# --- Day 19: Go With The Flow ---
#
# With the Elves well on their way constructing the North Pole base,
# you turn your attention back to understanding the inner workings of
# programming the device.
#
# You can't help but notice that the device's opcodes don't contain
# any flow control like jump instructions.  The device's manual goes
# on to explain:
#
# "In programs where flow control is required, the instruction pointer
# can be bound to a register so that it can be manipulated directly.
# This way, setr/seti can function as absolute jumps, addr/addi can
# function as relative jumps, and other opcodes can cause truly
# fascinating effects."
#
# This mechanism is achieved through a declaration like #ip 1, which
# would modify register 1 so that accesses to it let the program
# indirectly access the instruction pointer itself.  To compensate for
# this kind of binding, there are now six registers (numbered 0
# through 5); the five not bound to the instruction pointer behave as
# normal.  Otherwise, the same rules apply as the last time you worked
# with this device (day 16).
#
# When the instruction pointer is bound to a register, its value is
# written to that register just before each instruction is executed,
# and the value of that register is written back to the instruction
# pointer immediately after each instruction finishes execution.
# Afterward, move to the next instruction by adding one to the
# instruction pointer, even if the value in the instruction pointer
# was just updated by an instruction.  (Because of this, instructions
# must effectively set the instruction pointer to the instruction
# before the one they want executed next.)
#
# The instruction pointer is 0 during the first instruction, 1 during
# the second, and so on.  If the instruction pointer ever causes the
# device to attempt to load an instruction outside the instructions
# defined in the program, the program instead immediately halts.  The
# instruction pointer starts at 0.
#
# It turns out that this new information is already proving useful:
# the CPU in the device is not very powerful, and a background process
# is occupying most of its time.  You dump the background process's
# declarations and instructions to a file (your puzzle input), making
# sure to use the names of the opcodes rather than the numbers.
#
# For example, suppose you have the following program:
#
# #ip 0
# seti 5 0 1
# seti 6 0 2
# addi 0 1 0
# addr 1 2 3
# setr 1 0 0
# seti 8 0 4
# seti 9 0 5
#
# When executed, the following instructions are executed.  Each line
# contains the value of the instruction pointer at the time the
# instruction started, the values of the six registers before
# executing the instructions (in square brackets), the instruction
# itself, and the values of the six registers after executing the
# instruction (also in square brackets).
#
# ip=0 [0, 0, 0, 0, 0, 0] seti 5 0 1 [0, 5, 0, 0, 0, 0]
# ip=1 [1, 5, 0, 0, 0, 0] seti 6 0 2 [1, 5, 6, 0, 0, 0]
# ip=2 [2, 5, 6, 0, 0, 0] addi 0 1 0 [3, 5, 6, 0, 0, 0]
# ip=4 [4, 5, 6, 0, 0, 0] setr 1 0 0 [5, 5, 6, 0, 0, 0]
# ip=6 [6, 5, 6, 0, 0, 0] seti 9 0 5 [6, 5, 6, 0, 0, 9]
#
# In detail, when running this program, the following events occur:
#
# - The first line (#ip 0) indicates that the instruction pointer
#   should be bound to register 0 in this program.  This is not an
#   instruction, and so the value of the instruction pointer does not
#   change during the processing of this line.
# - The instruction pointer contains 0, and so the first instruction
#   is executed (seti 5 0 1).  It updates register 0 to the current
#   instruction pointer value (0), sets register 1 to 5, sets the
#   instruction pointer to the value of register 0 (which has no
#   effect, as the instruction did not modify register 0), and then
#   adds one to the instruction pointer.
# - The instruction pointer contains 1, and so the second instruction,
#   seti 6 0 2, is executed.  This is very similar to the instruction
#   before it: 6 is stored in register 2, and the instruction pointer
#   is left with the value 2.
# - The instruction pointer is 2, which points at the instruction
#   addi 0 1 0.  This is like a relative jump: the value of the
#   instruction pointer, 2, is loaded into register 0.  Then, addi
#   finds the result of adding the value in register 0 and the value
#   1, storing the result, 3, back in register 0.  Register 0 is then
#   copied back to the instruction pointer, which will cause it to end
#   up 1 larger than it would have otherwise and skip the next
#   instruction (addr 1 2 3) entirely.  Finally, 1 is added to the
#   instruction pointer.
# - The instruction pointer is 4, so the instruction setr 1 0 0 is
#   run.  This is like an absolute jump: it copies the value contained
#   in register 1, 5, into register 0, which causes it to end up in
#   the instruction pointer.  The instruction pointer is then
#   incremented, leaving it at 6.
# - The instruction pointer is 6, so the instruction seti 9 0 5 stores
#   9 into register 5.  The instruction pointer is incremented,
#   causing it to point outside the program, and so the program ends.
#
# What value is left in register 0 when the background process halts?

