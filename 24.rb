# --- Day 24: Immune System Simulator 20XX ---
#
# After a weird buzzing noise, you appear back at the man's cottage.
# He seems relieved to see his friend, but quickly notices that the
# little reindeer caught some kind of cold while out exploring.
#
# The portly man explains that this reindeer's immune system isn't
# similar to regular reindeer immune systems:
#
# The immune system and the infection each have an army made up of
# several groups; each group consists of one or more identical units.
# The armies repeatedly fight until only one army has units remaining.
#
# Units within a group all have the same hit points (amount of damage
# a unit can take before it is destroyed), attack damage (the amount
# of damage each unit deals), an attack type, an initiative (higher
# initiative units attack first and win ties), and sometimes
# weaknesses or immunities.  Here is an example group:
#
# - 18 units each with 729 hit points (weak to fire; immune to cold,
#   slashing) with an attack that does 8 radiation damage at
#   initiative 10
#
# Each group also has an effective power: the number of units in that
# group multiplied by their attack damage.  The above group has an
# effective power of 18 * 8 = 144.  Groups never have zero or negative
# units; instead, the group is removed from combat.
#
# Each fight consists of two phases: target selection and attacking.
#
# During the target selection phase, each group attempts to choose one
# target.  In decreasing order of effective power, groups choose their
# targets; in a tie, the group with the higher initiative chooses
# first.  The attacking group chooses to target the group in the enemy
# army to which it would deal the most damage (after accounting for
# weaknesses and immunities, but not accounting for whether the
# defending group has enough units to actually receive all of that
# damage).
#
# If an attacking group is considering two defending groups to which
# it would deal equal damage, it chooses to target the defending group
# with the largest effective power; if there is still a tie, it
# chooses the defending group with the highest initiative.  If it
# cannot deal any defending groups damage, it does not choose a
# target.  Defending groups can only be chosen as a target by one
# attacking group.
#
# At the end of the target selection phase, each group has selected
# zero or one groups to attack, and each group is being attacked by
# zero or one groups.
#
# During the attacking phase, each group deals damage to the target it
# selected, if any.  Groups attack in decreasing order of initiative,
# regardless of whether they are part of the infection or the immune
# system.  (If a group contains no units, it cannot attack.)
#
# The damage an attacking group deals to a defending group depends on
# the attacking group's attack type and the defending group's
# immunities and weaknesses.  By default, an attacking group would
# deal damage equal to its effective power to the defending group.
# However, if the defending group is immune to the attacking group's
# attack type, the defending group instead takes no damage; if the
# defending group is weak to the attacking group's attack type, the
# defending group instead takes double damage.
#
# The defending group only loses whole units from damage; damage is
# always dealt in such a way that it kills the most units possible,
# and any remaining damage to a unit that does not immediately kill it
# is ignored.  For example, if a defending group contains 10 units
# with 10 hit points each and receives 75 damage, it loses exactly 7
# units and is left with 3 units at full health.
#
# After the fight is over, if both armies still contain units, a new
# fight begins; combat only ends once one army has lost all of its
# units.
#
# For example, consider the following armies:
#
# Immune System:
# - 17 units each with 5390 hit points (weak to radiation,
#   bludgeoning) with an attack that does 4507 fire damage at
#   initiative 2
# - 989 units each with 1274 hit points (immune to fire; weak to
#   bludgeoning, slashing) with an attack that does 25 slashing damage
#   at initiative 3
#
# Infection:
# - 801 units each with 4706 hit points (weak to radiation) with an
#   attack that does 116 bludgeoning damage at initiative 1
# - 4485 units each with 2961 hit points (immune to radiation; weak to
#   fire, cold) with an attack that does 12 slashing damage at
#   initiative 4
#
# If these armies were to enter combat, the following fights,
# including details during the target selection and attacking phases,
# would take place:
#
# Fight 1
# - Immune System:
#   - Group 1 contains 17 units
#   - Group 2 contains 989 units
# - Infection:
#   - Group 1 contains 801 units
#   - Group 2 contains 4485 units
# - Target selection:
#   - Infection group 1 would deal defending group 1 185832 damage
#   - Infection group 1 would deal defending group 2 185832 damage
#   - Infection group 2 would deal defending group 2 107640 damage
#   - Immune System group 1 would deal defending group 1 76619 damage
#   - Immune System group 1 would deal defending group 2 153238 damage
#   - Immune System group 2 would deal defending group 1 24725 damage
# - Attacking:
#   - Infection group 2 attacks defending group 2, killing 84 units
#   - Immune System group 2 attacks defending group 1, killing 4 units
#   - Immune System group 1 attacks defending group 2, killing 51 units
#   - Infection group 1 attacks defending group 1, killing 17 units
#
# Fight 2
# - Immune System:
#   - Group 2 contains 905 units
# - Infection:
#   - Group 1 contains 797 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 184904 damage
#   - Immune System group 2 would deal defending group 1 22625 damage
#   - Immune System group 2 would deal defending group 2 22625 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 4 units
#   - Infection group 1 attacks defending group 2, killing 144 units
#
# Fight 3
# - Immune System:
#   - Group 2 contains 761 units
# - Infection:
#   - Group 1 contains 793 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 183976 damage
#   - Immune System group 2 would deal defending group 1 19025 damage
#   - Immune System group 2 would deal defending group 2 19025 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 4 units
#   - Infection group 1 attacks defending group 2, killing 143 units
#
# Fight 4
# - Immune System:
#   - Group 2 contains 618 units
# - Infection:
#   - Group 1 contains 789 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 183048 damage
#   - Immune System group 2 would deal defending group 1 15450 damage
#   - Immune System group 2 would deal defending group 2 15450 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 3 units
#   - Infection group 1 attacks defending group 2, killing 143 units
#
# Fight 5
# - Immune System:
#   - Group 2 contains 475 units
# - Infection:
#   - Group 1 contains 786 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 182352 damage
#   - Immune System group 2 would deal defending group 1 11875 damage
#   - Immune System group 2 would deal defending group 2 11875 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 2 units
#   - Infection group 1 attacks defending group 2, killing 142 units
#
# Fight 6
# - Immune System:
#   - Group 2 contains 333 units
# - Infection:
#   - Group 1 contains 784 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 181888 damage
#   - Immune System group 2 would deal defending group 1 8325 damage
#   - Immune System group 2 would deal defending group 2 8325 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 1 unit
#   - Infection group 1 attacks defending group 2, killing 142 units
#
# Fight 7
# - Immune System:
#   - Group 2 contains 191 units
# - Infection:
#   - Group 1 contains 783 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 181656 damage
#   - Immune System group 2 would deal defending group 1 4775 damage
#   - Immune System group 2 would deal defending group 2 4775 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 1 unit
#   - Infection group 1 attacks defending group 2, killing 142 units
#
# Fight 8
# - Immune System:
#   - Group 2 contains 49 units
# - Infection:
#   - Group 1 contains 782 units
#   - Group 2 contains 4434 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 181424 damage
#   - Immune System group 2 would deal defending group 1 1225 damage
#   - Immune System group 2 would deal defending group 2 1225 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 0 units
#   - Infection group 1 attacks defending group 2, killing 49 units
#
# Fight 9
# - Immune System:
#   - No groups remain
# - Infection:
#   - Group 1 contains 782 units
#   - Group 2 contains 4434 units
#
# In the example above, the winning army ends up with 782 + 4434 =
# 5216 units.
#
# You scan the reindeer's condition (your puzzle input); the
# white-bearded man looks nervous.  As it stands now, how many units
# would the winning army have?

