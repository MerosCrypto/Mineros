include MainLocks

#Reset all data.
#This is used when someone else mines a Block or we publish an invalid one.
proc reset() {.async.} =
    #Acquire the RPC.
    await acquireRPC()

    #Nonce.
    nonce = uint(await rpc.merit.getHeight())

    #Difficulty.
    difficulty = newBN(await rpc.merit.getDifficulty())

    #Last.
    last = (
        await rpc.merit.getBlock(
            int(nonce - 1)
        )
    )["hash"].getStr().toArgonHash()

    #Handle Verifications.
    ###
    ###
    ###

    #Release the RPC.
    releaseRPC()

#Check for Verifications.
proc checkup() {.async.} =
    while true:
        #Run every five seconds.
        await sleepAsync(5000)

        var
            #New Nonce.
            newNonce: uint
            #New Last Hash.
            newLast: ArgonHash

        #Get the current Blockchain Height and Last Hash.
        await acquireRPC()
        newNonce = uint(await rpc.merit.getHeight())
        newLast = (
            await rpc.merit.getBlock(
                int(newNonce - 1)
            )
        )["hash"].getStr().toArgonHash()
        releaseRPC()

        #If someone else mined a block...
        if newNonce != nonce:
            await reset()
            return

        #If the chain forked...
        if newLast != last:
            await reset()
            return
