# --- Day 6: Chronal Coordinates ---
#
# The device on your wrist beeps several times, and once again you
# feel like you're falling.
#
# "Situation critical," the device announces.  "Destination
# indeterminate.  Chronal interference detected.  Please specify new
# target coordinates."
#
# The device then produces a list of coordinates (your puzzle input).
# Are they places it thinks are safe or dangerous?  It recommends you
# check manual page 729.  The Elves did not give you a manual.
#
# If they're dangerous, maybe you can minimize the danger by finding
# the coordinate that gives the largest distance from the other
# points.
#
# Using only the Manhattan distance, determine the area around each
# coordinate by counting the number of integer X,Y locations that are
# closest to that coordinate (and aren't tied in distance to any other
# coordinate).
#
# Your goal is to find the size of the largest area that isn't
# infinite.  For example, consider the following list of coordinates:
#
# 1, 1
# 1, 6
# 8, 3
# 3, 4
# 5, 5
# 8, 9
#
# If we name these coordinates A through F, we can draw them on a
# grid, putting 0,0 at the top left:
#
# ..........
# .A........
# ..........
# ........C.
# ...D......
# .....E....
# .B........
# ..........
# ..........
# ........F.
#
# This view is partial - the actual grid extends infinitely in all
# directions.  Using the Manhattan distance, each location's closest
# coordinate can be determined, shown here in lowercase:
#
# aaaaa.cccc
# aAaaa.cccc
# aaaddecccc
# aadddeccCc
# ..dDdeeccc
# bb.deEeecc
# bBb.eeee..
# bbb.eeefff
# bbb.eeffff
# bbb.ffffFf
#
# Locations shown as . are equally far from two or more coordinates,
# and so they don't count as being closest to any.
#
# In this example, the areas of coordinates A, B, C, and F are
# infinite - while not shown here, their areas extend forever outside
# the visible grid.  However, the areas of coordinates D and E are
# finite: D is closest to 9 locations, and E is closest to 17 (both
# including the coordinate's location itself).  Therefore, in this
# example, the size of the largest area is 17.
#
# What is the size of the largest area that isn't infinite?
#
# --------------------
#
# It was not obvious how to determine which areas are infinite.  Using
# Euclidean distance, the infinite areas (or what are usually called
# the unbounded regions) of a Voronoi diagram are those whose
# generating points are on the points' convex hull.  But using
# Manhattan distance, it turns out that a region is unbounded iff it
# intersects the generating points' minimum bounding rectangle (MBR).
# The example below is helpful in seeing why this is so.  Suppose that
# A and B are rightmost among the generating points, and are therefore
# on both the convex hull and MBR, and suppose that C is to the left
# of A and B as shown.  Notice that C's region is unbounded.
#
#  MBR
#   |
# aaAaaaa
# caaaaaa
# ccaaaaa
# Ccccccc
# ccbbbbb
# cbbbbbb
# bbBbbbb
#   |
#
# If a region is unbounded, then obviously it must intersect the MBR.
# Conversely, suppose a region intersects the MBR.  The diagram below
# repeats the example above, but we've notated the intersection of C's
# region and the MBR by (=) and the grid location immediately to the
# right by (+).  Location (+) is one unit farther from C than (=), but
# because it is to the right of the MBR, compared to (=) it is
# uniformly one unit farther from *every* generating point.  It stands
# to reason that (+) shares (=)'s region, and so on by induction as we
# proceed rightward.
#
#  MBR
#   |
# aaAaaaa
# caaaaaa
# ccaaaaa
# Cc=+ccc
# ccbbbbb
# ccbbbbb
# bbBbbbb
#   |
#
# Thus our algorithm is to compute Manhattan distances and regions
# within and including the MBR, and to discard those regions that
# intersect the MBR.

X, Y, ID = 0, 1, 2
Input = open("06.in").map.with_index {|l,i| l.split(",").map{|v|v.to_i} + [i] }

xrange = Range.new(*Input.map{|c|c[X]}.minmax).to_a
yrange = Range.new(*Input.map{|c|c[Y]}.minmax).to_a

def distance(a, b)
  (a[X]-b[X]).abs + (a[Y]-b[Y]).abs
end

areas = {} # [x,y] => ID
xrange.product(yrange) do |x,y|
  sd = Input.map {|c| {value: distance([x,y], c), id: c[ID]} }
    .sort {|a,b| a[:value] <=> b[:value] }
  areas[[x,y]] = (sd[0][:value] == sd[1][:value] ? -1 : sd[0][:id])
end

counts = Hash.new(0) # ID => count
areas.values.each {|v| counts[v] += 1 }

xrange.product(yrange)
  .select {|x,y| x == xrange.first || x == xrange.last ||
                 y == yrange.first || y == yrange.last }
  .each do |x,y|
    counts.delete(areas[[x,y]])
  end

puts counts.values.max

# --- Part Two ---
#
# On the other hand, if the coordinates are safe, maybe the best you
# can do is try to find a region near as many coordinates as possible.
#
# For example, suppose you want the sum of the Manhattan distance to
# all of the coordinates to be less than 32.  For each location, add
# up the distances to all of the given coordinates; if the total of
# those distances is less than 32, that location is within the desired
# region.  Using the same coordinates as above, the resulting region
# looks like this:
#
# ..........
# .A........
# ..........
# ...###..C.
# ..#D###...
# ..###E#...
# .B.###....
# ..........
# ..........
# ........F.
#
# In particular, consider the location 4,3 located at the top middle
# of the region.  Its calculation is as follows, where abs() is the
# absolute value function:
#
# - Distance to coordinate A: abs(4-1) + abs(3-1) =  5
# - Distance to coordinate B: abs(4-1) + abs(3-6) =  6
# - Distance to coordinate C: abs(4-8) + abs(3-3) =  4
# - Distance to coordinate D: abs(4-3) + abs(3-4) =  2
# - Distance to coordinate E: abs(4-5) + abs(3-5) =  3
# - Distance to coordinate F: abs(4-8) + abs(3-9) = 10
# - Total distance: 5 + 6 + 4 + 2 + 3 + 10 = 30
#
# Because the total distance to all coordinates (30) is less than 32,
# the location is within the region.
#
# This region, which also includes coordinates D and E, has a total
# size of 16.
#
# Your actual region will need to be much larger than this example,
# though, instead including all locations with a total distance of
# less than 10000.
#
# What is the size of the region containing all locations which have a
# total distance to all given coordinates of less than 10000?
#
# --------------------
#
# If the region includes the MBR, we must search outside the MBR to
# probe its extent.  Fortunately, it's not necessary in this case.

L = 10000

a = {} # cell => distance sum
xrange.product(yrange) do |x,y|
  a[[x,y]] = Input.map {|c| distance([x,y], c) }.reduce(:+)
end

raise "need to increase range" if
  xrange.any? {|x| a[[x,yrange.first]] < L || a[[x,yrange.last]] < L }
raise "need to increase range" if
  yrange.any? {|y| a[[xrange.first,y]] < L || a[[xrange.last,y]] < L }

puts a.select {|k,v| v < L }.length