BODY, GERM = "Immune System", "Infection" # sides

class Group

  @@all = []   # all groups
  @@alive = [] # those still alive

  def Group.alive
    @@alive
  end

  def Group.reset
    @@alive = @@all.dup
    @@alive.each do |g|
      g.reset
    end
  end

  attr_reader :num_units, :immunities, :weaknesses, :initiative, :side
  attr_accessor :targeted

  def initialize(num_units, hit_points, damage_points, damage_type,
    immunities, weaknesses, initiative, side)
    @original_num_units = num_units
    @num_units = nil
    @hit_points, @damage_points, @damage_type, @immunities, @weaknesses,
      @initiative, @side = hit_points, damage_points, damage_type,
      immunities, weaknesses, initiative, side
    @targeted = false
    @target = nil
    @@all << self
  end

  def effective_power
    @num_units*@damage_points
  end

  def enemies
    @@alive.select {|g| g.side != @side }
  end

  def damage_amount(enemy)
    d = effective_power
    if enemy.immunities.member?(@damage_type)
      d = 0
    elsif enemy.weaknesses.member?(@damage_type)
      d *= 2
    end
    d
  end

  def target
    l = enemies.reject {|e| e.targeted }.sort_by {|e|
      [-damage_amount(e), -e.effective_power, -e.initiative]
    }
    if l.length > 0 && damage_amount(l[0]) > 0
      e = l[0]
      e.targeted = true
      @target = e
    end
  end

  def attack
    # returns true if the attack did damage
    return false if @target.nil?
    k = @target.receive_damage(damage_amount(@target))
    return k > 0
  end

  def receive_damage(points)
    # returns the number of units killed
    k = points/@hit_points
    @num_units -= k
    @@alive.delete(self) if dead?
    k
  end

  def dead?
    @num_units <= 0
  end

  def clear_targeting
    @targeted = false
    @target = nil
  end

  def reset
    @num_units = @original_num_units
  end

