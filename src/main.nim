#The Main files include each other sequentially.
#It starts with MainImports.
#MainImports is included by MainVariables.
#MainVariables is included by MainLocks.
#MainLocks is included by MainBlock.
#MainBlock is included by MainUpdate.
#MainUpdate is included by MainMine.
#It ends with MainMine.

#We could include all of them in this file, but then all the other files would throw errors.
#IDEs can't, and shouldn't, detect that an external file includes that file, and the external file resolves the dependencies.

#Include the last file in the sequence.
include MainMine

#Reset so we have data to mine with.
waitFor reset()

#Start mining.
asyncCheck mine(0)

#Run forever.
runForever()
