#Util lib.
import ../lib/Util

#Base lib.
import ../lib/Base

#Hash lib.
import ../lib/Hash

#BLS lib.
import ../lib/BLS

#Merit objects.
import ../Merit/objects/VerificationsObj
import ../Merit/objects/BlockHeaderObj
import ../Merit/objects/MinersObj
import ../Merit/objects/BlockObj

#Serialize/Deserialize functions.
import SerializeCommon
import SerializeBlockHeader
import SerializeVerifications
import SerializeMiners

#String utils standard lib.
import strutils

#Serialize a Block.
func serialize*(blockArg: Block): string {.raises: [].} =
    #Create the serialized Block.
    result =
        !blockArg.header.serialize() &
        !blockArg.proof.toBinary() &
        !blockArg.verifications.serialize() &
        !blockArg.miners.serialize()
