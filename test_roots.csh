#!/bin/csh
# ----------------------------------------------------------------------------
# File name:    run_roots.csh
#
# Purpose:      Run roots.crun against all the test cases and create
#               test results file.
#
# Invocation:   test_roots.csh 
#
# Keyboard Inputs: None.
#
# Required Files: 
#               1) roots.crun -- executable version of roots.
#               2) tci_roots.txt -- set of test cases for roots.
#
# Output Files:
#               1) utr_roots.txt -- test results (appended)
#
# Author:       Andia Dark
#
# Date:         2020-09-21
#
# ----------------------------------------------------------------------------

#-| ------------------------------------------------------------------
#-| Check argument list. Do not accept any arguments.
#-| ------------------------------------------------------------------ 
if ($#argv != 1) then
  echo " "
  echo " "
  echo "USAGE ERROR: Missing Arguments ... "
  echo " "
  echo "CORRECT USAGE: test_roots.csh tester "
  echo " "
  echo " "
  exit 1
endif

#-| ------------------------------------------------------------------
#-| Check for the existence of the required files.
#-| ------------------------------------------------------------------
set tester = $1
set tci = tci_roots.txt
set utr = utr_roots.txt 
set run = roots.crun
--set run = roots.run
set timestamp = `date`

if (! -e $tci) then
  echo " "
  echo "TEST CASE INPUT (test cases) FILE $tci NOT FOUND ... EXITING ..."
  echo " "
  exit 2
endif

if (! -e $run) then
  echo " "
  echo "EXECUTABLE FILE $run NOT FOUND ... EXITING ..."
  echo " "
  exit 3
endif


#-| ------------------------------------------------------------------
#-| Establish the output Test Results file if it does not exist. 
#-| Write the required header lines identifying tester.
#-| ------------------------------------------------------------------
if (! -e $utr) then
   echo "--------------------------------------------" > $utr
   echo "File Name:  $utr  " >> $utr
   echo "Area TEST RESULTS FILE  " >> $utr
   echo " " >> $utr
endif


#-| ------------------------------------------------------------------
#-| Write the test session header identifying tester and test date.
#-| ------------------------------------------------------------------

echo " " >> $utr
echo "============================================" >> $utr
echo "TEST SESSION DATE: $timestamp " >> $utr
echo "TESTER:            $tester" >> $utr
echo "============================================" >> $utr
echo " " >> $utr
echo "TC# TEST CASE/RESULTS                        " >> $utr
echo "--- ---------------------------------------- " >> $utr

   
#-| ------------------------------------------------------------------
#-| Make a list of test cases to be used. Because Area takes two
#-|      stimuli and produces one response, each test case requires
#-|      three values "Length Width expectedArea. So make sure the number
#-|      of values is a multiple of 3.
#-| ------------------------------------------------------------------
set testcase=(`cat $tci`)
echo "REMAINING TEST CASES:  $testcase"

#-| ------------------------------------------------------------------
#-| Skip past the header line in the tci_ file: A B C roots-expected
#-| ------------------------------------------------------------------
repeat 4 shift testcase
 
echo "TEST CASES:  $testcase"


#-| ------------------------------------------------------------------
#-| Initialize the count of test cases and the counts of failed/passed
#-|          test cases.
#-| ------------------------------------------------------------------
set tcasenum = 0
set passed = 0
set failed = 0

#-| ------------------------------------------------------------------
#-| Until the list of testcases is exhausted, extract 3 values, two`
#-|       to be used as inputs, and the third as the expected result.
#-| ------------------------------------------------------------------
while ($#testcase >= 5)

     set A=$testcase[1]
     set B=$testcase[2]
     set C=$testcase[3]
     set exp=$testcase[4]" "$testcase[5]
     
     @ tcasenum ++ 
     set actual=`echo $A $B $C | ./roots.crun  | awk '/QUADRATIC ROOTS:/  {print $3" "$4}'`

     #-| ------------------------------------------------------------------
     #-| Parse outputs to extract answer computed.
     #-| Location of answer depends on program's output specification: 
     #-|      
     #-|   Captured output: "Enter A: Enter B: Enter C: ROOTS = xxx"
     #-|
     #-|    NOTE: The answer follows the '=' sign. 
     #-| ------------------------------------------------------------------
     echo "OUTPUTS: $actual "
     

     set testrec = " #$tcasenum A=$A  B=$B C=$C "
     set testrec = "$testrec     ==> ROOTS=< $actual  $exp >"
 

     #-| ------------------------------------------------------------------
     #-| Apply the test oracle to determine whether PASSED/FAILED.
     #-|       Count #passed, #failed.
     #-| ------------------------------------------------------------------
     if ("$actual" == "$exp") then
        set testrec = "$testrec  PASSED"
        @ passed++
     else
        set testrec = "$testrec  FAILED"
        @ failed++
     endif

 
     #-| Display test result record and write to test results file.
     echo $testrec
     echo $testrec >> $utr
    
     #-|  Remove the test testrec from the list.
     shift testcase
     shift testcase
     shift testcase
     shift testcase
     shift testcase
     
     echo ""
     echo "REMAINING TEST CASES: ( $testcase )"
     echo ""
end #while


