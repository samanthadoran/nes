import ppuControlRegister, ppuMaskRegister

const screenWidth = 256u16
const screenHeight = 240u16
const cyclesPerScanline = 114u16
const vblankScanline = 241u16
const lastScanline = 261u16

type
  scrollDir* = enum
    xDir,
    yDir

  addrByte* = enum
    loByte,
    hiByte

  PPUStatus = object
    val: uint8

  PPUScroll = object
    x: uint8
    y: uint8
    next: scrollDir

  PPUAddr = object
    val: uint16
    next: addrByte

  PPU* = ref PPUObj

  VRAM = object
    nametables: array[0x400, uint8]
    pallet: array[0x20, uint8]

  PPUObj = object
    control: PPUCtrl
    mask: PPUMask
    status: PPUStatus
    oamaddr: uint8
    scroll: PPUScroll
    address: PPUAddr
    data: uint8

    scanline: uint16
    scroll_x: uint16
    scroll_y: uint16

    oddFrame*: bool
    cycle: uint64
    oam*: array[256, uint8]
    screen*: array[screenWidth * screenHeight, uint8]
    vram*: VRAM

proc readRegister*(p: PPU, index: uint8): uint8 =
  result =
    case index
      #Status
      of 2u8:
        p.status.val
      #OAM DATA
      of 4u8:
        p.oam[p.oamaddr]
      #PPUDATA
      of 7u8:
        p.data
      else:
        echo("We really shouldn't read from reg number: ", index)
        0u8

proc writeRegister*(p: PPU, index: uint8, value: uint8) =
  case index
  #Ctrl
  of 0u8:
    p.control.val = value
    p.scroll_x = (p.scroll_x and 0x00FF) or (p.control.xScrollOffset())
    p.scroll_y = (p.scroll_y and 0x00FF) or (p.control.yScrollOffset())
  #Mask
  of 1u8:
    p.mask.val = value
  #Status
  of 2u8:
    echo("We shouldn't write to ppu status")
  #oam ADDR
  of 3u8:
    p.oamaddr = value
  #oam data
  of 4u8:
    p.oam[p.oamaddr] = value
    inc(p.oamaddr)
  #ppu scroll
  of 5u8:
    if p.scroll.next == scrollDir.xDir:
      p.scroll_x = (p.scroll_x and 0xFF00) or (value)
      p.scroll.x = value
    else:
      p.scroll_y = (p.scroll_y and 0xFF00) or (value)
      p.scroll.y = value
    inc(p.scroll.next)
  #PPU addr
  of 6u8:
    if p.address.next == addrByte.loByte:
      p.address.val = p.address.val or value
    else:
      p.address.val = cast[uint16](value) shl 8
    inc(p.address.next)
  of 7u8:
    #TODO: Implement VRAM
    #p.vram[p.address.val] = value
    p.address.val += p.control.vramAddrInc()
    discard
  else:
    echo("Bad write, shouldn't happen")

proc reset*(p: PPU) =
  p.control.val = 0u8
  p.mask.val = 0u8
  p.scroll.x = 0u8
  p.scroll.y = 0u8
  p.data = 0u8
  p.oddFrame = false

proc powerOn*(p: PPU) =
  p.control.val = 0u8
  p.mask.val = 0u8
  #Status
  p.oamaddr = 0u8
  p.scroll.x = 0
  p.scroll.y = 0
  #2005/2006 latch is cleared
  p.address.val = 0u16
  p.data = 0u8
  p.oddFrame = false

proc step*(p: PPU) =
  discard
