# --- Day 17: Reservoir Research ---
#
# You arrive in the year 18.  If it weren't for the coat you got in
# 1018, you would be very cold: the North Pole base hasn't even been
# constructed.
#
# Rather, it hasn't been constructed yet.  The Elves are making a
# little progress, but there's not a lot of liquid water in this
# climate, so they're getting very dehydrated.  Maybe there's more
# underground?
#
# You scan a two-dimensional vertical slice of the ground nearby and
# discover that it is mostly sand with veins of clay.  The scan only
# provides data with a granularity of square meters, but it should be
# good enough to determine how much water is trapped there.  In the
# scan, x represents the distance to the right, and y represents the
# distance down.  There is also a spring of water near the surface at
# x=500, y=0.  The scan identifies which square meters are clay (your
# puzzle input).
#
# For example, suppose your scan shows the following veins of clay:
#
# x=495, y=2..7
# y=7, x=495..501
# x=501, y=3..7
# x=498, y=2..4
# x=506, y=1..2
# x=498, y=10..13
# x=504, y=10..13
# y=13, x=498..504
#
# Rendering clay as #, sand as ., and the water spring as +, and with
# x increasing to the right and y increasing downward, this becomes:
#
#    44444455555555
#    99999900000000
#    45678901234567
#  0 ......+.......
#  1 ............#.
#  2 .#..#.......#.
#  3 .#..#..#......
#  4 .#..#..#......
#  5 .#.....#......
#  6 .#.....#......
#  7 .#######......
#  8 ..............
#  9 ..............
# 10 ....#.....#...
# 11 ....#.....#...
# 12 ....#.....#...
# 13 ....#######...
#
# The spring of water will produce water forever.  Water can move
# through sand, but is blocked by clay.  Water always moves down when
# possible, and spreads to the left and right otherwise, filling space
# that has clay on both sides and falling out otherwise.
#
# For example, if five squares of water are created, they will flow
# downward until they reach the clay and settle there.  Water that has
# come to rest is shown here as ~, while sand through which water has
# passed (but which is now dry again) is shown as |:
#
# ......+.......
# ......|.....#.
# .#..#.|.....#.
# .#..#.|#......
# .#..#.|#......
# .#....|#......
# .#~~~~~#......
# .#######......
# ..............
# ..............
# ....#.....#...
# ....#.....#...
# ....#.....#...
# ....#######...
#
# Two squares of water can't occupy the same location.  If another
# five squares of water are created, they will settle on the first
# five, filling the clay reservoir a little more:
#
# ......+.......
# ......|.....#.
# .#..#.|.....#.
# .#..#.|#......
# .#..#.|#......
# .#~~~~~#......
# .#~~~~~#......
# .#######......
# ..............
# ..............
# ....#.....#...
# ....#.....#...
# ....#.....#...
# ....#######...
#
# Water pressure does not apply in this scenario.  If another four
# squares of water are created, they will stay on the right side of
# the barrier, and no water will reach the left side:
#
# ......+.......
# ......|.....#.
# .#..#.|.....#.
# .#..#~~#......
# .#..#~~#......
# .#~~~~~#......
# .#~~~~~#......
# .#######......
# ..............
# ..............
# ....#.....#...
# ....#.....#...
# ....#.....#...
# ....#######...
#
# At this point, the top reservoir overflows.  While water can reach
# the tiles above the surface of the water, it cannot settle there,
# and so the next five squares of water settle like this:
#
# ......+.......
# ......|.....#.
# .#..#||||...#.
# .#..#~~#|.....
# .#..#~~#|.....
# .#~~~~~#|.....
# .#~~~~~#|.....
# .#######|.....
# ........|.....
# ........|.....
# ....#...|.#...
# ....#...|.#...
# ....#~~~~~#...
# ....#######...
#
# Note especially the leftmost |: the new squares of water can reach
# this tile, but cannot stop there. Instead, eventually, they all fall
# to the right and settle in the reservoir below.
#
# After 10 more squares of water, the bottom reservoir is also full:
#
# ......+.......
# ......|.....#.
# .#..#||||...#.
# .#..#~~#|.....
# .#..#~~#|.....
# .#~~~~~#|.....
# .#~~~~~#|.....
# .#######|.....
# ........|.....
# ........|.....
# ....#~~~~~#...
# ....#~~~~~#...
# ....#~~~~~#...
# ....#######...
#
# Finally, while there is nowhere left for the water to settle, it can
# reach a few more tiles before overflowing beyond the bottom of the
# scanned data:
#
# ......+.......    (line not counted: above minimum y value)
# ......|.....#.
# .#..#||||...#.
# .#..#~~#|.....
# .#..#~~#|.....
# .#~~~~~#|.....
# .#~~~~~#|.....
# .#######|.....
# ........|.....
# ...|||||||||..
# ...|#~~~~~#|..
# ...|#~~~~~#|..
# ...|#~~~~~#|..
# ...|#######|..
# ...|.......|..    (line not counted: below maximum y value)
# ...|.......|..    (line not counted: below maximum y value)
# ...|.......|..    (line not counted: below maximum y value)
#
# How many tiles can be reached by the water?  To prevent counting
# forever, ignore tiles with a y coordinate smaller than the smallest
# y coordinate in your scan data or larger than the largest one.  Any
# x coordinate is valid.  In this example, the lowest y coordinate
# given is 1, and the highest is 13, causing the water spring (in row
# 0) and the water falling off the bottom of the render (in rows 14
# through infinity) to be ignored.
#
# So, in the example above, counting both water at rest (~) and other
# sand tiles the water can hypothetically reach (|), the total number
# of tiles the water can reach is 57.
#
# How many tiles can the water reach within the range of y values in
# your scan?
#
# --------------------
#
# The recursive traversal below mimics the flow of water.  We descend
# depth first as far as possible; then, while backtracking back up, at
# each level spread water horizontally as far as possible.  New
# falloffs trigger new descents.  There are some subtle cases that
# occur in the input.  Consider:
#
#      v
# ............
# .#........#.
# .#..#.#...#.
# .#..###...#.
# .#........#.
# .##########.
# ............
#
# After water fills the inner chamber it flows over the sides.  But
# such water does not remain flowing; it turns to water at rest as the
# outer chamber fills.

