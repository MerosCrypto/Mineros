#Util lib.
import Ember/lib/Util

#BN lib.
import BN

#Hash lib.
import Ember/lib/Hash

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

#Async standard lib.
import asyncdispatch

#JSON standard lib.
import json

#Main function is so these varriables can be GC'd.
proc main() {.async.} =
    var
        #Connect to the EMB Node.
        rpc: EmberRPC = await newEmberRPC()
        #Difficulty.
        difficulty: BN
        #Create a Wallet for signing Verifications.
        miner: MinerWallet = newMinerWallet()
        #Gensis string.
        genesis: string = "mainnet"
        #Block.
        newBlock: Block
        #Nonce.
        nonce: uint = 1
        #Last Block hash.
        last: ArgonHash = (
            await rpc.merit.getBlock(
                await rpc.merit.getHeight()
            )
        )["header"]["last"].getStr().toArgonHash()
        #Verifications object.
        verifs: Verifications = newVerificationsObj()
        #Miners object.
        miners: Miners = @[(
            newMinerObj(
                miner.publicKey,
                100
            )
        )]
    #Calculate the Verifications' signature.
    verifs.calculateSig()

    #Mine the chain.
    while true:
        #Get the difficulty.
        difficulty = newBN(await rpc.merit.getDifficulty())
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
                if newBlock.header.last.toBN() < difficulty:
                    raise newException(Exception, "Block didn't beat the Difficulty.")

                #Publish the block.
                await rpc.merit.publishBlock(newBlock.serialize())

                #If we succeded, break.
                break
            except:
                #If we failed, print the proof we tried.
                echo "Proof " & $newBlock.proof & " failed."
                #Increase the proof.
                inc(newBlock)

        #Print that we mined a block.
        echo "Mined a block: " & $nonce

        #Increase the nonce.
        inc(nonce)
        #Update last.
        last = newBlock.argon

asyncCheck main()
