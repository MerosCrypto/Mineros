include MainUpdate

#Mine.
proc mine(startProof: uint) {.async.} =
    #Start the checkup proc.
    asyncCheck checkup()

    #Mine the chain.
    while true:
        #Get the difficulty.
        await acquireRPC()
        difficulty = newBN(await rpc.merit.getDifficulty())
        releaseRPC()

        #Mine it.
        while true:
            #Allow checkup to run.
            await sleepAsync(1)

            try:
                #Make sure the Block beats the difficulty.
                if mining.hash.toBN() < difficulty:
                    raise newException(Exception, "Block didn't beat the Difficulty.")

                #Publish the block.
                try:
                    await acquireRPC()
                    await rpc.merit.publishBlock(mining.serialize())
                    releaseRPC()
                except:
                    #Make sure we released the RPC.
                    releaseRPC()
                    #Since we thought we published a valid block, reset.
                    await reset()
                    #Continue.
                    continue

                #If we succeded, break.
                break
            except:
                #Increase the proof.
                inc(mining)

        #Print that we mined a block.
        echo "Mined Block " & $nonce & "."

        #Reset the Block data.
        await reset()
