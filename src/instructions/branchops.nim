import ../console
import tables

instructions[0x20u8] =
  #JSR: Jump subroutine, absolute
  proc(n: NES) =
    echo("JSR, mode: ", n.cpu.inst.mode)
    n.cpu.push16(n.cpu.pc)
    #Move the PC to where specified
    n.cpu.pc = (cast[uint16](n.cpu.inst.hiByte) shl 8) or cast[uint16](n.cpu.inst.loByte)

instructions[0x60u8] =
  #RTS
  proc(n: NES) =
    echo("RTS, mode: ", n.cpu.inst.mode)
    n.cpu.pc = n.cpu.pull16()

instructions[0x6Cu8] =
  #JMP Indirect, make sure to emulate 6502 bug on page boundaries
  proc(n: NES) =
    echo("JMP, mode: ", n.cpu.inst.mode)
    #We are going to cross the page boundary!
    if (n.cpu.inst.loByte and 0xFF) == 0xFF:
      let buggy = (cast[uint16](n.cpu.inst.hiByte) shl 8) or n.cpu.inst.loByte
      let loBuggy = n.cpuRead(buggy)
      let hiBuggy = n.cpuRead(buggy and 0xFF00)
      let combinedBugggy = (cast[uint16](hiBuggy) shl 8) or loBuggy
      n.cpu.pc = n.cpuRead(combinedBugggy)
    else:
      n.cpu.pc = getAddr(n)

instructions[0x10u8] =
  #BPL
  proc(n: NES) =
    echo("BPL, mode: ", n.cpu.inst.mode)
    echo("Offset is: ", cast[int8](n.cpu.inst.loByte))
    if not n.cpu.status.negative:
      echo("Branching...")
      n.cpu.pc = getAddr(n)

instructions[0xB0u8] =
  #BCS
  proc(n: NES) =
    echo("BCS, mode: ", n.cpu.inst.mode)
    echo("Offset is: ", cast[int8](n.cpu.inst.loByte))
    if n.cpu.status.carry:
      echo("Branching...")
      n.cpu.pc = getAddr(n)

instructions[0xD0u8] =
  #BNE
  proc(n: NES) =
    echo("BNE, mode: ", n.cpu.inst.mode)
    echo("Offset is: ", cast[int8](n.cpu.inst.loByte))
    if n.cpu.status.zero:
      echo("Branching...")
      n.cpu.pc = getAddr(n)
