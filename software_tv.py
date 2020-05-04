import helpers
import sys
sys.setrecursionlimit(1500)

operation = 0
seed = "random"

print "===================================================================="
print "TEST VECTOR GENERATOR FOR DDP SW SESSIONS"

if len(sys.argv) == 3:
  print "--> Seed is ", sys.argv[2]
  seed = sys.argv[2]
  helpers.setSeed(sys.argv[2])
else:
  print "--> No seed specified"

if len(sys.argv) == 2 or len(sys.argv) == 3:
  if str(sys.argv[1]) == "add":         operation = 1;
  if str(sys.argv[1]) == "sub":         operation = 2;
  if str(sys.argv[1]) == "mod_add":     operation = 3;
  if str(sys.argv[1]) == "mod_sub":     operation = 4;
  if str(sys.argv[1]) == "mul":         operation = 5;
  if str(sys.argv[1]) == "mont_mul":    operation = 6;

print "===================================================================="

#####################################################

if operation == 0:
  print "You should use this script by passing an argument like:"
  print " $ python software_tv.py add"
  print " $ python software_tv.py sub"
  print " $ python software_tv.py mod_add"
  print " $ python software_tv.py mod_sub"
  print " $ python software_tv.py mul"
  print " $ python software_tv.py mont_mul"
  print ""
  print "You can also set a seed for randomness to work"
  print "with the same software_tv at each execution:"
  print " $ python software_tv.py add 1"
  print ""

#####################################################

if operation == 1:
  print "Test Vector for Multi Precision Addition\n"

  a = helpers.getRandomInt(1024)
  b = helpers.getRandomInt(1024)
  c = a + b

  print "a                = ", hex(a).rstrip("L")          # 1024-bits
  print "b                = ", hex(b).rstrip("L")          # 1024-bits
  print "a + b            = ", hex(c).rstrip("L")          # 1024-bits
  
  print "===================================================================="
  print "Input variable declaration in C language\n"
  
  print "uint32_t a[32]   = {", helpers.WriteConstants(a), "};"    # 1024-bits
  print "uint32_t b[32]   = {", helpers.WriteConstants(b), "};"    # 1024-bits
  
  print "===================================================================="

#####################################################

if operation == 2:
  print "Test Vector for Multi Precision Subtraction\n"

  a = helpers.getRandomInt(1024)
  b = helpers.getRandomMessage(1024,a)
  c = a - b

  print "a                = ", hex(a).rstrip("L")           # 1024-bits
  print "b                = ", hex(b).rstrip("L")           # 1024-bits
  print "a - b            = ", hex(c).rstrip("L")           # 1024-bits
  
  print "===================================================================="
  print "Input variable declaration in C language\n"
  
  print "uint32_t a[32]   = {", helpers.WriteConstants(a), "};"    # 1024-bits
  print "uint32_t b[32]   = {", helpers.WriteConstants(b), "};"    # 1024-bits
  
  print "===================================================================="

#####################################################

if operation == 3:
  print "Test Vector for Multi Precision Modular Addition\n"
  
  [p,q,n] = helpers.getModuli(512)

  a = helpers.getRandomMessage(1024,n)
  b = helpers.getRandomMessage(1024,n)
  c = (a + b) % n

  print "a                = ", hex(a).rstrip("L")           # 1024-bits
  print "b                = ", hex(b).rstrip("L")           # 1024-bits
  print "n                = ", hex(n).rstrip("L")          # 1024-bits
  print "(a + b) mod n    = ", hex(c).rstrip("L")           # 1024-bits
  
  print "===================================================================="
  print "Input variable declaration in C language\n"
  
  print "uint32_t a[32]   = {", helpers.WriteConstants(a), "};"    # 1024-bits
  print "uint32_t b[32]   = {", helpers.WriteConstants(b), "};"    # 1024-bits
  print "uint32_t n[32]   = {", helpers.WriteConstants(n), "};"    # 1024-bits
  
  print "===================================================================="
  
#####################################################

if operation == 4:

  print "Test Vector for Multi Precision Modular Subtraction\n"
  
  [p,q,n] = helpers.getModuli(512)

  a = helpers.getRandomMessage(1024,n)
  b = helpers.getRandomMessage(1024,n)
  c = (a - b) % n

  print "a                = ", hex(a).rstrip("L")           # 1024-bits
  print "b                = ", hex(b).rstrip("L")           # 1024-bits
  print "n                = ", hex(n).rstrip("L")          # 1024-bits
  print "(a - b) mod n    = ", hex(c).rstrip("L")           # 1024-bits
  
  print "===================================================================="
  print "Input variable declaration in C language\n"
  
  print "uint32_t a[32]   = {", helpers.WriteConstants(a), "};"    # 1024-bits
  print "uint32_t b[32]   = {", helpers.WriteConstants(b), "};"    # 1024-bits
  print "uint32_t n[32]   = {", helpers.WriteConstants(n), "};"    # 1024-bits
  
  print "===================================================================="

#####################################################

if operation == 5:

  print "Test Vector for Multi Precision Multiplication\n"

  a = helpers.getRandomInt(1024)
  b = helpers.getRandomInt(1024)
  c = a * b

  print "a                = ", hex(a).rstrip("L")           # 1024-bits
  print "b                = ", hex(b).rstrip("L")           # 1024-bits
  print "a * b            = ", hex(c).rstrip("L")           # 1024-bits
  
  print "===================================================================="
  print "Input variable declaration in C language\n"
  
  print "uint32_t a[32]   = {", helpers.WriteConstants(a), "};"    # 1024-bits
  print "uint32_t b[32]   = {", helpers.WriteConstants(b), "};"    # 1024-bits
  
  print "===================================================================="

#####################################################

if operation == 6:

  print "Test Vector for Multi Precision Montgomery Multiplication\n"

  [p,q,n] = helpers.getModuli(512)
  
  r = 2**1024  
  n_prime = helpers.Modinv(r, n)

  a = helpers.getRandomMessage(1024,n)
  b = helpers.getRandomMessage(1024,n)
  c = (a * b * n_prime) % n

  print "a                      = ", hex(a).rstrip("L")           # 1024-bits
  print "b                      = ", hex(b).rstrip("L")           # 1024-bits
  print "n                      = ", hex(n).rstrip("L")           # 1024-bits
  print "n_prime                = ", hex(n_prime).rstrip("L")       # 1024-bits
  print "(a * b * n_prime) % n  = ", hex(c).rstrip("L")           # 1024-bits
  
  print "===================================================================="
  print "Input variable declaration in C language\n"
  
  print "uint32_t a[32]         = {", helpers.WriteConstants(a), "};"    # 1024-bits
  print "uint32_t b[32]         = {", helpers.WriteConstants(b), "};"    # 1024-bits
  print "uint32_t n[32]         = {", helpers.WriteConstants(n), "};"    # 1024-bits
  print "uint32_t n_prime[32]   = {", helpers.WriteConstants(n_prime), "};"    # 1024-bits
  
  print "===================================================================="
