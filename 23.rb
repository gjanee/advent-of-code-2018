# --- Day 23: Experimental Emergency Teleportation ---
#
# Using your torch to search the darkness of the rocky cavern, you
# finally locate the man's friend: a small reindeer.
#
# You're not sure how it got so far in this cave.  It looks sick - too
# sick to walk - and too heavy for you to carry all the way back.
# Sleighs won't be invented for another 1500 years, of course.  The
# only option is experimental emergency teleportation.
#
# You hit the "experimental emergency teleportation" button on the
# device and push "I accept the risk" on no fewer than 18 different
# warning messages.  Immediately, the device deploys hundreds of tiny
# nanobots which fly around the cavern, apparently assembling
# themselves into a very specific formation.  The device lists the
# X,Y,Z position (pos) for each nanobot as well as its signal radius
# (r) on its tiny screen (your puzzle input).
#
# Each nanobot can transmit signals to any integer coordinate which is
# a distance away from it less than or equal to its signal radius (as
# measured by Manhattan distance).  Coordinates a distance away of
# less than or equal to a nanobot's signal radius are said to be in
# range of that nanobot.
#
# Before you start the teleportation process, you should determine
# which nanobot is the strongest (that is, which has the largest
# signal radius) and then, for that nanobot, the total number of
# nanobots that are in range of it, including itself.
#
# For example, given the following nanobots:
#
# pos=<0,0,0>, r=4
# pos=<1,0,0>, r=1
# pos=<4,0,0>, r=3
# pos=<0,2,0>, r=1
# pos=<0,5,0>, r=3
# pos=<0,0,3>, r=1
# pos=<1,1,1>, r=1
# pos=<1,1,2>, r=1
# pos=<1,3,1>, r=1
#
# The strongest nanobot is the first one (position 0,0,0) because its
# signal radius, 4, is the largest.  Using that nanobot's location and
# signal radius, the following nanobots are in or out of range:
#
# - The nanobot at 0,0,0 is distance 0 away, and so it is in range.
# - The nanobot at 1,0,0 is distance 1 away, and so it is in range.
# - The nanobot at 4,0,0 is distance 4 away, and so it is in range.
# - The nanobot at 0,2,0 is distance 2 away, and so it is in range.
# - The nanobot at 0,5,0 is distance 5 away, and so it is not in range.
# - The nanobot at 0,0,3 is distance 3 away, and so it is in range.
# - The nanobot at 1,1,1 is distance 3 away, and so it is in range.
# - The nanobot at 1,1,2 is distance 4 away, and so it is in range.
# - The nanobot at 1,3,1 is distance 5 away, and so it is not in range.
#
# In this example, in total, 7 nanobots are in range of the nanobot
# with the largest signal radius.
#
# Find the nanobot with the largest signal radius.  How many nanobots
# are in range of its signals?

class Position

  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  def distance(other)
    (@x-other.x).abs + (@y-other.y).abs + (@z-other.z).abs
  end

end

class Nanobot

  attr_reader :position, :radius

  def initialize(position, radius)
    @position, @radius = position, radius
  end

  def in_range?(point)
    @position.distance(point) <= @radius
  end

end

max_radius = 0
Input = open("23.in").map {|l|
  m = /^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)$/.match(l)
  r = m[4].to_i
  max_radius = [max_radius, r].max
  Nanobot.new(Position.new(m[1].to_i, m[2].to_i, m[3].to_i), r)
}

bn = Input.find {|n| n.radius == max_radius }
puts Input.count {|n| bn.in_range?(n.position) }

