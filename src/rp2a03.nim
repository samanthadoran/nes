#Information mostly found from nesdev wiki
#http://wiki.nesdev.com/w/index.php/CPU

discard """
000	(zero page,X)
001	zero page
010	#immediate
011	absolute
100	(zero page),Y
101	zero page,X
110	absolute,Y
111	absolute,X
"""

type
  #The 6502 has 13 addressing modes and stores them in 3 bits..fun
  addressingMode = enum
    FILLTHISIN

  instruction = object
    mode: addressingMode
    op: proc(c: CPU)
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
  c.status.carry = false
  c.status.zero = false
  c.status.interrupt = true
  c.status.decimal = false
  c.status.bitFour = true
  #bit five: true
  c.status.overflow = false
  c.status.negative = false

  c.sp = 0xFDu8

  #$4017 = $00 (frame irq enabled)
  #$4015 = $00 (all channels disabled)
  #$4000-$400F = $00 (not sure about $4010-$4013)

#TODO: implement
proc fetch*(c: CPU) =
  c.opcode = 0x0u8
  discard

#TODO: implement
proc decode*(c: CPU) =
  discard
