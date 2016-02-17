type
  PPUMask* = object
    val*: uint8

proc showBackground*(p: PPUMask): bool =
  result = (p.val and 0x08) != 0

proc showSprites*(p: PPUMask): bool =
  result = (p.val and 0x10) != 0
