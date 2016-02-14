import cpu, ppu, cartridge
type
  NES* = ref NESObj
  NESObj = object
    cpu: CPU
    ppu: PPU
    cart: Cartridge

proc reset*(nes: NES) =
  nes.cpu.reset()
  nes.ppu.reset()

proc cpuRead*(nes: NES, address: uint16): uint8 =
  case address
  #Mirrored internal cpu memory
  of 0..0x1FFFu16:
    result = nes.cpu.memory[address mod cast[uint16](len(nes.cpu.memory))]
  #PPU registers
  of 0x2000u16..0x3FFFu16:
    let regNumber = address mod 8
  #APU and IO registers
  of 0x4000u16..0x401Fu16:
    discard
  #Cartridge space
  of 0x4020u16..0xFFFFu16:
    discard


proc powerOn*(nes: NES) =
  nes.cpu.powerOn()
  nes.ppu.powerOn()
  nes.cart = loadCartridge("../smb.nes")
  let pc: uint16 = (nes.cpuRead(0xFFFD) shl 8) or nes.cpuRead(0xFFFC)

  nes.cpu.pc = pc


proc test() =
  var n = new(NES)
  n.powerOn()
  discard
