type
  #16 bytes total
  iNESHeader* = object
    magic*: array[4, uint8]
    #Size of prg rom in 16 KiB units
    sizeOfPRGROM*: uint8
    #Size of chr rom in 8 KiB units
    sizeOfCHRROM*: uint8
    flags6*: uint8
    flags7*: uint8
    #Size of prg ram in 8 KiB units
    sizeOfPRGRAM*: uint8
    flags9*: uint8
    flags10*: uint8
    zeroPad*: array[5, uint8]
