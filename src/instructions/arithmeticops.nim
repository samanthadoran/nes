import ../console
import tables

instructions[0x88u8] =
  #DEY
  proc(n: NES) =
    echo("DEY, mode: ", n.cpu.inst.mode)
    dec(n.cpu.y)
    n.cpu.setZN(n.cpu.y)

instructions[0xC1u8] =
  #CMP
  proc(n: NES) =
    echo("CMP, mode: ", n.cpu.inst.mode)
    let v = getValue(n)
    n.cpu.status.zero = v == n.cpu.accumulator
    n.cpu.status.carry = n.cpu.accumulator >= v
    echo("Was equal: ", n.cpu.status.zero)

instructions[0xCAu8] =
  #DEX
  proc(n: NES) =
    echo("DEX, mode: ", n.cpu.inst.mode)
    dec(n.cpu.x)
    n.cpu.setZN(n.cpu.x)

instructions[0xC0u8] =
  #CPY
  proc(n: NES) =
    echo("CPY, mode: ", n.cpu.inst.mode)
    let v = getValue(n)
    n.cpu.status.zero = v == n.cpu.y
    n.cpu.status.carry = n.cpu.y >= v
    echo("Was equal: ", n.cpu.status.zero)

instructions[0xE0u8] =
  #CPX
  proc(n: NES) =
    echo("CPX, mode: ", n.cpu.inst.mode)
    let v = getValue(n)
    n.cpu.status.zero = v == n.cpu.x
    n.cpu.status.carry = n.cpu.x >= v
    echo("Was equal: ", n.cpu.status.zero)
