#Util lib.
import Util

#RandomX lib.
import mc_randomx

#BLS lib.
import mc_bls

#Meros RPC lib.
import MerosRPC

#OS standard lib.
import os

#Locks standard lib.
import locks

#Async standard lib.
import asyncdispatch

#String utils standard lib.
import strutils

#JSON standard lib.
import json

var
    #Meros node host
    host: string
    #Meros node port
    port: int
    #Connect to the Meros Node.
    rpc: MerosRPC
    #Lock for using the RPC.
    rpcLock: Lock

    #Miner Key.
    minerKey: PrivateKey

    #ID.
    id: int
    #Header.
    header: string
    #Body.
    body: string

    #Current Difficulty.
    difficulty: string

    #RandomX VM.
    key: string = ""
    flags: RandomXFlags = getFlags()
    cache: RandomXCache = allocCache(flags)
    vm: RandomXVM

vm = createVM(flags, cache, nil)

#If there are params, load them.
if paramCount() == 2:
    host = paramStr(1)
    try:
        port = parseInt(paramStr(2))
    except ValueError as e:
        echo "Failed to parse port: ", e.msg
        quit(1)
#Else, create a new wallet to mine to.
else:
    echo "Meros node host and port is required.\n"
    echo "Usage: Mineros <host> <port>"
    quit(1)

#Acquire the RPC.
proc acquireRPC() {.async.} =
    #Acquire the RPC lock.
    while not tryAcquire(rpcLock):
        #While we can't acquire it, allow other async processes to run.
        await sleepAsync(1)

#Release the RPC.
proc releaseRPC() =
    release(rpcLock)

#Reset all data.
#This is used when someone else mines a Block or we publish an invalid one.
proc reset() {.async.} =
    #Acquire the RPC.
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
    difficulty = await rpc.merit.getDifficulty()

    #Release the RPC.
    releaseRPC()

proc getMinerKey(): Future[PrivateKey] {.async.} =
    #Acquire the RPC.
    await acquireRPC()

    #Get miner key
    var key: string = await rpc.personal.getMiner()

    #Parse to PrivateKey
    result = newPrivateKey(key)

    #Release the RPC.
    releaseRPC()

#Check for Verifications.
proc checkup() {.async.} =
    while true:
        #Run every thirty seconds.
        await sleepAsync(30000)

        #Update the template/difficulty.
        await reset()

#Mine.
proc mine(
    startProof: int
) {.async.} =
    #Mine the chain.
    var
        proof: int = startProof
        hash: string
        signature: Signature
    while true:
        #Mine the Block.
        hash = vm.hash(header & proof.toBinary(4))
        signature = minerKey.sign(hash)
        hash = vm.hash(hash & signature.serialize())

        if hash.lessThan(difficulty):
            #Allow checkup to run.
            await sleepAsync(1)

            #Increment the proof.
            inc(proof)

            #Continue.
            continue

        #Publish the block.
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

proc ctrlc() {.noconv.} =
    echo "Exiting."
    quit(0)

#Register CTRL+C exiting.
setControlCHook(ctrlc)

#Initialize RPC lock.
initLock(rpcLock)

#Connect to RPC.
try:
    echo "Connecting to RPC."
    rpc = waitFor newMerosRPC(host, port)
except OSError:
    #We don't output e.msg because of https://github.com/nim-lang/Nim/issues/11029.
    echo "Failed to connect to RPC at ", host, ":", port, "."
    quit(1)

#Get Miner Key
echo "Retrieving miner key."
minerKey = waitFor getMinerKey()

#Reset so we have data to mine with.
waitFor reset()

#Start the checkup proc.
asyncCheck checkup()

#Start mining.
echo "Mining."
asyncCheck mine(0)

#Run forever.
runForever()
