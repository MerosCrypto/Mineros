include MainImports

const
    gensis: string = "EMB_DEVELOPER_TESTNET"

var
    #Connect to the EMB Node.
    rpc: EmberRPC = waitFor newEmberRPC()
    #Lock for using the RPC.
    rpcLock: Lock
    #Boolean for making sure async procs don't use the RPC at the same time.
    rpcBool: bool
    #Public Key to mine to.
    publicKey: BLSPublicKey
    #Difficulty.
    difficulty: BN
    #Nonce.
    nonce: uint = uint(waitFor rpc.merit.getHeight())
    #Last Block hash.
    last: ArgonHash = (
        waitFor rpc.merit.getBlock(
            int(nonce - 1)
        )
    )["argon"].getStr().toArgonHash()
    #Verifications object.
    verifs: Verifications = newVerificationsObj()
    #Miners object.
    miners: Miners

#Calculate the Verifications' signature.
verifs.calculateSig()

#If there are params...
if paramCount() > 0:
    publicKey = newBLSPublicKey(paramStr(1))
else:
    #Else, create a new wallet.
    var miner: MinerWallet = newMinerWallet()
    publicKey = miner.publicKey
    echo "No wallet was passed in. A new one has been created with a Private Key of " & $miner.privateKey & "."

miners = @[(
    newMinerObj(
        publicKey,
        100
    )
)]
