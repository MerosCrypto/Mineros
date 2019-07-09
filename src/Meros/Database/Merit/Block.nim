#Errors lib.
import ../../lib/Errors

#Util lib.
import ../../lib/Util

#Hash lib.
import ../../lib/Hash

#MinerWallet lib.
import ../../Wallet/MinerWallet

#MeritHolderRecord object.
import ../common/objects/MeritHolderRecordObj

#BlockHeader lib.
import BlockHeader

#Block object.
import objects/BlockObj
export BlockObj

#Serialize BlockHeader libs (for inc).
import ../../Network/Serialize/Merit/SerializeBlockHeader

#Tables standard lib.
import tables

#Increase the proof.
func inc*(
    blockArg: var Block
) {.forceCheck: [
    ArgonError
].} =
    #Increase the proof.
    inc(blockArg.header.proof)
    #Recalculate the hash.
    try:
        blockArg.header.hash = Argon(blockArg.header.serialize(true), blockArg.header.proof.toBinary())
    except ArgonError as e:
        fcRaise e
