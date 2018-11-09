include MainVariables

#Acquire the RPC.
proc acquireRPC() {.async.} =
    #Make sure no other async procs are using the RPC.
    while rpcBool:
        #If they are, sleep so they can finish.
        await sleepAsync(1)
    rpcBool = true
    #Make sure no other threads are using the RPC.
    acquire(rpcLock)

#Release the RPC.
proc releaseRPC() =
    rpcBool = false
    release(rpcLock)
