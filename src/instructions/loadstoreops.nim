import ../console
import tables

instructions[0xA1u8] =
  #LDA
  proc(n: NES) =
    echo("LDA, mode: ", n.cpu.inst.mode)
    n.cpu.accumulator = getValue(n)
    n.cpu.setZN(n.cpu.accumulator)
    echo("Stored value: ", n.cpu.accumulator)

instructions[0xA2u8] =
  #LDX
  proc(n: NES) =
    echo("LDX, mode: ", n.cpu.inst.mode)
    n.cpu.x = getValue(n)
    n.cpu.setZN(n.cpu.x)
    echo("LDX set register x to: ", n.cpu.x)

instructions[0x80u8] =
  #STY
  proc(n: NES) =
    echo("STY, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.y)

instructions[0x81u8] =
  #STA
  proc(n: NES) =
    echo("STA, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.accumulator)

instructions[0x82u8] =
  #STX
  proc(n: NES) =
    echo("STX, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.x)

instructions[0x9Au8] =
  #TXS
  proc(n: NES) =
    echo("TXS, mode: ", n.cpu.inst.mode)
    n.cpu.sp = n.cpu.x
