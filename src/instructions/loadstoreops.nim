import ../console
import tables
import strutils

instructions[0xA0u8] =
  #LDY
  proc(n: NES) =
    echo("LDY, mode: ", n.cpu.inst.mode)
    n.cpu.y = getValue(n)
    n.cpu.setZN(n.cpu.y)
    echo("Stored value: ", cast[int](n.cpu.y).tohex(4))

instructions[0xA1u8] =
  #LDA
  proc(n: NES) =
    echo("LDA, mode: ", n.cpu.inst.mode)
    n.cpu.accumulator = getValue(n)
    n.cpu.setZN(n.cpu.accumulator)
    echo("Stored value: ", cast[int](n.cpu.accumulator).toHex(4))

instructions[0xA2u8] =
  #LDX
  proc(n: NES) =
    echo("LDX, mode: ", n.cpu.inst.mode)
    n.cpu.x = getValue(n)
    n.cpu.setZN(n.cpu.x)
    echo("LDX set register x to: ", cast[int](n.cpu.x).toHex(4))

instructions[0x80u8] =
  #STY
  proc(n: NES) =
    echo("STY, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.y)
    echo("Wrote to: ", cast[int](getAddr(n)).toHex(4))

instructions[0x81u8] =
  #STA
  proc(n: NES) =
    echo("STA, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.accumulator)
    echo("Wrote to: ", cast[int](getAddr(n)).toHex(4))

instructions[0x82u8] =
  #STX
  proc(n: NES) =
    echo("STX, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.x)
    echo("Wrote to: ", cast[int](getAddr(n)).toHex(4))

instructions[0x8Au8] =
  #TXA
  proc(n: NES) =
    echo("TXA, mode: ", n.cpu.inst.mode)
    n.cpu.accumulator = n.cpu.x
    n.cpu.setZN(n.cpu.accumulator)

instructions[0x9Au8] =
  #TXS
  proc(n: NES) =
    echo("TXS, mode: ", n.cpu.inst.mode)
    n.cpu.sp = n.cpu.x
