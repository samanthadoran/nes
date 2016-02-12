#Information mostly found from nesdev wiki
#http://wiki.nesdev.com/w/index.php/CPU

type
  #The 6502 has 13 addressing modes and stores them in 3 bits..fun
  addressingMode = enum
    #Non-indexed
    implicit,
    accumulator,
    immediate,
    zeroPage,
    absolute,
    relative,
    indirect,
    #Indexed
    zeroPageIndexedX,
    zeroPageIndexedY,
    absoluteIndexedX,
    absoluteIndexedY,
    indexedIndirect, #(d, x)
    indirectIndexed #(d), y

  instruction = object
    mode: addressingMode
    op: proc(c: CPU)
    hiByte: uint8
    loByte: uint8

  flags = object
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
  CPU = ref RP2a03
  RP2A03 = object
    memory: array[0x800, uint8]
    accumulator: uint8
    x, y: uint8
    pc: uint16
    sp: uint8
    status: flags
    opcode: uint8
    inst: instruction

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

proc determineAddressingMode(c: CPU, aaa: uint8, bbb: uint8, cc: uint8): addressingMode =
  #Reference: http://www.llx.com/~nparker/a2/opcodes.html
  #TODO: Special case ops that don't conform to these patterns
  result = case cc
    of 0:
      #If we have one of the branching instructions
      if c.opcode in {0x10u8, 0x30u8, 0x50u8, 0x70u8, 0x90u8, 0xB0u8, 0xD0u8, 0xF0u8}:
        addressingMode.relative
      #BRK, RTI, RTS: interrupt and subroutines
      elif c.opcode in {0x0u8, 0x40u8, 0x60u8}:
        addressingMode.implicit
      #JSR ABS: subroutine
      elif c.opcode == 0x20u8:
        addressingMode.absolute
      #Bunches of single byte instructions
      elif c.opcode in {0x08, 0x28, 0x48, 0x68, 0x88, 0xA8, 0xC8, 0xE8, 0x18,
                        0x38, 0x58, 0x78, 0x98, 0xB8, 0xD8, 0xF8}:
        addressingMode.implicit
      else:
        case bbb
        of 0:
          addressingMode.immediate
        of 1:
          addressingMode.zeroPage
        of 3:
          addressingMode.absolute
        of 5:
          addressingMode.zeroPageIndexedX
        of 7:
          addressingMode.absoluteIndexedX
        else:
          #This should never happen.
          #However, we need to put something here to make nim happy.
          #As such, implicit (meaning not to grab more bytes), makes most sense
          addressingMode.implicit
    of 1:
      case bbb
      of 0:
        addressingMode.indexedIndirect
      of 1:
        addressingMode.zeroPage
      of 2:
        addressingMode.immediate
      of 3:
        addressingMode.absolute
      of 4:
        addressingMode.indirectIndexed
      of 5:
        addressingMode.zeroPageIndexedX
      of 6:
        addressingMode.absoluteIndexedY
      of 7:
        addressingMode.absoluteIndexedX
      else:
        #This should never happen.
        addressingMode.implicit
    of 2:
      #More special cases...
      if c.opcode in {0x8A, 0x9A, 0xAA, 0xBA, 0xCA, 0xEA}:
        addressingMode.implicit
      else:
        case bbb
        of 0:
          addressingMode.immediate
        of 1:
          addressingMode.zeroPage
        of 2:
          addressingMode.accumulator
        of 3:
          addressingMode.absolute
        of 5:
          #STX: 100b and LDX: 101b become y instead of x indexed
          if aaa notin {4, 5}:
            addressingMode.zeroPageIndexedX
          else:
            addressingMode.zeroPageIndexedY
        of 7:
          #LDX: 101b becomes y instead of x indexed
          if aaa != 5:
            addressingMode.absoluteIndexedX
          else:
            addressingMode.absoluteIndexedY
        else:
          #Shouldn't happen.
          addressingMode.implicit
    else:
      #Shouldn't happen.
      addressingMode.implicit

#TODO: implement
proc fetch*(c: CPU) =
  #c.opcode = memory[c.pc]
  discard

#TODO: implement
proc decode*(c: CPU) =
  let cc = c.opcode and 0x03u8
  let bbb = (c.opcode shr 2u8) and 0x07u8
  let aaa = (c.opcode shr 5u8) and 0x07u8
  let mode: addressingMode = determineAddressingMode(c, aaa, bbb, cc)

#TODO: implement
proc execute*(c: CPU) =
  c.inst.op(c)
  discard
