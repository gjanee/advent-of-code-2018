# --- Day 3: No Matter How You Slice It ---
#
# The Elves managed to locate the chimney-squeeze prototype fabric for
# Santa's suit (thanks to someone who helpfully wrote its box IDs on
# the wall of the warehouse in the middle of the night).
# Unfortunately, anomalies are still affecting them - nobody can even
# agree on how to cut the fabric.
#
# The whole piece of fabric they're working on is a very large
# square - at least 1000 inches on each side.
#
# Each Elf has made a claim about which area of fabric would be ideal
# for Santa's suit.  All claims have an ID and consist of a single
# rectangle with edges parallel to the edges of the fabric.  Each
# claim's rectangle is defined as follows:
#
# - The number of inches between the left edge of the fabric and the
#   left edge of the rectangle.
# - The number of inches between the top edge of the fabric and the
#   top edge of the rectangle.
# - The width of the rectangle in inches.
# - The height of the rectangle in inches.
#
# A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a
# rectangle 3 inches from the left edge, 2 inches from the top edge, 5
# inches wide, and 4 inches tall.  Visually, it claims the square
# inches of fabric represented by # (and ignores the square inches of
# fabric represented by .) in the diagram below:
#
# ...........
# ...........
# ...#####...
# ...#####...
# ...#####...
# ...#####...
# ...........
# ...........
# ...........
#
# The problem is that many of the claims overlap, causing two or more
# claims to cover part of the same areas.  For example, consider the
# following claims:
#
# #1 @ 1,3: 4x4
# #2 @ 3,1: 4x4
# #3 @ 5,5: 2x2
#
# Visually, these claim the following areas:
#
# ........
# ...2222.
# ...2222.
# .11XX22.
# .11XX22.
# .111133.
# .111133.
# ........
#
# The four square inches marked with X are claimed by both 1 and 2.
# (Claim 3, while adjacent to the others, does not overlap either of
# them.)
#
# If the Elves all proceed with their own plans, none of them will
# have enough fabric.  How many square inches of fabric are within two
# or more claims?

class Claim
  # the claim's range is [left, right) x [top, bottom)

  attr_reader :id, :left, :top, :width, :height
  attr_accessor :overlaps

  def initialize(line)
    m = /^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/.match(line)
    @id, @left, @top, @width, @height = (1..5).map {|i| m[i].to_i }
    @overlaps = false
  end

  def right
    @left+@width
  end

  def bottom
    @top+@height
  end

end

Claims = open("03.in").readlines.map {|l| Claim.new(l) }

counts = Hash.new(0)
Claims.each do |c|
  (c.left...c.right).each do |i|
    (c.top...c.bottom).each do |j|
      counts[[i,j]] += 1
    end
  end
end
puts counts.values.select {|v| v > 1 }.length

# --- Part Two ---
#
# Amidst the chaos, you notice that exactly one claim doesn't overlap
# by even a single square inch of fabric with any other claim.  If you
# can somehow draw attention to it, maybe the Elves will be able to
# make Santa's suit after all!
#
# For example, in the claims above, only claim 3 is intact after all
# claims are made.
#
# What is the ID of the only claim that doesn't overlap?
#
# --------------------
#
# It's interesting how a slightly different question necessitates an
# entirely different approach.  The grid counting approach used in the
# first part is unhelpful in this part, and vice versa.  Note that all
# pairs of claims need to be tested for overlap; a claim can't be
# eliminated early.

Claims.combination(2) do |a,b|
  if b.left < a.right && a.left < b.right &&
    b.top < a.bottom && a.top < b.bottom
    a.overlaps = b.overlaps = true
  end
end
puts Claims.find {|c| !c.overlaps }.id
