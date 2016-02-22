import cpu, ppu, cartridge
export cpu, ppu, cartridge

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

proc getAddr*(nes: NES): uint16 =
  result =
    case nes.cpu.inst.mode
      of zeroPage:
        cast[uint16](nes.cpu.inst.loByte)
      of absolute:
        (cast[uint16](nes.cpu.inst.hiByte) shl 8) or cast[uint16](nes.cpu.inst.loByte)
      of relative:
        let offSet: int8 = cast[int8](nes.cpu.inst.loByte)
        cast[uint16](cast[int](nes.cpu.pc) + offSet)
      of indirect:
        let ptrAddr = (cast[uint16](nes.cpu.inst.hiByte) shl 8) or nes.cpu.inst.loByte
        (cast[uint16](nes.cpuRead(ptrAddr + 1)) shl 8) or nes.cpuRead(ptrAddr)
      of zeroPageIndexedX:
        cast[uint16](nes.cpu.inst.loByte + nes.cpu.x)
      of zeroPageIndexedY:
        cast[uint16](nes.cpu.inst.loByte + nes.cpu.y)
      of absoluteIndexedX:
        ((cast[uint16](nes.cpu.inst.hiByte) shl 8) or nes.cpu.inst.loByte) + nes.cpu.x
      of absoluteIndexedY:
        ((cast[uint16](nes.cpu.inst.hiByte) shl 8) or nes.cpu.inst.loByte) + cast[uint16](nes.cpu.y)
      of indexedIndirect:
        nes.cpuRead(nes.cpu.inst.loByte + nes.cpu.x)
      of indirectIndexed:
        nes.cpuRead(nes.cpu.inst.loByte) + nes.cpu.y
      else:
        echo("Bad get addr mode!")
        while true:
          discard
        0u16

proc getValue*(nes: NES): uint8 =
  result =
    case nes.cpu.inst.mode
    of immediate:
      nes.cpu.inst.loByte
    else:
      nes.cpuRead(getAddr(nes))

proc newNES*(): NES =
  result = new(NES)
  result.cpu = new(CPU)
  result.ppu = new(PPU)

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
    let regIndex = cast[uint8](address mod 8)
    writeRegister(nes.ppu, regIndex, value)
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
    let regIndex = cast[uint8](address mod 8)
    result = readRegister(nes.ppu, regIndex)
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

  discard """
  nes.ppu.vram =
    if nes.cart.chrROM == nil:
      VRAM(nametables: nes.cart.chrRAM[0..0x3FFF], pallet: nes.cart.chrRAM[0x400..0x41F])
    else:
      VRAM(nes.cart.chrROM, nes.cart.chrROM)
  """

proc emulate*(nes: NES) =
  let debug = false
  while true:
    echo("\nPC is: 0x", cast[int](nes.cpu.pc).toHex(4))
    let unmaskedOpcode = nes.cpuRead(nes.cpu.pc)

    #We need this initial unmasked opcode for decode
    nes.cpu.inst.opcode = unmaskedOpcode

    #CPU can't see system memory, so we set it from the console level
    #We set these bytes even if the instruction doesn't need it
    nes.cpu.inst.loByte = nes.cpuRead(nes.cpu.pc + 1)
    nes.cpu.inst.hiByte = nes.cpuRead(nes.cpu.pc + 2)

    #Decode the current opcode
    nes.cpu.decode()

    #Step the PC
    nes.cpu.stepPC()

    if instructions.hasKey(nes.cpu.inst.opcode):
      if debug:
        echo("The actual opcode here is: 0x", cast[int](unmaskedOpcode).toHex(2))
        echo("The decoded opcode is: 0x", cast[int](nes.cpu.inst.opcode).toHex(2))
      let op = instructions[nes.cpu.inst.opcode]
      nes.op()
    else:
      echo("Unimplemented opcode: 0x", cast[int](unmaskedOpcode).toHex(2))
      echo("Decoded as: 0x", cast[int](nes.cpu.inst.opcode).toHex(2))
      while true:
        discard
