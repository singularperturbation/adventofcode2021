import std/parseopt
import std/strformat
import std/strutils
import std/logging
from std/os import commandLineParams
import ./day1/runExercise
import ./day2/part1

proc displayHelp(code: int) =
  echo """
  Runs an Advent of Code exercise:

  ./aoc_2021 --help (displays this help)
  ./aoc_2021 --day=i (run exercise for ith day)
  """.strip()
  quit(code)

proc main() =
  # This CLI Parser is awkward, try with docopt or cligen
  var args = initOptParser(commandLineParams())
  let exercisesByDay = [
    day1,
    day2,
  ]

  var dayIndex = -1

  for (kind, key, val) in args.getopt():
    case kind:
    of cmdLongOption:
      case key:
      of "day":
        discard
      of "help":
        displayHelp(0)
      else:
        displayHelp(-1)
      
      try:
        dayIndex = parseInt(val) - 1
        if dayIndex < low(exercisesByDay) or dayIndex > high(exercisesByDay):
          raise newException(ValueError, fmt"Day {dayIndex + 1} outside of range [1, {exercisesByday.len()})")
      except ValueError as e:
        echo fmt"Error parsing day - {e.msg}"
        displayHelp(-1)

    of cmdArgument, cmdShortOption:
      displayHelp(-1)
    of cmdEnd:
      break

  # Have we actually set up a day
  if dayIndex == -1:
    displayHelp(-1)
  
  echo fmt"Running Day {dayIndex+1}"
  # Make this configurable through CLI args
  let logger = newConsoleLogger(lvlAll)
  addHandler(logger)

  exercisesByDay[dayIndex]()
  
when isMainModule:
  main()
