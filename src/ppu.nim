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
    oddFrame*: bool
    regs*: array[PPUCTRL..PPUDATA, uint8]
    oam*: array[256, uint8]

proc reset*(p: PPU) =
  p.regs[ppuRegs.PPUCTRL] = 0u8
  p.regs[ppuRegs.PPUMASK] = 0u8
  #Status
  #OAM ADDR stays unchanged
  #2005/2006 latch is cleared
  p.regs[ppuRegs.PPUSCROLL] = 0u8
  #PPU Addr is unchanged
  p.regs[ppuRegs.PPUDATA] = 0u8
  p.oddFrame = false

proc powerOn*(p: PPU) =
  p.regs[ppuRegs.PPUCTRL] = 0u8
  p.regs[ppuRegs.PPUMASK] = 0u8
  #Status
  p.regs[ppuRegs.OAMADDR] = 0u8
  #2005/2006 latch is cleared
  p.regs[ppuRegs.PPUSCROLL] = 0u8
  p.regs[ppuRegs.PPUADDR] = 0u8
  p.regs[ppuRegs.PPUDATA] = 0u8
  p.oddFrame = false
