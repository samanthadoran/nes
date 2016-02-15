import ../console
import tables

instructions[0x78u8] =
  #SEI
  proc(n: NES) =
    echo("SEI, mode: ", n.cpu.inst.mode)
    n.cpu.status.interrupt = true

instructions[0xD8u8] =
  #CLD
  proc(n: NES) =
    echo("CLD, mode: ", n.cpu.inst.mode)
    n.cpu.status.decimal = false
