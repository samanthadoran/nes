import console
import instructions/branchops, instructions/flagops, instructions/loadstoreops

proc test*() =
  var n = newNES()
  n.powerOn()
  n.emulate()

test()
