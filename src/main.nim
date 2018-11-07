#Util lib.
import Ember/lib/Util

#Numerical libs.
import BN
import Ember/lib/Base

#Hash lib.
import Ember/lib/Hash

#BLS lib.
import Ember/lib/BLS

#Merit objects.
import Ember/Merit/objects/DifficultyObj
import Ember/Merit/objects/MinersObj

#Merit libs.
import Ember/Merit/Verifications
import Ember/Merit/MinerWallet
import Ember/Merit/Block

#Block Serialization lib.
import Ember/Serialize/SerializeBlock

#Ember RPC lib.
import EmberRPC

#OS standard lib.
import os

#Locks standard lib.
import locks

#Async standard lib.
import asyncdispatch

#JSON standard lib.
import json

const
    gensis: string = "EMB_DEVELOPER_TESTNET"

var
    #Connect to the EMB Node.
    rpc: EmberRPC = waitFor newEmberRPC()
    #Lock for using the RPC.
    rpcLock: Lock
    #Boolean for making sure async procs don't use the RPC at the same time.
    rpcBool: bool
    #Public Key to mine to.
    publicKey: BLSPublicKey
    #Difficulty.
    difficulty: BN
    #Nonce.
    nonce: uint = uint(waitFor rpc.merit.getHeight())
    #Last Block hash.
    last: ArgonHash = (
        waitFor rpc.merit.getBlock(
            int(nonce - 1)
        )
    )["argon"].getStr().toArgonHash()
    #Verifications object.
    verifs: Verifications = newVerificationsObj()
    #Miners object.
    miners: Miners

#Calculate the Verifications' signature.
verifs.calculateSig()

#If there are params...
if paramCount() > 0:
    publicKey = newBLSPublicKey(paramStr(1))
else:
    #Else, create a new wallet.
    var miner: MinerWallet = newMinerWallet()
    publicKey = miner.publicKey
    echo "No wallet was passed in. A new one has been created with a Private Key of " & $miner.privateKey & "."

miners = @[(
    newMinerObj(
        publicKey,
        100
    )
)]

#Acquire the RPC.
proc acquireRPC() {.async.} =
    #Make sure no other async procs are using the RPC.
    while rpcBool:
        #If they are, sleep so they can finish.
        await sleepAsync(1)
    rpcBool = true
    #Make sure no other threads are using the RPC.
    acquire(rpcLock)

#Release the RPC.
proc releaseRPC() =
    rpcBool = false
    release(rpcLock)

#Check for Verifications.
proc checkup() {.async.} =
    while true:
        #Run every ten seconds.
        await sleepAsync(10000)

        #Get the Verifications.
        await acquireRPC()
        var jsonVerifs: JSONNode = await rpc.lattice.getUnarchivedVerifications()
        releaseRPC()

#Main function is so this runs async.
proc main() {.async.} =
    #Block.
    var newBlock: Block

    #Start the checkup proc.
    asyncCheck checkup()

    #Mine the chain.
    while true:
        #Get the difficulty.
        await acquireRPC()
        difficulty = newBN(await rpc.merit.getDifficulty())
        releaseRPC()

        #Create a block.
        newBlock = newBlock(
            nonce,
            last,
            verifs,
            miners
        )

        #Mine it.
        while true:
            try:
                #Make sure the Block beats the difficulty.
                if newBlock.argon.toBN() < difficulty:
                    raise newException(Exception, "Block didn't beat the Difficulty.")

                #Publish the block.
                try:
                    await acquireRPC()
                    await rpc.merit.publishBlock(newBlock.serialize())
                    releaseRPC()
                except:
                    echo "The miner submitted a Block the Node considered invalid."
                    quit(-1)

                #If we succeded, break.
                break
            except:
                #Increase the proof.
                inc(newBlock)

        #Print that we mined a block.
        echo "Mined a block: " & $nonce

        #Increase the nonce.
        inc(nonce)
        #Update last.
        last = newBlock.argon

asyncCheck main()
runForever()