# --- Part Two ---
#
# Now, you just need to figure out where to position yourself so that
# you're actually teleported when the nanobots activate.
#
# To increase the probability of success, you need to find the
# coordinate which puts you in range of the largest number of
# nanobots.  If there are multiple, choose one closest to your
# position (0,0,0, measured by Manhattan distance).
#
# For example, given the following nanobot formation:
#
# pos=<10,12,12>, r=2
# pos=<12,14,12>, r=2
# pos=<16,12,12>, r=4
# pos=<14,14,14>, r=6
# pos=<50,50,50>, r=200
# pos=<10,10,10>, r=5
#
# Many coordinates are in range of some of the nanobots in this
# formation.  However, only the coordinate 12,12,12 is in range of the
# most nanobots: it is in range of the first five, but is not in range
# of the nanobot at 10,10,10.  (All other coordinates are in range of
# fewer than five nanobots.)  This coordinate's distance from 0,0,0 is
# 36.
#
# Find the coordinates that are in range of the largest number of
# nanobots.  What is the shortest Manhattan distance between any of
# those points and 0,0,0?
#
# --------------------
#
# We use an octree pyramid to organize the search.  The root node (or
# root 3D "tile") is a cube, centered at the origin, with side length
# a power of 2, of sufficient size to enclose all nanobot ranges.
# Each tile is recursively subdivided into eight octants until tiles
# of side length 1 are reached, corresponding to individual points.
# We consider the number of nanobot range intersections with each
# tile, though with optimization we won't have to compute all of them.
#
# Note that a tile's intersection count cannot exceed its parent's.
# Note also that a greedy search strategy will not necessarily work: a
# tile with a higher intersection count may ultimately produce an
# inferior individual point because its intersections are more widely
# dispersed.
#
# The search is greatly accelerated over an exhaustive search by
# visiting tiles in strategic order using a priority queue.  A tile
# with a higher intersection count has priority over a tile with a
# lower count, and hence is visited first, because it may (but not
# necessarily) ultimately yield a point with a higher count.  Given
# two tiles with equal counts, the tile closer to the origin has
# higher priority because it may (but not necessarily) ultimately
# yield a point closer to the origin.  And given tiles with equal
# counts and equidistant from the origin, the smaller tile has
# priority, to effect a depth first search.  The first tile of size 1
# reached is necessarily the solution, for it has equal or higher
# count than every other tile (and therefore every point in every
# other tile), and it is as close or closer to the origin than every
# other tile (and therefore every point in every other tile).
#
# The intersection between a tile and a nanobot range is computed by
# clamping the nanobot (center) position to the tile, which yields the
# point in the tile nearest to the center, and then checking if the
# clamped point is within the nanobot's range.  In one dimension, the
# formula for clamping a point x to a range [a,b] is given by
# min(max(x, a), b).  In multiple dimensions each dimension is
# individually clamped.  The correctness of this can be seen by
# considering, in two dimensions, a tile and the nearest point to the
# tile from each of the eight surrounding regions:
#
#    |     |
# ---+-----+---
#    |     |
#    |     |
# ---+-----+---
#    |     |
#
# To eliminate confusion where integer lattice points sit vis-a-vis
# tile boundaries, we think of the nanobot positions as residing
# within tiles.  For example, a nanobot at 0,0 would sit as shown
# below:
#
# 2 +---+---+
#   |   |   |
# 1 +---+---+
#   | . |   |
# 0 +---+---+
#   0   1   2
#
# The implication is that clamping a lattice point at x to a tile with
# range [a,b] is given by min(max(x, a), b-1).  This also explains why
# a tile of size 1 corresponds to a point.
#
# First, an unfortunate omission from the Ruby standard library...

class PriorityQueue

  def initialize
    @heap = [nil]
  end

  def <<(element)
    @heap << element
    bubble_up(@heap.length-1)
  end

  def pop
    @heap[1], @heap[-1] = @heap[-1], @heap[1]
    e = @heap.pop
    bubble_down(1)
    e
  end

  private

  def bubble_up(i)
    p = i/2
    if i > 1 && @heap[p] < @heap[i]
      @heap[i], @heap[p] = @heap[p], @heap[i]
      bubble_up(p)
    end
  end

  def bubble_down(i)
    c = i*2
    if c < @heap.length
      c += 1 if c < @heap.length-1 && @heap[c+1] > @heap[c]
      if @heap[i] < @heap[c]
        @heap[i], @heap[c] = @heap[c], @heap[i]
        bubble_down(c)
      end
    end
  end

end

Origin = Position.new(0, 0, 0)

class Tile
  # cubic tile with minimal corner at `corner` and side length `size`

  attr_reader :corner, :size, :count

  def initialize(corner, size)
    @corner, @size = corner, size
    @count = Input.count {|n| n.in_range?(clamp(n.position)) }
  end

  def clamp(point)
    Position.new(
      [[point.x, @corner.x].max, @corner.x+@size-1].min,
      [[point.y, @corner.y].max, @corner.y+@size-1].min,
      [[point.z, @corner.z].max, @corner.z+@size-1].min)
  end

  include Comparable
  def <=>(other)
    if @count != other.count
      @count <=> other.count
    else
      d_self = clamp(Origin).distance(Origin)
      d_other = other.clamp(Origin).distance(Origin)
      if d_self != d_other
        d_other <=> d_self
      else
        other.size <=> @size
      end
    end
  end

end

bound = Input.map {|n|
  [n.position.x, n.position.y, n.position.z].map(&:abs).max + n.radius + 1
}.max
bound = 2**Math.log2(bound).ceil

pq = PriorityQueue.new
pq << Tile.new(Position.new(-bound, -bound, -bound), 2*bound)
while true
  t = pq.pop
  break if t.size == 1
  s = t.size/2
  [t.corner.x, t.corner.x+s].each do |x|
    [t.corner.y, t.corner.y+s].each do |y|
      [t.corner.z, t.corner.z+s].each do |z|
        pq << Tile.new(Position.new(x, y, z), s)
      end
    end
  end
end
puts t.corner.distance(Origin)