end

pattern = Regexp.compile("^(\\d+) units each with (\\d+) hit points"\
  "( \\(.*\\))? with an attack that does (\\d+) ([^ ]+) damage at "\
  "initiative (\\d+)$")
side = nil
open("24.in").each do |l|
  l.chomp!
  next if l.length == 0
  if l.end_with?(":")
    side = l[0..-2]
    next
  end
  m = pattern.match(l)
  num_units = m[1].to_i
  hit_points = m[2].to_i
  damage_points = m[4].to_i
  damage_type = m[5]
  initiative = m[6].to_i
  immunities = []
  weaknesses = []
  if !m[3].nil?
    m[3][2..-2].split(";").map(&:strip).each do |p|
      m = /^(immune|weak) to (.*)$/.match(p)
      if m[1] == "immune"
        immunities = m[2].split(",").map(&:strip)
      else
        weaknesses = m[2].split(",").map(&:strip)
      end
    end
  end
  Group.new(num_units, hit_points, damage_points, damage_type,
    immunities, weaknesses, initiative, side)
end

def battle
  while Group.alive.count {|g| g.side == BODY } > 0 &&
    Group.alive.count {|g| g.side == GERM } > 0
    Group.alive.each do |g|
      g.clear_targeting
    end
    Group.alive.sort_by {|g| [-g.effective_power, -g.initiative] }.each do |g|
      g.target
    end
    something_changed = false
    Group.alive.sort_by {|g| -g.initiative }.each do |g|
      # Careful: a group may die mid-fight, in which case it must be
      # excluded immediately.
      next if g.dead?
      # While it does not happen in part 1, it does happen in part 2,
      # and can happen in general: the remaining damage amounts are so
      # low that units are no longer killed, resulting in a stalemate.
      # We look for at least one unit to die per fight.
      r = g.attack
      something_changed |= r
    end
    return ["stalemate", 0] if !something_changed
  end
  [Group.alive[0].side, Group.alive.map {|g| g.num_units }.reduce(:+)]
end

Group.reset
winner, num_units = battle
raise "stalement" if winner == "stalement"
puts num_units

