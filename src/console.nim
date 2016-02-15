import cpu, ppu, cartridge
import strutils, tables
type
  NES* = ref NESObj
  NESObj = object
    cpu*: CPU
    ppu*: PPU
    cart*: Cartridge

proc cpuWrite*(nes: NES, address: uint16, value: uint8)
proc cpuRead*(nes: NES, address: uint16): uint8

var instructions* = initTable[uint8, proc(n: NES)]()

proc reset*(nes: NES) =
  nes.cpu.reset()
  nes.ppu.reset()

proc cpuWrite*(nes: NES, address: uint16, value: uint8) =
  case address
  #CPU Memory
  of 0x0u16..0x1FFFu16:
    nes.cpu.memory[address mod cast[uint16](len(nes.cpu.memory))] = value
  #PPU Registers
  of 0x2000u16..0x3FFFu16:
    let regIndex = ppuRegs(address mod 8)
    case regIndex
    of PPUSTATUS:
      echo("We really shouldn't write to ", PPUSTATUS)
    else:
      nes.ppu.regs[regIndex] = value
  #PRG RAM
  of 0x6000u16..0x7FFFu16:
    if len(nes.cart.prgRAM) != 0:
      let modAddr = cast[int](address) mod len(nes.cart.prgRAM)
      nes.cart.prgRAM[modAddr] = value
    else:
      echo("NO PRG RAM")
  else:
    echo("Can't write to location: 0x", cast[int](address).toHex(4))

proc cpuRead*(nes: NES, address: uint16): uint8 =
  case address
  #Mirrored internal cpu memory
  of 0x0u16..0x1FFFu16:
    result = nes.cpu.memory[address mod cast[uint16](len(nes.cpu.memory))]
  #PPU registers
  of 0x2000u16..0x3FFFu16:
    let regIndex = ppuRegs(address mod 8)
    result =
      case regIndex
        of PPUSTATUS, OAMDATA, PPUDATA:
          nes.ppu.regs[regIndex]
        else:
          echo("We really shouldn't read from ", regIndex)
          0u8
  #APU and IO registers
  of 0x4000u16..0x401Fu16:
    discard
  #Cartridge space
  #TODO: Make this mapper agnostic
  #Mapper registers
  of 0x4020u16..0x5FFFu16:
    discard
  #PRG RAM
  of 0x6000u16..0x7FFFu16:
    if len(nes.cart.prgRAM) != 0:
      let modAddr = cast[int](address) mod len(nes.cart.prgRAM)
      result = nes.cart.prgRAM[modAddr]
    else:
      echo("NO PRG RAM!!!")
  #PRG ROM
  of 0x8000u16..0xFFFFu16:
    let modAddr = cast[int](address) mod len(nes.cart.prgROM)
    result = nes.cart.prgROM[modAddr]

proc powerOn*(nes: NES) =
  nes.cpu.powerOn()
  nes.ppu.powerOn()
  nes.cart = loadCartridge("../smb.nes")
  let pc: uint16 = (cast[uint16](nes.cpuRead(0xFFFD)) shl 8) or cast[uint16](nes.cpuRead(0xFFFC))
  nes.cpu.pc = pc
  while true:
    echo("\n\n\nNew inst")
    echo("PC is: ", cast[int](nes.cpu.pc).toHex(4))
    let unmaskedOpcode = nes.cpuRead(nes.cpu.pc)

    #We need this initial unmasked opcode for decode
    nes.cpu.inst.opcode = unmaskedOpcode

    #CPU can't see system memory, so we set it from the console level
    #We set these bytes even if the instruction doesn't need it
    let loByte = nes.cpuRead(nes.cpu.pc + 1)
    let hiByte = nes.cpuRead(nes.cpu.pc + 2)

    #Step the PC
    nes.cpu.stepPC()

    #Decode the current opcode
    nes.cpu.decode()
    nes.cpu.inst.loByte = loByte
    nes.cpu.inst.hiByte = hiByte
    echo("Unmasked opcode is: 0x", cast[int](unmaskedOpcode).toHex(2))
    echo("Decoded opcode is: 0x", cast[int](nes.cpu.inst.opcode).toHex(2))

    if instructions.hasKey(nes.cpu.inst.opcode):
      let op = instructions[nes.cpu.inst.opcode]
      nes.op()



proc test*() =
  var n = new(NES)
  n.cpu = new(CPU)
  n.ppu = new(PPU)
  n.powerOn()
