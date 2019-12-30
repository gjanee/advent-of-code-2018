# --- Day 21: Chronal Conversion ---
#
# You should have been watching where you were going, because as you
# wander the new North Pole base, you trip and fall into a very deep
# hole!
#
# Just kidding.  You're falling through time again.
#
# If you keep up your current pace, you should have resolved all of
# the temporal anomalies by the next time the device activates.  Since
# you have very little interest in browsing history in 500-year
# increments for the rest of your life, you need to find a way to get
# back to your present time.
#
# After a little research, you discover two important facts about the
# behavior of the device:
#
# First, you discover that the device is hard-wired to always send you
# back in time in 500-year increments.  Changing this is probably not
# feasible.
#
# Second, you discover the activation system (your puzzle input) for
# the time travel module.  Currently, it appears to run forever
# without halting.
#
# If you can cause the activation system to halt at a specific moment,
# maybe you can make the device send you so far back in time that you
# cause an integer underflow in time itself and wrap around back to
# your current time!
#
# The device executes the program as specified in manual section one
# [day 16] and manual section two [day 19].
#
# Your goal is to figure out how the program works and cause it to
# halt.  You can only control register 0; every other register begins
# at 0 as usual.
#
# Because time travel is a dangerous activity, the activation system
# begins with a few instructions which verify that bitwise AND (via
# bani) does a numeric operation and not an operation as if the inputs
# were interpreted as strings.  If the test fails, it enters an
# infinite loop re-running the test instead of allowing the program to
# execute normally.  If the test passes, the program continues, and
# assumes that all other bitwise operations (banr, bori, and borr)
# also interpret their inputs as numbers.  (Clearly, the Elves who
# wrote this system were worried that someone might introduce a bug
# while trying to emulate this system with a scripting language.)
#
# What is the lowest non-negative integer value for register 0 that
# causes the program to halt after executing the fewest instructions?
# (Executing the same instruction multiple times counts as multiple
# instructions executed.)
#
# --------------------
#
# Analysis of the program reveals that register 0 is referenced in
# exactly one place: at instruction 28, if register 5 equals
# register 0 the program halts.  We run the program and stop at that
# instruction to discover the first value that register 5 takes on.

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

open("21.in") do |f|
  IP = f.readline.match(/\d+/)[0].to_i
  Program = f.readlines.map {|l|
    m = /([a-z]+) (\d+) (\d+) (\d+)/.match(l)
    [m[1], m[2].to_i, m[3].to_i, m[4].to_i]
  }
end

def run(&block)
  # halts early if the block returns true at instruction 28
  r = [0]*6
  while r[IP] >= 0 && r[IP] < Program.length
    i = Program[r[IP]]
    if r[IP] == 28
      break if yield(r[5])
    end
    Functions[i[0]].call(i[1], i[2], i[3], r)
    r[IP] += 1
  end
end

first_value = nil
run {|v| first_value = v; true }
puts first_value

# --- Part Two ---
#
# In order to determine the timing window for your underflow exploit,
# you also need an upper bound:
#
# What is the lowest non-negative integer value for register 0 that
# causes the program to halt after executing the most instructions?
# (The program must actually halt; running forever does not count as
# halting.)
#
# --------------------
#
# As in day 19, we reverse engineer the program to understand it, and
# arrive at this Ruby equivalent:
#
# while true
#   r4 = r5 | 0x10000
#   r5 = 3935295
#   while r4 > 0 # always executed exactly 3 times
#     r5 += r4 & 0xff
#     r5 &= 0xffffff
#     r5 *= 65899
#     r5 &= 0xffffff
#     r4 /= 256
#   end
#   break if r5 == r0 # instruction 28
# end
#
# The program is essentially a random number generator, producing
# 24-bit integers in register 5, and as such must repeat.  Choosing a
# value for register 0 not among those generated will cause the
# program to run forever.  Choosing the last value generated before
# the generator starts repeating yields the longest possible finite
# execution time.
#
# We could reuse the run function above, but for efficiency redefine
# it to use our Ruby version.

def run(&block)
  # halts when the block returns true at instruction 28
  r4 = r5 = 0
  while true
    r4 = r5 | 0x10000
    r5 = 3935295
    while r4 > 0
      r5 += r4 & 0xff
      r5 &= 0xffffff
      r5 *= 65899
      r5 &= 0xffffff
      r4 /= 256
    end
    break if yield(r5)
  end
end

seen = []
run {|v|
  if seen.member?(v)
    true
  else
    seen << v
    false
  end
}
puts seen[-1]
