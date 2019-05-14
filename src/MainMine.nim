include MainUpdate

#Mine.
proc mine(
    startProof: int
) {.async.} =
    #Start the checkup proc.
    asyncCheck checkup()

    #Mine the chain.
    while true:
        #Mine the current Block.
        while mining.header.hash < difficulty:
            #Allow checkup to run.
            await sleepAsync(1)

            #Increment the proof.
            inc(mining)

        #Publish the block.
        try:
            echo "Publishing a Block."
            await acquireRPC()
            await rpc.merit.publishBlock(mining.serialize())
            #Print that we mined a block.
            echo "Mined Block " & $nonce & "."
        except Exception as e:
            echo "Block we attempted to publish was rejected: " & e.msg
        finally:
            #Make sure we release the RPC.
            releaseRPC()

        #Since we either published a valid Block, or thought we did, reset.
        await reset()
