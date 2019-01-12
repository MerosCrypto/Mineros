include MainVariables

#Acquire the RPC.
proc acquireRPC() {.async.} =
    #Acquire the RPC lock.
    while not tryAcquire(rpcLock):
        #While we can't acquire it, allow other async processes to run.
        await sleepAsync(1)

#Release the RPC.
proc releaseRPC() =
    release(rpcLock)
