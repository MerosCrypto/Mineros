#We never keep a full copy of the Verifications.
#Because of this, we can't call newBlock or Block.serialize.
#This file offers custom solutions to bypass this requirement.

include MainLocks

proc newBlock(
    nonce: uint,
    last: ArgonHash,
    verifs: seq[Index],
    miners: Miners
): Block =
    result = Block(
        header: newBlockheaderObj(
            nonce,
            last,
            nil,
            miners.calculateMerkle(),
            getTime(),
            0
        ),
        verifications: verifs,
        miners: miners
    )

    if verifs.len > 0:
        discard

    #Set the Header hash.
    result.hash = Argon(result.header.serialize(), result.header.proof.toBinary())

proc serialize(blockArg: Block): string =
    #Serialize the Verifications.
    for index in blockArg.verifications:
        result &=
            !index.key &
            !index.nonce.toBinary() &
            !merkles[index.key]

    #Create the serialized Block.
    result =
        !blockArg.header.serialize() &
        !result &
        !blockArg.miners.serialize()
