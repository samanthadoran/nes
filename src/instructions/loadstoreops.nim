import ../console
import tables

instructions[0xA1u8] =
  #LDA
  proc(n: NES) =
    echo("LDA, mode: ", n.cpu.inst.mode)
    n.cpu.accumulator = getValue(n)
    n.cpu.status.negative =
      if n.cpu.accumulator > 127u8:
        true
      else:
        false
    echo("Stored value: ", n.cpu.accumulator)

instructions[0xA2u8] =
  #LDX
  proc(n: NES) =
    echo("LDX, mode: ", n.cpu.inst.mode)
    n.cpu.x = getValue(n)
    n.cpu.status.negative =
      if n.cpu.x > 127u8:
        true
      else:
        false
    echo("LDX set register x to: ", n.cpu.x)

instructions[0x81u8] =
  #STA
  proc(n: NES) =
    echo("STA, mode: ", n.cpu.inst.mode)
    n.cpuWrite(getAddr(n), n.cpu.accumulator)

instructions[0x9Au8] =
  #TXS
  proc(n: NES) =
    echo("TXS, mode: ", n.cpu.inst.mode)
    n.cpu.sp = n.cpu.x