# --- Part Two ---
#
# Things aren't looking good for the reindeer.  The man asks whether
# more milk and cookies would help you think.
#
# If only you could give the reindeer's immune system a boost, you
# might be able to change the outcome of the combat.
#
# A boost is an integer increase in immune system units' attack
# damage.  For example, if you were to boost the above example's
# immune system's units by 1570, the armies would instead look like
# this:
#
# Immune System:
# - 17 units each with 5390 hit points (weak to radiation,
#   bludgeoning) with an attack that does 6077 fire damage at
#   initiative 2
# - 989 units each with 1274 hit points (immune to fire; weak to
#   bludgeoning, slashing) with an attack that does 1595 slashing
#   damage at initiative 3
#
# Infection:
# - 801 units each with 4706 hit points (weak to radiation) with an
#   attack that does 116 bludgeoning damage at initiative 1
# - 4485 units each with 2961 hit points (immune to radiation; weak to
#   fire, cold) with an attack that does 12 slashing damage at
#   initiative 4
#
# With this boost, the combat proceeds differently:
#
# Fight 1
# - Immune System:
#   - Group 2 contains 989 units
#   - Group 1 contains 17 units
# - Infection:
#   - Group 1 contains 801 units
#   - Group 2 contains 4485 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 185832 damage
#   - Infection group 1 would deal defending group 1 185832 damage
#   - Infection group 2 would deal defending group 1 53820 damage
#   - Immune System group 2 would deal defending group 1 1577455 damage
#   - Immune System group 2 would deal defending group 2 1577455 damage
#   - Immune System group 1 would deal defending group 2 206618 damage
# - Attacking:
#   - Infection group 2 attacks defending group 1, killing 9 units
#   - Immune System group 2 attacks defending group 1, killing 335 units
#   - Immune System group 1 attacks defending group 2, killing 32 units
#   - Infection group 1 attacks defending group 2, killing 84 units
#
# Fight 2
# - Immune System:
#   - Group 2 contains 905 units
#   - Group 1 contains 8 units
# - Infection:
#   - Group 1 contains 466 units
#   - Group 2 contains 4453 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 108112 damage
#   - Infection group 1 would deal defending group 1 108112 damage
#   - Infection group 2 would deal defending group 1 53436 damage
#   - Immune System group 2 would deal defending group 1 1443475 damage
#   - Immune System group 2 would deal defending group 2 1443475 damage
#   - Immune System group 1 would deal defending group 2 97232 damage
# - Attacking:
#   - Infection group 2 attacks defending group 1, killing 8 units
#   - Immune System group 2 attacks defending group 1, killing 306 units
#   - Infection group 1 attacks defending group 2, killing 29 units
#
# Fight 3
# - Immune System:
#   - Group 2 contains 876 units
# - Infection:
#   - Group 2 contains 4453 units
#   - Group 1 contains 160 units
# - Target selection:
#   - Infection group 2 would deal defending group 2 106872 damage
#   - Immune System group 2 would deal defending group 2 1397220 damage
#   - Immune System group 2 would deal defending group 1 1397220 damage
# - Attacking:
#   - Infection group 2 attacks defending group 2, killing 83 units
#   - Immune System group 2 attacks defending group 2, killing 427 units
#
# After a few fights...
#
# Fight
# - Immune System:
#   - Group 2 contains 64 units
# - Infection:
#   - Group 2 contains 214 units
#   - Group 1 contains 19 units
# - Target selection:
#   - Infection group 2 would deal defending group 2 5136 damage
#   - Immune System group 2 would deal defending group 2 102080 damage
#   - Immune System group 2 would deal defending group 1 102080 damage
# - Attacking:
#   - Infection group 2 attacks defending group 2, killing 4 units
#   - Immune System group 2 attacks defending group 2, killing 32 units
#
# Fight
# - Immune System:
#   - Group 2 contains 60 units
# - Infection:
#   - Group 1 contains 19 units
#   - Group 2 contains 182 units
# - Target selection:
#   - Infection group 1 would deal defending group 2 4408 damage
#   - Immune System group 2 would deal defending group 1 95700 damage
#   - Immune System group 2 would deal defending group 2 95700 damage
# - Attacking:
#   - Immune System group 2 attacks defending group 1, killing 19 units
#
# Fight
# - Immune System:
#   - Group 2 contains 60 units
# - Infection:
#   - Group 2 contains 182 units
# - Target selection:
#   - Infection group 2 would deal defending group 2 4368 damage
#   - Immune System group 2 would deal defending group 2 95700 damage
# - Attacking:
#   - Infection group 2 attacks defending group 2, killing 3 units
#   - Immune System group 2 attacks defending group 2, killing 30 units
#
# After a few more fights...
#
# Fight
# - Immune System:
#   - Group 2 contains 51 units
# - Infection:
#   - Group 2 contains 40 units
# - Target selection:
#   - Infection group 2 would deal defending group 2 960 damage
#   - Immune System group 2 would deal defending group 2 81345 damage
# - Attacking:
#   - Infection group 2 attacks defending group 2, killing 0 units
#   - Immune System group 2 attacks defending group 2, killing 27 units
#
# Fight
# - Immune System:
#   - Group 2 contains 51 units
# - Infection:
#   - Group 2 contains 13 units
# - Target selection:
#   - Infection group 2 would deal defending group 2 312 damage
#   - Immune System group 2 would deal defending group 2 81345 damage
# - Attacking:
#   - Infection group 2 attacks defending group 2, killing 0 units
#   - Immune System group 2 attacks defending group 2, killing 13 units
#
# Fight
# - Immune System:
#   - Group 2 contains 51 units
# - Infection:
#   - No groups remain
#
# This boost would allow the immune system's armies to win!  It would
# be left with 51 units.
#
# You don't even know how you could boost the reindeer's immune system
# or what effect it might have, so you need to be cautious and find
# the smallest boost that would allow the immune system to win.
#
# How many units does the immune system have left after getting the
# smallest boost it needs to win?

class Group

  def set_boost(boost)
    @boost = boost
  end

  def effective_power
    @num_units*(@damage_points+@boost)
  end

end

1.step do |n|
  Group.reset
  Group.alive.each do |g|
    g.set_boost(g.side == BODY ? n : 0)
  end
  winner, num_units = battle
  break if winner == BODY
end
puts num_units
