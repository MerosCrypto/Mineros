#Argon library.
import Argon2

#String utils standard lib.
import strutils

#Define the Hash Type.
type ArgonHash* = object
    data*: array[48, uint8]

#Take in data and a salt; return a ArgonHash.
proc Argon*(
    data: string,
    salt: string
): ArgonHash =
    result.data = Argon2d(
        data,
        salt,
        1,
        131072,
        1
    ).data

#toHash function.
func toArgonHash*(
    hash: string
): ArgonHash =
    if hash.len == 48:
        for i in 0 ..< hash.len:
            result.data[i] = uint8(hash[i])
    elif hash.len == 96:
        for i in countup(0, hash.len - 1, 2):
            result.data[i div 2] = uint8(parseHexInt(hash[i .. i + 1]))
    else:
        raise newException(ValueError, "toHash not handed the right amount of data.")


#Compare hash values.
func `<`*(
    lhs: ArgonHash,
    rhs: ArgonHash
): bool =
    var bytes: int = 48
    for i in 0 ..< bytes:
        if lhs.data[i] == rhs.data[i]:
            continue
        elif lhs.data[i] < rhs.data[i]:
            return true
        else:
            return false
    return false

#Left-pads data, with a char or string, until the data is a certain length.
func pad*(
    data: char or string,
    len: int,
    prefix: char or string = char(0)
): string =
    result = $data

    while result.len < len:
        result = prefix & result

#Converts a number to a binary string.
func toBinary*(
    number: SomeNumber
): string =
    var
        #Get the bytes of the number.
        bytes: int = sizeof(number)
        #Init the shift counters.
        left: int = -8
        right: int = bytes * 8
        #Have we encountered a non 0 byte yet?
        filler: bool = true

    #Iterate over each byte.
    for i in 0 ..< bytes:
        #Update left/right.
        left += 8
        right -= 8

        #Clear the left side, shift it back, and clear the right side.
        var b: int = int(number shl left shr (left + right))

        #If we haven't hit a non-0 byte...
        if filler:
            #And this is a 0 byte...
            if b == 0:
                #Continue.
                continue
            #Else, mark that we have hit a 0 byte.
            filler = false

        #Put the byte in the string.
        result &= char(b)
