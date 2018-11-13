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

    var
        jsonVerifs: JSONNode = await rpc.lattice.getUnarchivedVerifications()
        strVerif: string
    for verif in jsonverifs.items:
        #Get the serialized Verification.
        strVerif = parseHexStr(verif["verifier"].getStr()) & parseHexStr(verif["hash"].getStr())
        #If we added it, move on.
        if added.hasKey(strVerif):
            continue
        #Say we added it.
        added[strVerif] = true

        #Add each Verification.
        verifs.verifications.add(
            newMemoryVerification(verif["hash"].getStr().toHash(512))
        )
        verifs.verifications[^1].verifier = newBLSPublicKey(verif["verifier"].getStr())
        verifs.verifications[^1].signature = newBLSSignature(verif["signature"].getStr())
        verifs.verifications[^1].signature.setAggregationInfo(
            newBLSAggregationInfo(
                verifs.verifications[^1].verifier,
                verifs.verifications[^1].hash.toString()
            )
        )

    verifs.calculateSig()

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
            newVerifs: Verifications

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

        #Set newVerifs to the existing verifs.
        newVerifs[] = verifs[]

        #Get the Verifications.
        await acquireRPC()
        jsonVerifs = await rpc.lattice.getUnarchivedVerifications()
        releaseRPC()

        #Parse it.
        var strVerif: string
        for verif in jsonVerifs.items():
            #Get the serialized Verification.
            strVerif = parseHexStr(verif["verifier"].getStr()) & parseHexStr(verif["hash"].getStr())
            #If we added it, move on.
            if added.hasKey(strVerif):
                continue
            #Say we added it.
            added[strVerif] = true

            #Add each Verification.
            newVerifs.verifications.add(
                newMemoryVerification(verif["hash"].getStr().toHash(512))
            )
            newVerifs.verifications[^1].verifier = newBLSPublicKey(verif["verifier"].getStr())
            newVerifs.verifications[^1].signature = newBLSSignature(verif["signature"].getStr())
            newVerifs.verifications[^1].signature.setAggregationInfo(
                newBLSAggregationInfo(
                    newVerifs.verifications[^1].verifier,
                    newVerifs.verifications[^1].hash.toString()
                )
            )

        #Calculate the signature.
        newVerifs.calculateSig()

        #Set the Verifications to the New Verifications.
        verifs = newVerifs
