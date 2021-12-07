#[
--- Part Two ---
Based on your calculations, the planned course doesn't seem to make any sense.
You find the submarine manual and discover that the process is actually slightly
more complicated.

In addition to horizontal position and depth, you'll also need to track a third
value, aim, which also starts at 0. The commands also mean something entirely
different than you first thought:

down X increases your aim by X units.
up X decreases your aim by X units.
forward X does two things:
It increases your horizontal position by X units.
It increases your depth by your aim multiplied by X.
Again note that since you're on a submarine, down and up do the opposite of what
you might expect: "down" means aiming in the positive direction.


Now, the above example does something different:

forward 5 adds 5 to your horizontal position, a total of 5. Because your aim is
0, your depth does not change.
down 5 adds 5 to your aim, resulting in a value of 5.

forward 8 adds 8 to your horizontal position, a total of 13. Because your aim is
5, your depth increases by 8*5=40.

up 3 decreases your aim by 3, resulting in a value of 2.
down 8 adds 8 to your aim, resulting in a value of 10.
forward 2 adds 2 to your horizontal position, a total of 15. Because your aim is
10, your depth increases by 2*10=20 to a total of 60.

After following these new instructions, you would have a horizontal position of
15 and a depth of 60. (Multiplying these produces 900.)


Using this new interpretation of the commands, calculate the horizontal position
and depth you would have after following the planned course. What do you get if
you multiply your final horizontal position by your final depth?
]#
import std/logging
import std/strformat
import std/strutils
import zero_functional

from part1 import Direction, getInputFilepath

type ExpandedPosition = object
  horizontal: int
  depth: int
  aim: int


proc processLine(line: string, result: var ExpandedPosition) =
  ## Parses input line with revised input logic
  let direction_and_quantity = line.strip().splitWhitespace(maxSplit = 2)
  assert direction_and_quantity.len() == 2, (
    fmt"Should have only position and quantity, got {direction_and_quantity}"
  )

  let (direction, quantity) = (direction_and_quantity[0].toLower(),
      direction_and_quantity[1].parseInt())

  let dirValue = case direction:
  of "up":
    Direction.Up
  of "down":
    Direction.Down
  of "forward":
    Direction.Forward
  else:
    var possibleDirections: seq[string] = @[]
    for d in ord(low(Direction)) .. ord(high(Direction)):
      possibleDirections.add($Direction(d))

    let all_directions = possibleDirections.join(", ")

    raise newException(ValueError, fmt"Expected one of {all_directions}, got {direction}")

  case dirValue:
  of Direction.Up:
    result.aim -= quantity
  of Direction.Down:
    result.aim += quantity
  of Direction.Forward:
    result.horizontal += quantity
    result.depth += quantity * result.aim


proc runPart2*() =
  var position = ExpandedPosition(horizontal: 0, depth: 0, aim: 0)
  let inputFilepath = getInputFilepath()

  debug fmt"Loading file from {inputFilepath}"

  inputFilepath.lines() -->
    foreach(processLine(it, position))
  
  echo fmt"Ending position is {position}"

  let product = position.depth * position.horizontal
  echo fmt"Product is {product}"

