#Math standard lib.
import math

#Compare hash values.
func lessThan*(
    lhs: string,
    rhs: string
): bool =
    var bytes: int = 48
    for i in 0 ..< bytes:
        if int(lhs[i]) == int(rhs[i]):
            continue
        elif int(lhs[i]) < int(rhs[i]):
            return true
        else:
            return false
    return false

#Converts a number to a binary string.
func toBinary*(
    number: SomeNumber,
    length: int = 0
): string {.raises: [].} =
    #Get the amount of bytes the number actually uses.
    var used: int = 0
    if number != 0:
        used = ceil((floor(log2(float(number))) + 1) / 8).toInt()

    #Add filler bytes to the final result is at least length.
    #If the amount of bytes needed is more than the length, the result will be the amount needed.
    result = newString(max(length - used, 0))

    #Shift counters.
    var
        mask: uint = 255
        fromEnd: int = (used - 1) * 8

    #Iterate over each byte.
    while fromEnd >= 0:
        result &= char((uint64(number) and uint64(mask shl fromEnd)) shr fromEnd)
        fromEnd -= 8
