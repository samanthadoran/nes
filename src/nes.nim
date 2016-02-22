import console
import instructions/branchops, instructions/flagops, instructions/loadstoreops
import instructions/arithmeticops

proc test*() =
  var n = newNES()
  n.powerOn()
  n.emulate()

test()
