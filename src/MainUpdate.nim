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
    )["argon"].getStr().toArgonHash()

    #Verifications.
    verifs = newVerificationsObj()
    verifs.calculateSig()
    added = initTable[string, bool]()

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
            #JSON Verifications.
            jsonVerifs: JSONNode
            #New Verifications.
            newVerifs: Verifications = newVerificationsObj()

        #Get the current Blockchain Height and Last Hash.
        await acquireRPC()
        newNonce = uint(await rpc.merit.getHeight())
        newLast = (
            await rpc.merit.getBlock(
                int(newNonce - 1)
            )
        )["argon"].getStr().toArgonHash()
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
        jsonVerifs = await rpc.lattice.getUnarchivedVerifications()
        releaseRPC()

        #Parse it.
        var strVerif: string
        for jsonVerif in jsonVerifs.items():
            #Turn the Verification into a string.
            strVerif = parseHexStr(jsonVerif["verifier"].getStr()) & parseHexStr(jsonVerif["hash"].getStr())
            #If we added it, move on.
            if added.hasKey(strVerif):
                continue
            #Make sure we have an entry for it.
            added[strVerif] = true

            #Create the Verification.
            var verif: MemoryVerification = newMemoryVerification(
                jsonVerif["hash"].getStr().toHash(512)
            )
            verif.verifier = newBLSPublicKey(jsonVerif["verifier"].getStr)
            verif.signature = newBLSSignature(jsonVerif["signature"].getStr)

            #Add it to the New Verifications.
            newVerifs.verifications.add(verif)

        #Calculate the signature.
        newVerifs.calculateSig()

        #Set the Verifications to the New Verifications.
        verifs = newVerifs
