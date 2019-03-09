include MainLocks

#Get the most recent Verifications.
proc getVerifs() {.async.} =
    verifs = @[]
    aggregates = @[]

    var jsonVerifs: JSONNode = await rpc.verifications.getUnarchivedVerifications()
    for index in jsonVerifs:
        verifs.add(
            newVerifierIndex(
                parseHexStr(index["verifier"].getStr()),
                uint(index["nonce"].getInt()),
                parseHexStr(index["merkle"].getStr())
            )
        )
        aggregates.add(newBLSSignature(index["signature"].getStr()))

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
    )["header"]["hash"].getStr().toArgonHash()

    #Verifications.
    await getVerifs()

    #Release the RPC.
    releaseRPC()

    #Create a block.
    mining = newBlockObj(nonce, last, aggregates.aggregate(), verifs, miners)

#Check for Verifications.
proc checkup() {.async.} =
    while true:
        #Run every thirty seconds.
        await sleepAsync(30000)

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
        )["header"]["hash"].getStr().toArgonHash()
        releaseRPC()

        #If someone else mined a block...
        if newNonce != nonce:
            await reset()
            return

        #If the chain forked...
        if newLast != last:
            await reset()
            return

        #Get the Verifications.
        await acquireRPC()
        await getVerifs()
        releaseRPC()

        #Construct a new block.
        mining = newBlockObj(nonce, last, aggregates.aggregate(), verifs, miners)
