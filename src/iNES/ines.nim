type
  #16 bytes total
  iNESHeader* = object
    magic*: array[4, uint8]
    sizeOfPRGROM*: uint8
    sizeOfCHRROM*: uint8
    flags6*: uint8
    flags7*: uint8
    sizeOfPRGRAM*: uint8
    flags9*: uint8
    flags10*: uint8
    zeroPad*: array[5, uint8]
