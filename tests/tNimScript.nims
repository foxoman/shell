import ../shell
import strutils

checkShell:
  cd "Analysis/ingrid"
do:
  "cd Analysis/ingrid"

checkShell:
  cd Analysis/ingrid/stuff
do:
  "cd Analysis/ingrid/stuff"

checkShell:
  run test.h5
do:
  "run test.h5"

checkShell:
  "cd Analysis"
do:
  "cd Analysis"

checkShell:
  nimble develop
do:
  "nimble develop"

checkShell:
  ./reconstruction "Run123" "--out" "test.h5"
do:
  "./reconstruction Run123 --out test.h5"

checkShell:
  ./reconstruction Run123 "--out" "test.h5"
do:
  "./reconstruction Run123 --out test.h5"

checkShell:
  ./reconstruction Run123 "--out" test.h5
do:
  "./reconstruction Run123 --out test.h5"

checkShell:
  ./reconstruction Run123 --out test.h5
do:
  "./reconstruction Run123 --out test.h5"

checkShell:
  ./reconstruction Run123 --out
do:
  "./reconstruction Run123 --out"


checkShell:
  ./reconstruction Run123 """--out="test.h5""""
do:
  "./reconstruction Run123 --out=\"test.h5\""

checkShell:
  echo """"test file"""" > test.txt
do:
  "echo \"test file\" > test.txt"

checkShell:
  cat test.txt | grep """"file""""
do:
  "cat test.txt | grep \"file\""

checkShell:
  mkdir foo && rmdir foo
do:
  "mkdir foo && rmdir foo"

checkShell:
  echo `Hallo`
do:
  "echo \"Hallo\""

checkShell:
  echo `"Hello World!"`
do:
  "echo \"Hello World!\""

checkShell:
  "a=`echo Hallo`"
do:
  "a=`echo Hallo`"

shellEcho:
  ./reconstruction Run123 --out test.h5

shell:
  touch test1234567890.txt
  mv test1234567890.txt bar1234567890.txt
  rm bar1234567890.txt

checkShell:
  one:
    mkdir foo
    cd foo
    touch bar
    cd ".."
do:
  "mkdir foo && cd foo && touch bar && cd .."

checkShell:
  pipe:
    cat tests/tShell.nim
    grep test
    head -3
do:
  "cat tests/tShell.nim | grep test | head -3"

let name = "Vindaar"
checkShell:
  echo "Hello from" ($name)
do:
  &"echo Hello from {name}"

let dir = "testDir"
checkShell:
  tar -czf ($dir).tar.gz
do:
  &"tar -czf {dir}.tar.gz"

block:
  # "[shell] quoting a Nim symbol and appending to it using dotExpr":
  let dir = "testDir"
  checkShell:
    tar -czf ($dir).tar.gz
  do:
    &"tar -czf {dir}.tar.gz"

block:
  # "[shell] unintuitive: quoting a Nim symbol (), appending string":
  ## This is a rather unintuitive side effect of the way the Nim parser works.
  ## Unfortunately appending a string literal to a quote via `()` will result
  ## in a space between the quoted identifier and the string literal.
  ## See the test case below, which quotes everything via `()`.
  let dir = "testDir"
  checkShell:
    tar -czf ($dir)".tar.gz"
  do:
    &"tar -czf {dir} .tar.gz"

block:
  # "[shell] quoting a Nim symbol () and appending string inside the ()":
  let dir = "testDir"
  checkShell:
    tar -czf ($dir".tar.gz")
  do:
    &"tar -czf {dir}.tar.gz"

block:
  # "[shell] quoting a Nim symbol () and appending string inside the () with a space":
  let dir = "testDir"
  checkShell:
    tar -czf ($dir "aFile")
  do:
    &"tar -czf {dir} aFile"


block:
  # "[shell] quoting a Nim symbol and appending it to a string without space":
  let outname = "test.h5"
  checkShell:
    ./test "--out="($outname)
  do:
    &"./test --out={outname}"

block:
  # "[shell] quoting a Nim symbol and appending it within `()`":
  let outname = "test.h5"
  checkShell:
    ./test ("--out="$outname)
  do:
    &"./test --out={outname}"

block:
  # "[shell] quoting a Nim symbol and appending it within `()` with a space":
  let outname = "test.h5"
  checkShell:
    ./test ("--out" $outname)
  do:
    &"./test --out {outname}"

block:
  # "[shell] quoting a Nim symbol and appending it to a string with space":
  let outname = "test.h5"
  checkShell:
    ./test "--out" ($outname)
  do:
    &"./test --out {outname}"

block:
  var res = ""
  shellAssign:
    res = echo `hello`
  doAssert res == "hello"

block:
  var res = ""
  shellAssign:
    res = pipe:
      seq 0 1 10
      tail -3
  when not defined(travisCI):
    doAssert res == "8\n9\n10"

block:
  let ret = shellVerbose:
    "for f in 1 2 3; do echo $f; sleep 1; done"
  doAssert ret[0] == "1\n2\n3", "was " & $ret[0]

block:
  var toContinue = true
  template tc(cmd: untyped): untyped {.dirty.} =
    if toContinue:
      toContinue = cmd

  template shellCheck(actions: untyped): untyped =
    tc:
      let res = shellVerbose:
        actions
      res[1] == 0

  shellCheck:
    one:
      "f=hallo"
      echo $f
  doAssert toContinue

block:
  let res = shellVerbose:
    echo runBrokenCommand
    thisCommandDoesNotExistOnYourSystemOrThisTestWillFail
    echo Hello
  doAssert res[1] != 0
  echo res[0]
  doAssert res[0].startsWith("runBrokenCommand")

echo "All tests passed using NimScript!"
