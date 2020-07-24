import bitops

import stint

#Converts a number to a binary string.
func toBinary*(
  number: SomeNumber,
  length: int = 0
): string {.raises: [].} =
  var used: int = 0
  if number != 0:
    used = sizeof(number) - (countLeadingZeroBits(number) div 8)
  result = newString(max(length, used))

  var c: int = 0
  while c < used:
    result[c] = char((number shr (c * 8)) and 0b11111111)
    inc(c)

#Check if a hash overflows when multiplied by a factor.
#Used for the difficulty code.
proc overflows*(
  hash: string,
  factor: uint32 or uint64
): bool {.raises: [].} =
  var
    hashCopy: array[64, byte]
    original: StUInt[512]
  for b in 0 ..< 32:
    hashCopy[b] = byte(hash[b])
  original = StUInt[512].fromBytesLE(hashCopy)

  var product: array[64, byte] = (original * stuint(factor, 512)).toBytesLE()
  for b in 32 ..< 64:
    if product[b] != 0:
      return true
