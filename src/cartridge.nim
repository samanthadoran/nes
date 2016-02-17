import iNES/ines, mapper
import strutils

type
  Cartridge* = ref CartridgeObj
  CartridgeObj = object
    prgROM*: seq[uint8]
    prgROMWindow*: uint8
    prgRAM*: seq[uint8]
    prgRAMWindow*: uint8
    chrROM*: seq[uint8]
    chrRAM*: seq[uint8]
    chrWindow*: uint8
    mapperNumber*: int

const PRGSize: uint32 = 0x4000u32
const CHRSize: uint32 = 0x2000u32


proc loadCartridge*(rom: string): Cartridge =
  result = new(Cartridge)
  var f: File
  if f.open(rom):
    var header: iNESHeader

    #Read in as plain array for simplicity...
    var tmparray: array[16, uint8]
    discard f.readBytes(tmparray, 0, 16)

    #Store in an organized fashion
    header.magic[0..<len(header.magic)] = tmparray[0..3]
    header.sizeOfPRGROM = tmparray[4]
    header.sizeOfCHRROM = tmparray[5]
    header.flags6 = tmparray[6]
    header.flags7 = tmparray[7]
    header.sizeOfPRGRAM = tmparray[8]
    header.flags9 = tmparray[9]
    header.flags10 = tmparray[10]
    header.zeroPad[0..<len(header.zeroPad)] = tmparray[11..15]

    #We don't handle trainers for right now, skip them if present
    if ((header.flags6 shr 2) and 1u8) == 1u8:
      f.setFilePos(f.getFilePos() + 512)

    #Read prg rom
    echo("PRG Rom size: 0x", cast[int](PRGSize * header.sizeOfPRGROM).toHex(4))
    result.prgROM = newSeq[uint8](PRGSize * header.sizeOfPRGROM)
    discard f.readBytes(result.prgROM, 0, PRGSize * header.sizeOfPRGROM)

    #Read chr rom if present
    if header.sizeOfCHRROM == 0:
      result.chrRAM = newSeq[uint8] (CHRSize)
    else:
      result.chrROM = newSeq[uint8] (CHRSize)

    if result.chrRam == nil:
      discard f.readBytes(result.chrROM, 0, CHRSize * header.sizeOfCHRROM)

  else:
    echo("Failed to open rom!")
