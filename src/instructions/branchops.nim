import ../console
import tables

instructions[0x20u8] =
  #JSR: Jump subroutine, absolute
  proc(n: NES) =
    #6502 uses empty stack approach, store then move
    let stackAddress = 0x0100u16 or n.cpu.sp
    #Write it little endian style
    #High byte
    n.cpuWrite(stackAddress, cast[uint8](n.cpu.pc shr 8))
    #Low byte
    n.cpuWrite(stackAddress - 1, cast[uint8](n.cpu.pc))
    #Move the stack pointer
    n.cpu.sp -= 2u8
    #Move the PC to where specified
    n.cpu.pc = (cast[uint16](n.cpu.inst.hiByte) shl 8) or cast[uint16](n.cpu.inst.loByte)
