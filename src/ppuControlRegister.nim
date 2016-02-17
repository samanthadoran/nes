type
  spriteSizes* = enum
    eightByEight,
    eightBySixteen

  PPUCtrl* = object
    val*: uint8

proc xScrollOffset*(p: PPUCtrl): uint16 =
  result =
    if (p.val and 0x01) == 0:
      0u16
    else:
      256u16

proc yScrollOffset*(p: PPUCtrl): uint16 =
  result =
    if (p.val and 0x02) == 0:
      0u16
    else:
      240u16

proc vramAddrInc*(p: PPUCtrl): uint16 =
  result =
    if (p.val and 0x04) == 0:
      1u16
    else:
      32u16

proc spriteSize*(p: PPUCtrl): spriteSizes =
  if (p.val and 0x20) == 0:
    spriteSizes.eightByEight
  else:
    spriteSizes.eightBySixteen

proc isVblankNMI*(ctrl: PPUCtrl): bool =
  result = (ctrl.val and 0x80u8) != 0u8
