import os
import locks
import asyncdispatch
import strutils
import json

import stint
import mc_randomx
import mc_bls
import MerosRPC

import Util

var
  host: string
  port: int
  rpc: MerosRPC
  rpcLock: Lock

  minerKey: PrivateKey

  id: int
  header: string
  body: string

  difficulty: uint64

  key: string = ""
  flags: RandomXFlags = getFlags()
  cache: RandomXCache = allocCache(flags)
  vm: RandomXVM

vm = createVM(flags, cache, nil)

if paramCount() == 2:
  host = paramStr(1)
  try:
    port = parseInt(paramStr(2))
  except ValueError as e:
    echo "Failed to parse port: ", e.msg
    quit(1)
else:
  echo "Meros node host and port is required.\n"
  echo "Usage: Mineros <host> <port>"
  quit(1)

#Acquire a lock over the RPC.
proc acquireRPC() {.async.} =
  while not tryAcquire(rpcLock):
    await sleepAsync(1)

#Release the RPC.
proc releaseRPC() =
  release(rpcLock)

#Reset all data.
#This is used when someone else mines a Block or we publish an invalid one.
proc reset() {.async.} =
  await acquireRPC()

  #Get the Block template.
  var blockTemplate: JSONNode = await rpc.merit.getBlockTemplate(minerKey.toPublicKey().serialize())
  id = blockTemplate["id"].getInt()
  if key != blockTemplate["key"].getStr():
    key = parseHexStr(blockTemplate["key"].getStr())
    cache.init(key)
    vm.setCache(cache)
  header = parseHexStr(blockTemplate["header"].getStr())
  body = parseHexStr(blockTemplate["body"].getStr())

  #Get the difficulty.
  difficulty = fromHex[uint64]((await rpc.merit.getDifficulty()).toHex())

  #Release the RPC.
  releaseRPC()

proc getMinerKey(): Future[PrivateKey] {.async.} =
  await acquireRPC()
  var key: string = await rpc.personal.getMiner()
  result = newPrivateKey(key)
  releaseRPC()

#Check for an updated Block.
proc checkup() {.async.} =
  while true:
    #Run every thirty seconds.
    await sleepAsync(30000)
    await reset()

proc mine(
  startProof: int
) {.async.} =
  #Mine the chain.
  var
    proof: int = startProof
    hash: string
    signature: Signature
    final: StUint[512]
  while true:
    block thisProof:
      #Mine the Block.
      hash = vm.hash(header & proof.toBinary(4))
      signature = minerKey.sign(hash)
      hash = vm.hash(hash & signature.serialize())

      if hash.overflows(difficulty):
        #Allow checkup to run.
        await sleepAsync(1)
        #Increment the proof.
        inc(proof)
        #Try the next proof.
        break thisProof

      #Since we didn't move to the next proof, publish the block.
      try:
        await acquireRPC()
        await rpc.merit.publishBlock(id, header & proof.toBinary(4) & signature.serialize() & body)
        #Print that we mined a block.
        echo "Mined Block."
      except Exception as e:
        echo "Block we attempted to publish was rejected: " & e.msg
      finally:
        #Make sure we release the RPC.
        releaseRPC()

      #Since we either published a valid Block, or thought we did, reset.
      await reset()

#Register CTRL+C exiting.
#This will allow for a cleaner shutdown in the future.
proc ctrlc() {.noconv.} =
  echo "Exiting."
  quit(0)
setControlCHook(ctrlc)

#Initialize RPC lock.
initLock(rpcLock)

try:
  echo "Connecting to Meros."
  rpc = waitFor newMerosRPC(host, port)
except OSError as e:
  echo "Failed to connect to RPC at ", host, ":", port, " due to: " & e.msg
  quit(1)

echo "Retrieving miner key."
minerKey = waitFor getMinerKey()

waitFor reset()
asyncCheck checkup()

echo "Mining."
asyncCheck mine(0)

runForever()
