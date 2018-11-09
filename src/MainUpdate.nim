include MainLocks

#Reset all data.
#This is used when someone else mines a Block or we publish an invalid one.
proc reset() {.async.} =
    discard

#Check for Verifications.
proc checkup() {.async.} =
    while true:
        #Run every ten seconds.
        await sleepAsync(10000)

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
        for jsonVerif in jsonVerifs.items():
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
