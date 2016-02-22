import ../console
import tables

instructions[0x01u8] =
  #ORA
  proc(n: NES) =
    echo("ORA, mode: ", n.cpu.inst.mode)
    n.cpu.accumulator = n.cpu.accumulator or getValue(n)
    n.cpu.setZN(n.cpu.accumulator)

instructions[0x21u8] =
  #ANDA
  proc(n: NES) =
    echo("ANDA, mode: ", n.cpu.inst.mode)
    n.cpu.accumulator = n.cpu.accumulator and getValue(n)
    n.cpu.setZN(n.cpu.accumulator)

instructions[0x24u8] =
  #BIT zp
  proc(n: NES) =
    echo("BIT, mode: zp")
    let v = getValue(n) and n.cpu.accumulator
    n.cpu.setZN(v)

instructions[0x2Cu8] =
  #BIT ABS
  proc(n: NES) =
    echo("BIT, mode: abs")
    let v = getValue(n) and n.cpu.accumulator
    n.cpu.setZN(v)

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

instructions[0xC8u8] =
  #INY
  proc(n: NES) =
    echo("INY, mode: ", n.cpu.inst.mode)
    inc(n.cpu.y)
    n.cpu.setZN(n.cpu.y)

instructions[0xE0u8] =
  #CPX
  proc(n: NES) =
    echo("CPX, mode: ", n.cpu.inst.mode)
    let v = getValue(n)
    n.cpu.status.zero = v == n.cpu.x
    n.cpu.status.carry = n.cpu.x >= v
    echo("Was equal: ", n.cpu.status.zero)

instructions[0xE2u8] =
  #INC
  proc(n: NES) =
    echo("INC, mode: ", n.cpu.inst.mode)
    let val = getValue(n)
    n.cpuWrite(getAddr(n), val + 1)
