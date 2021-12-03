import std/logging
import std/deques
import std/strformat
# Prompt
#[
--- Part Two ---
Considering every single measurement isn't as useful as you expected: there's
just too much noise in the data.


Instead, consider sums of a three-measurement sliding window. Again considering
the above example:


199  A
200  A B
208  A B C
210    B C D
200  E   C D
207  E F   D
240  E F G
269    F G H
260      G H
263        H

Start by comparing the first and second three-measurement windows. The
measurements in the first window are marked A (199, 200, 208); their sum is 199
+ 200 + 208 = 607. The second window is marked B (200, 208, 210); its sum is
618. The sum of measurements in the second window is larger than the sum of the
first, so this first comparison increased.

Your goal now is to count the number of times the sum of measurements in this
sliding window increases from the previous sum. So, compare A with B, then
compare B with C, then C with D, and so on. Stop when there aren't enough
measurements left to create a new three-measurement sum.


In the above example, the sum of each three-measurement window is as follows:

A: 607 (N/A - no previous sum)
B: 618 (increased)
C: 618 (no change)
D: 617 (decreased)
E: 647 (increased)
F: 716 (increased)
G: 769 (increased)
H: 792 (increased)
In this example, there are 5 sums that are larger than the previous sum.

Consider sums of a three-measurement sliding window. How many sums are larger
than the previous sum?
]#

iterator slidingWindow*[T](
  inputs: openArray[T],
  window_size: static[int]
): array[window_size, T] =
  ## Yield all sliding windows of size `window_size`, stopping when we have run
  ## out of elements.
  runnableExamples:
    import std/sequtils
    let a = [1, 2, 3, 4]

    let expectedWindows = [
      [1, 2],
      [2, 3],
      [3, 4]
    ]

    doAssert expectedWindows == toSeq(slidingWindow(a, 2))

  var dq = initDeque[T](initialSize = 0)
  # Empty array of window_size
  var windowVals: array[window_size, T]

  for i in 0 ..< min(window_size, len(inputs)):
    dq.addLast(inputs[i])
  
  if dq.len() == window_size:
    for i, value in dq.pairs():
      windowVals[i] = value
    
    yield windowVals
    discard dq.popFirst()

    for i in inputs[window_size .. high(inputs)]:
      dq.addLast(i)
      for i, value in dq.pairs():
        windowVals[i] = value
      
      yield windowVals
      discard dq.popFirst()

proc runPuzzle2*(measurements: seq[int]) =
  const window_size = 3
  var lastSum = high(int)
  var numIncreases = 0
  for window in slidingWindow(measurements, window_size):
    var currentSum = 0
    for v in window:
      currentSum += v
    
    if currentSum > lastSum:
      numIncreases += 1
    
    lastSum = currentSum

  echo fmt"{numIncreases} sliding window increases"