S, C, W, F = 0, 1, 2, 3 # sand, clay, water at rest, flowing water

$g = Hash.new(S) # [x,y] => SCWF
open("17.in").each do |l|
  m = /^([xy])=(\d+), ([xy])=(\d+\.\.\d+)$/.match(l)
  eval "(#{m[2]}..#{m[2]}).each {|#{m[1]}|
          (#{m[4]}).each {|#{m[3]}| $g[[x,y]] = C }
        }"
end
Yrange = Range.new(*$g.keys.map(&:last).minmax)

def flow_across(x, y, dir)
  # Walk horizontally starting from [x,y] in direction dir, stopping
  # when either a falloff allowing water to descend further is
  # encountered, or clay is encountered.  The return is
  # [ending x, true if clay encountered].
  while true
    if $g[[x,y]] == C
      return [x-dir, true]
    else
      if $g[[x,y+1]] == S
        flow_down(x, y+1)
        # Tricky: after recursing, the cell below might become water
        # at rest, in which case we will want to continue walking, or
        # it might be flowing, in which case we want to return.  So we
        # back up to cause the cell to be reevaluated.
        x -= dir
      elsif $g[[x,y+1]] == F
        return [x, false]
      end
    end
    x += dir
  end
end

def flow_down(x, y)
  return if y > Yrange.max || $g[[x,y]] != S
  flow_down(x, y+1)
  if y == Yrange.max || $g[[x,y+1]] == F
    $g[[x,y]] = F
  else
    xmin, left_clay = flow_across(x, y, -1)
    xmax, right_clay = flow_across(x, y, 1)
    (xmin..xmax).each do |i|
      $g[[i,y]] = left_clay && right_clay ? W : F
    end
  end
end

flow_down(500, 0)

puts $g.count {|k,v| x,y = k; Yrange.cover?(y) && (v == W || v == F) }

# --- Part Two ---
#
# After a very long time, the water spring will run dry.  How much
# water will be retained?
#
# In the example above, water that won't eventually drain out is shown
# as ~, a total of 29 tiles.
#
# How many water tiles are left after the water spring stops producing
# water and all remaining water not at rest has drained?

puts $g.count {|k,v| x,y = k; Yrange.cover?(y) && v == W }
