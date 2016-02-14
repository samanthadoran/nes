import cpu, ppu, cartridge, strutils
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
    case address
    #PRG RAM
    of 0x6000u16..0x7FFFu16:
      let modAddr = cast[int](address) mod len(nes.cart.prgRAM)
      #echo("Reading from prg rom bank 1. Index of array is is: ", cast[int](modAddr).toHex(4))
      result = nes.cart.prgRAM[modAddr]
      #echo("Result is: ", cast[int](result).toHex(2))
    of 0x8000u16..0xFFFFu16:
      let modAddr = cast[int](address) mod len(nes.cart.prgROM)
      #echo("Reading from prg rom bank 2. Index of array is is: ", cast[int](modAddr).toHex(4))
      result = nes.cart.prgROM[modAddr]
      #echo("Result is: ", cast[int](result).toHex(2))
    else:
      discard

proc powerOn*(nes: NES) =
  nes.cpu.powerOn()
  nes.ppu.powerOn()
  nes.cart = loadCartridge("../smb.nes")
  let pc: uint16 = (cast[uint16](nes.cpuRead(0xFFFD)) shl 8) or cast[uint16](nes.cpuRead(0xFFFC))
  nes.cpu.pc = pc
  while true:
    echo("PC is: ", cast[int](nes.cpu.pc).toHex(4))
    nes.cpu.opcode = nes.cpuRead(nes.cpu.pc)
    nes.cpu.stepPC()
    nes.cpu.decode()
    echo("Opcode is: ", cast[int](nes.cpu.opcode).toHex(2))


proc test() =
  var n = new(NES)
  n.cpu = new(CPU)
  n.ppu = new(PPU)
  n.powerOn()

test()
