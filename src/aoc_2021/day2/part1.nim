import std/os
import std/strformat
import std/strutils
import std/logging
import zero_functional
#[
--- Day 2: Dive! ---
Now, you need to figure out how to pilot this thing.

It seems like the submarine can take a series of commands like forward 1, down
2, or up 3:

forward X increases the horizontal position by X units.
down X increases the depth by X units.
up X decreases the depth by X units.

Note that since you're on a submarine, down and up affect your depth, and so
they have the opposite result of what you might expect.


The submarine seems to already have a planned course (your puzzle input). You
should probably figure out where it's going. For example:

forward 5
down 5
forward 8
up 3
down 8
forward 2

Your horizontal position and depth both start at 0. The steps above would then
modify them as follows:

forward 5 adds 5 to your horizontal position, a total of 5.
down 5 adds 5 to your depth, resulting in a value of 5.
forward 8 adds 8 to your horizontal position, a total of 13.
up 3 decreases your depth by 3, resulting in a value of 2.
down 8 adds 8 to your depth, resulting in a value of 10.
forward 2 adds 2 to your horizontal position, a total of 15.

After following these instructions, you would have a horizontal position of 15
and a depth of 10. (Multiplying these together produces 150.)

Calculate the horizontal position and depth you would have after following the
planned course. What do you get if you multiply your final horizontal position
by your final depth?

]#

type PositionData = tuple[
  horizontal: int,
  depth: int
]

type Direction* = enum
  Up, Down, Forward

proc `+=`(a: var PositionData, b: PositionData) {.inline.} =
  a.horizontal += b.horizontal
  a.depth += b.depth

proc `+`(a: PositionData, b: PositionData): PositionData {.inline.} =
  result += a
  result += b


proc parseLine(inputLine: string): PositionData =
  ## Parses the input line and converts that to a chnage in position data.
  let direction_and_quantity = inputLine.strip().splitWhitespace(maxSplit = 2)
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
    result.depth -= quantity
  of Direction.Down:
    result.depth += quantity
  of Direction.Forward:
    result.horizontal += quantity

proc getInputFilepath*(): string = currentSourcePath().parentDir() / "input.txt"

proc runPart1() =
  var totalPosition: PositionData = (0, 0)

  let inputFilepath = getInputFilepath()

  debug fmt"Loading file from {inputFilepath}"

  # Functional with sequtils would load all in memory
  let position = inputFilepath.lines() -->
    map(parseLine).
    fold(totalPosition, a + it)

  echo fmt"Final fp result: {position}"
  let product = totalPosition.horizontal * totalPosition.depth
  echo fmt"Final (horizontal, depth): {totalPosition}, product = {product}"

proc day2*() =
  ## Entry for the module to run all parts
  runPart1()


when isMainModule:
  import std/unittest
  let sampleLines = [
    "forward 9",
    "down 9",
    "up 4",
    "down 5",
    "down 6",
    "up 6",
    "down 7",
  ]

  # Fixture data for expected position parsing
  let expectedPositionData = [
    (horizontal: 9, depth: 0),
    (horizontal: 0, depth: 9),
    (horizontal: 0, depth: -4),
    (horizontal: 0, depth: 5),
    (horizontal: 0, depth: 6),
    (horizontal: 0, depth: -6),
    (horizontal: 0, depth: 7)
  ]

  echo "Testing with fixture data"
  for i, l in pairs(sampleLines):
    let t = parseLine(l)
    doAssert t == expectedPositionData[i]

  echo "Testing invalid data raises"
  expect ValueError:
    discard parseLine("backward 3")

  expect ValueError:
    discard parseLine("down three")

  echo "Done testing"
