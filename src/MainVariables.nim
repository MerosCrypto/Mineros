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
    verifs: seq[Index]
    #Merkles.
    merkles: Table[string, string]
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
    var miner: MinerWallet = newMinerWallet()
    publicKey = miner.publicKey
    echo "No wallet was passed in. A new one has been created with a Private Key of " & $miner.privateKey & " and Public Key of " & $miner.publicKey & "."

#Create the Miners object now that we know the Public Key.
miners = @[(
    newMinerObj(
        publicKey,
        100
    )
)]
