import iNES/ines

type
  Cartridge* = ref CartridgeObj
  CartridgeObj = object
    prgROM*: seq[uint8]
    prgROMWindow*: uint8
    prgRAM*: seq[uint8]
    prgRAMWindow*: uint8
    chr*: seq[uint8]
    chrWindow*: uint8


proc loadCartridge(rom: string): Cartridge =
  result = new(Cartridge)
  var f: File
  if f.open(rom):
    discard
  else:
    echo("Failed to open rom!")


discard """
proc loadROM*(c: Chip8, rom: string): bool =
  var f: File
  if f.open(rom):
    result = true
    #From rom offset until the top of memory
    let len = 0xFFFu16 - romOffset
    discard f.readBytes(c.memory, c.pc, len)
    f.close()
  else:
    echo("Failed to open file!")
    result = false

"""
