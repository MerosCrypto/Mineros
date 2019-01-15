include MainImports

var
    #Connect to the Meros Node.
    rpc: MerosRPC = waitFor newMerosRPC()
    #Lock for using the RPC.
    rpcLock: Lock

    #Public Key to mine to.
    publicKey: BLSPublicKey

    #Current Difficulty.
    difficulty: BN
    #Nonce.
    nonce: uint
    #Last Block hash.
    last: ArgonHash
    #Verifications.
    verifs: seq[VerifierIndex]
    #Aggregate Signatures.
    aggregates: seq[BLSSignature]
    #Miners object.
    miners: Miners
    #Block.
    mining: Block

#If there are params, load them.
if paramCount() > 0:
    publicKey = newBLSPublicKey(paramStr(1))
#Else, create a new wallet to mine to.
else:
    echo "No wallet was passed in. Please run this command with a BLS Public Key (in hex format) after it."
    quit()

#Create the Miners object now that we know the Public Key.
miners = @[(
    newMinerObj(
        publicKey,
        100
    )
)]
