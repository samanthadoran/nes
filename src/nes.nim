import cpu, ppu, cartridge
type
  NES* = ref NESObj
  NESObj = object
    cpu: CPU
    ppu: PPU
    cart: Cartridge

proc reset(nes: NES) =
  nes.cpu.reset()
  nes.ppu.reset()

proc powerOn(nes: NES) =
  nes.cpu.powerOn()
  nes.ppu.powerOn()
