include MainUpdate

#Mine.
proc mine(startProof: uint) {.async.} =
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
            miners,
            startProof
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
                    #Make sure we released the RPC.
                    releaseRPC()
                    #Since we thought we published a valid block, reset.
                    await reset()
                    #Recreate the Block.
                    newBlock = newBlock(
                        nonce,
                        last,
                        verifs,
                        miners,
                        startProof
                    )
                    #Continue.
                    continue

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
