#Information mostly found from nesdev wiki
#http://wiki.nesdev.com/w/index.php/CPU
type
  #The 6502 has 13 addressing modes and stores them in 3 bits..fun
  addressingMode* = enum
    #Non-indexed
    implicit, #1 bytes
    accumulator, #1 bytes
    immediate, #3 bytes
    zeroPage, #2 bytes
    absolute, #3 bytes
    relative, #2 bytes
    indirect, #3 bytes
    #Indexed
    zeroPageIndexedX, #2 bytes
    zeroPageIndexedY, #2 bytes
    absoluteIndexedX, #3 bytes
    absoluteIndexedY, #3 bytes
    indexedIndirect, #(d, x) 2 bytes
    indirectIndexed #(d), y 2 bytes

  instruction* = object
    mode*: addressingMode
    opcode*: uint8
    hiByte*: uint8
    loByte*: uint8

  flags* = object
    #Last addition/shift resulted in a carry/subtraction with no borrow
    carry: bool

    #Last op resulted in zero?
    zero: bool

    #Interrupt inhibit
    interrupt: bool

    #BCD, ignored on RP2A03
    decimal: bool

    #True if from php/brk, 0 if from interrupt line
    bitFour: bool

    #bit five is ALWAYS true
    #s: true?

    #True if last adc/sbc sign overflow or D6 from last BIT
    overflow: bool

    #Bit 7 of last op
    negative: bool
  CPU* = ref RP2a03
  RP2A03 = object
    memory*: array[0x800, uint8]
    accumulator*: uint8
    x*, y*: uint8
    pc*: uint16
    sp*: uint8
    status*: flags
    inst*: instruction

proc reset*(c: CPU) =
  #A, X, Y, internal memory, APU mode in 4017: Unchanged
  c.sp -= 3
  c.status.interrupt = true
  #APU was silenced ($4015 = 0)

proc powerOn*(c: CPU) =
  #Status flags: 0x34 == 00110100b
  c.status.carry = false #bit 0
  c.status.zero = false #bit 1
  c.status.interrupt = true #bit 2
  c.status.decimal = false #bit 3
  c.status.bitFour = true # bit 4
  #bit five: true
  c.status.overflow = false #bit 6
  c.status.negative = false #bit 7

  c.sp = 0xFDu8

  #$4017 = $00 (frame irq enabled)
  #$4015 = $00 (all channels disabled)
  #$4000-$400F = $00 (not sure about $4010-$4013)

proc stepPC*(c: CPU) =
  c.pc =
    case c.inst.mode
      of implicit:
        c.pc + 1u16
      of accumulator:
        c.pc + 1u16
      of immediate:
        c.pc + 3u16
      of zeroPage:
        c.pc + 2u16
      of absolute:
        c.pc + 3u16
      of relative:
        c.pc + 2u16
      of indirect:
        c.pc + 3u16
      of zeroPageIndexedX:
        c.pc + 2u16
      of zeroPageIndexedY:
        c.pc + 2u16
      of absoluteIndexedX:
        c.pc + 3u16
      of absoluteIndexedY:
        c.pc + 3u16
      of indexedIndirect:
        c.pc + 2u16
      of indirectIndexed:
        c.pc + 2u16

