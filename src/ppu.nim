type
  ppuRegs* = enum
    PPUCTRL,
    PPUMASK,
    PPUSTATUS,
    OAMADDR,
    OAMDATA,
    PPUSCROLL,
    PPUADDR,
    PPUDATA
  PPU* = ref PPUObj
  PPUObj = object
    regs*: array[PPUCTRL..PPUDATA, uint8]

proc reset*(c: PPU) =
  discard

proc powerOn*(c: PPU) =
  discard