Functions = {
  "addr" => lambda {|a,b,c,r| r[c] = r[a]+r[b] },
  "addi" => lambda {|a,b,c,r| r[c] = r[a]+b },
  "mulr" => lambda {|a,b,c,r| r[c] = r[a]*r[b] },
  "muli" => lambda {|a,b,c,r| r[c] = r[a]*b },
  "banr" => lambda {|a,b,c,r| r[c] = r[a]&r[b] },
  "bani" => lambda {|a,b,c,r| r[c] = r[a]&b },
  "borr" => lambda {|a,b,c,r| r[c] = r[a]|r[b] },
  "bori" => lambda {|a,b,c,r| r[c] = r[a]|b },
  "setr" => lambda {|a,b,c,r| r[c] = r[a] },
  "seti" => lambda {|a,b,c,r| r[c] = a },
  "gtir" => lambda {|a,b,c,r| r[c] = a > r[b] ? 1 : 0 },
  "gtri" => lambda {|a,b,c,r| r[c] = r[a] > b ? 1 : 0 },
  "gtrr" => lambda {|a,b,c,r| r[c] = r[a] > r[b] ? 1 : 0 },
  "eqir" => lambda {|a,b,c,r| r[c] = a == r[b] ? 1 : 0 },
  "eqri" => lambda {|a,b,c,r| r[c] = r[a] == b ? 1 : 0 },
  "eqrr" => lambda {|a,b,c,r| r[c] = r[a] == r[b] ? 1 : 0 }
}

open("19.in") do |f|
  IP = f.readline.match(/\d+/)[0].to_i
  Program = f.readlines.map {|l|
    m = /([a-z]+) (\d+) (\d+) (\d+)/.match(l)
    [m[1], m[2].to_i, m[3].to_i, m[4].to_i]
  }
end

r = [0]*6
while r[IP] >= 0 && r[IP] < Program.length
  i = Program[r[IP]]
  Functions[i[0]].call(i[1], i[2], i[3], r)
  r[IP] += 1
end
puts r[0]

# --- Part Two ---
#
# A new background process immediately spins up in its place.  It
# appears identical, but on closer inspection, you notice that this
# time, register 0 started with the value 1.
#
# What value is left in register 0 when this new background process
# halts?
#
# --------------------
#
# The program runs seemingly forever, so reverse engineering is
# required to understand what the program is doing so that we can then
# optimize it.  On the left below is a direct translation into modern
# programming syntax, on the right a simplification of the same.  In
# simplifying, a few observations:
#
# - Register r1 is used only as a temporary variable.
# - Instructions 17-35 are executed only once, at the beginning of the
#   program.  In this section r2 is set and never modified again, and
#   r0 is initialized to 0 regardless of which path is taken.
# - Instructions 1-16 implement a double loop with r2 acting as an
#   upper bound.
# - If r0 is 1, r2 is much larger, which explains why the program runs
#   so long.
#
#  0 | IP = IP + 16          | GOTO 17
#  1 | r4 = 1                | r4 = 1
#  2 | r3 = 1                | r3 = 1
#  3 | r1 = r4 * r3          | .
#  4 | r1 = r1 == r2 ? 1 : 0 | r0 += r4 if r4*r3 == r2
#  5 | IP = r1 + IP          | .
#  6 | IP = IP + 1           | .
#  7 | r0 = r4 + r0          | .
#  8 | r3 = r3 + 1           | r3 += 1
#  9 | r1 = r3 > r2 ? 1 : 0  | GOTO 3 if r3 <= r2
# 10 | IP = IP + r1          | .
# 11 | IP = 2                | .
# 12 | r4 = r4 + 1           | r4 += 1
# 13 | r1 = r4 > r2 ? 1 : 0  | GOTO 2 if r4 <= r2
# 14 | IP = r1 + IP          | .
# 15 | IP = 1                | .
# 16 | IP = IP * IP          | HALT
# 17 | r2 = r2 + 2           | r2 = 2*2*19*11+8*22+18
# 18 | r2 = r2 * r2          | .
# 19 | r2 = IP * r2          | .
# 20 | r2 = r2 * 11          | .
# 21 | r1 = r1 + 8           | .
# 22 | r1 = r1 * IP          | .
# 23 | r1 = r1 + 18          | .
# 24 | r2 = r2 + r1          | .
# 25 | IP = IP + r0          | GOTO 1 if r0 == 0
# 26 | IP = 0                | .
# 27 | r1 = IP               | r2 += (27*28+29)*30*14*32
# 28 | r1 = r1 * IP          | .
# 29 | r1 = IP + r1          | .
# 30 | r1 = IP * r1          | .
# 31 | r1 = r1 * 14          | .
# 32 | r1 = r1 * IP          | .
# 33 | r2 = r2 + r1          | .
# 34 | r0 = 0                | r0 = 0
# 35 | IP = 0                | GOTO 1
#
# The program translated into Ruby:
#
# r2 = 1030
# if r0 == 1
#   r2 += 10550400
#   r0 = 0
# end
# r4 = 1
# while r4 <= r2
#   r3 = 1
#   while r3 <= r2
#     r0 += r4 if r4*r3 == r2
#     r3 += 1
#   end
#   r4 += 1
# end
#
# So the program is computing the sum of the divisors of 10551430.  We
# could of course compute this quantity offline and simply print the
# answer, but the code below computes the divisor sum of any positive
# integer.

require 'prime'

f = 10551430.prime_division
puts f
  .map {|p,e| (0..e).to_a }     # for each exponent, range of possible values
  .reduce {|a,l| a.product(l) } # cartesian product of ranges
  .map {|l| l.flatten }
  .map {|l| f.map(&:first)      # the primes
             .zip(l)            # pair with specific exponent values
             .map {|p,e| p**e } # compute the divisor that results
             .reduce(:*)
       }
  .reduce(:+)                   # and sum
