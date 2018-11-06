#Util lib.
import ../lib/Util

#Miners object.
import ../Merit/objects/MinersObj

#Common serialization functions.
import SerializeCommon

#BLS lib.
import ../lib/BLS

#String utils standard library.
import strutils

#Serialization function.
func serialize*(
    miners: Miners
): string {.raises: [].} =
    #Add each miner.
    for miner in 0 ..< miners.len:
        result &=
            !miners[miner].miner.toString() &
            char(1) & char(miners[miner].amount)