proc initInstruction(c: CPU) =
  let cc: uint8 = c.inst.opcode and 0x03u8
  let bbb: uint8 = (c.inst.opcode shr 2u8) and 0x07u8
  let aaa: uint8 = (c.inst.opcode shr 5u8) and 0x07u8
  let maskedOp = c.inst.opcode and 0xe3u8
  c.inst = case cc
    of 0:
      #If we have one of the branching instructions
      if c.inst.opcode in {0x10u8, 0x30u8, 0x50u8, 0x70u8, 0x90u8, 0xB0u8, 0xD0u8, 0xF0u8}:
        instruction(mode: addressingMode.relative, opcode: c.inst.opcode, loByte: 0u8, hiByte: 0u8)
      #BRK, RTI, RTS: interrupt and subroutines
      elif c.inst.opcode in {0x0u8, 0x40u8, 0x60u8}:
        instruction(mode: addressingMode.implicit, opcode: c.inst.opcode, loByte: 0u8, hiByte: 0u8)
      #JSR ABS: subroutine
      elif c.inst.opcode == 0x20u8:
        instruction(mode: addressingMode.absolute, opcode: c.inst.opcode, loByte: 0u8, hiByte: 0u8)
      #Bunches of single byte instructions
      elif c.inst.opcode in {0x08, 0x28, 0x48, 0x68, 0x88, 0xA8, 0xC8, 0xE8, 0x18,
                        0x38, 0x58, 0x78, 0x98, 0xB8, 0xD8, 0xF8}:
        instruction(mode: implicit, opcode: c.inst.opcode, loByte: 0u8, hiByte: 0u8)
      else:
        case bbb
        of 0:
          instruction(mode: addressingMode.immediate, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 1:
          instruction(mode: addressingMode.zeroPage, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 3:
          instruction(mode: addressingMode.absolute, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 5:
          instruction(mode: addressingMode.zeroPageIndexedX, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 7:
          instruction(mode: addressingMode.absoluteIndexedX, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        else:
          #This should never happen.
          #However, we need to put something here to make nim happy.
          #As such, implicit (meaning not to grab more bytes), makes most sense
          echo("BAD OP: Got default case in: ", cc)
          instruction(mode: addressingMode.implicit, opcode: 0u8, loByte: 0u8, hiByte: 0u8)
    of 1:
      case bbb
      of 0:
        instruction(mode: addressingMode.indexedIndirect, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 1:
        instruction(mode: addressingMode.zeroPage, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 2:
        instruction(mode: addressingMode.immediate, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 3:
        instruction(mode: addressingMode.absolute, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 4:
        instruction(mode: addressingMode.indirectIndexed, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 5:
        instruction(mode: addressingMode.zeroPageIndexedX, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 6:
        instruction(mode: addressingMode.absoluteIndexedY, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      of 7:
        instruction(mode: addressingMode.absoluteIndexedX, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
      else:
        #This should never happen.
        echo("BAD OP: Got default case in: ", cc)
        instruction(mode: addressingMode.implicit, opcode: 0u8, loByte: 0u8, hiByte: 0u8)
    of 2:
      #More special cases...
      if c.inst.opcode in {0x8A, 0x9A, 0xAA, 0xBA, 0xCA, 0xEA}:
        instruction(mode: addressingMode.implicit, opcode: c.inst.opcode, loByte: 0u8, hiByte: 0u8)
      else:
        case bbb
        of 0:
          instruction(mode: addressingMode.immediate, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 1:
          instruction(mode: addressingMode.zeroPage, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 2:
          instruction(mode: addressingMode.accumulator, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 3:
          instruction(mode: addressingMode.absolute, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 5:
          #STX: 100b and LDX: 101b become y instead of x indexed
          if aaa notin {4, 5}:
            instruction(mode: addressingMode.zeroPageIndexedX, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
          else:
            instruction(mode: addressingMode.zeroPageIndexedY, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        of 7:
          #LDX: 101b becomes y instead of x indexed
          if aaa != 5:
            instruction(mode: addressingMode.absoluteIndexedX, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
          else:
            instruction(mode: addressingMode.absoluteIndexedY, opcode: maskedOp, loByte: 0u8, hiByte: 0u8)
        else:
          echo("BAD OP: Got default case in: ", cc)
          #Shouldn't happen.
          instruction(mode: addressingMode.implicit, opcode: 0u8, loByte: 0u8, hiByte: 0u8)
    else:
      #Shouldn't happen.
      echo("BAD OP: Got default case in outer switch")
      instruction(mode: addressingMode.zeroPage, opcode: 0u8, loByte: 0u8, hiByte: 0u8)


#TODO: implement
proc fetch*(c: CPU) =
  #c.inst.opcode = memory[c.pc]
  discard

#TODO: implement
proc decode*(c: CPU) =
  #TODO: Another switch off of AAAXXXCC, gross, but effective.
  c.initInstruction()

#TODO: implement
proc execute*(c: CPU) =
  #c.inst.op(c)
  discard
