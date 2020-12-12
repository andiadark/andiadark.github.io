#!/bin/csh
# -------------------------------------------------------------------------
# File name:  gradeMy_utility_Billing.csh
#
# Template:   My_grader_template_LOCALbin.txt
#
# GENERATED:  Sun Mar 15 18:57:44 EST 2020 
#
# Purpose:    TEMPLATE: Grade CODIO programming assignment for specific student (login).
#
# Invocation: gradeMy_utility_Billing.csh login
#
# Example:    gradeMy_utility_Billing.csh ejones 
#
# Arguments: 
#            (1) studlogin - Unix login of student. 
#
# Author:    Dr. Edward L. Jones
#
# Date:      Fall 2010  
# Revised:   05 Mar 2018 : Codio template.
#            12 May 2018 : Removed login from all source files.
#
#            TBD: Add bonus  (expf + checkrun)
#
#item PTS  Objective / Rubric
#---- ---  ----------------------------------------------------------
#  1  0     Submitted                         (0).
#  2  1     Clean compilation                 (1)
#  3  0     Quality of documentation          (0)
#  4  62     Correctness of output             (62)
#  5  bon     BONUS -- exceptional features     (+0)
#     ---
#      63  POINTS
#
#      score = ( bon + score ) / 63
# -------------------------------------------------------------------------

#-| Family members share testcase files.
set basename = utility_Billing
set familyname = utility_Billing     

set inFile = ( in:cin in:readings.txt )
set outFile = ( out:cout )

set curyear = 2020
@ doc = 0
@ cor = 62
@ bon = 0
set auto_docngrading = YES
set auto_rungrading = YES

set gradingDIR = ~/workspace/grading
#-|---------------------------------------------------------------------------
#-| Verify that grading directory exists and grading files are there.
#-|---------------------------------------------------------------------------
if (-d $gradingDIR/) then
   set count = ( `ls  $gradingDIR/utility_Billing:*f?* | wc` )
   if ($count[1] < 2) then
      echo "ERROR-2: utility_Billing grading test cases not found. Email TEACHER. "
      exit 2
   endif
else
   echo "ERROR-1: utility_Billing grading area not established. Email TEACHER. "
   exit 1
endif

#-|----------------------------------------------------------------
#-| Personal use: if no login supplied, use stored login.
#-| Otherwise, read and store login in .loginfile.
#-|----------------------------------------------------------------
set stud = $1
set loginFound = 0
if ($#argv == 0) then
   if (-e ~/workspace/.loginfile) then
      set STUDLOGIN = ( `cat ~/workspace/.loginfile` )
      if ( $#STUDLOGIN == 1) then
         @ loginFound = 1
         set stud = $STUDLOGIN[1]
      endif
   endif

   if ($loginFound == 0) then
      echo -n "Enter your login (e.g., ejones, ksmith): ";
      set stud = $<
      rm -f ~/workspace/.loginfile
      echo $stud > ~/workspace/.loginfile
   endif
else  
   #-|#LOGIN supplied. Store in .loginfile.
   rm -f ~/workspace/.loginfile
   echo $stud > ~/workspace/.loginfile
endif

#-| ---------------------------------------------------------------------------
#-| Initialize data for grading report header.
#-| ---------------------------------------------------------------------------
set curdir = `pwd`
set g = "My_utility_Billing.cpp_testreport-$stud.txt"

#-| ---------------------------------------------------------------------------
#-| Initialize overall score to the max value.
#-| ---------------------------------------------------------------------------
@ score = 63

#-| ---------------------------------------------------------------------------
#-| Initialize file names for student's work.
#-| ---------------------------------------------------------------------------
set src = utility_Billing.cpp
set srcFilter = utility_Billing:srcFilter
set run = utility_Billing-$stud.crun

#-| ---------------------------------------------------------------------------
#-| Copy source to grading directory, then move there.
#-| ---------------------------------------------------------------------------
cp $src $gradingDIR/
cd $gradingDIR/


#-| ---------------------------------------------------------------------------
#-| Verify testcase files needed for grading exist in directory.
#-| ---------------------------------------------------------------------------
if (-e $src) then
   @ first = 1
   @ TCmissing = 0
   foreach n ( 1 2 3 4 5 6 7 )
      if (-e utility_Billing:expf$n ) then
         if (-e utility_Billing:tcf$n ) then
            echo "TestCase $n found"
         else
            @ TCmissing++
            echo "TestCase $n tcf FILE NOT FOUND"
         endif
      else
         @ TCmissing++
         echo "TestCase $n expf FILE NOT FOUND"
      endif
   end
else
   echo "** BAD ERROR -- SOURCE FILE $src NOT FOUND **"
endif

#-| ---------------------------------------------------------------------------
#-| Write out header for grading report.
#-| ---------------------------------------------------------------------------
if (-e $g) rm $g
echo "-----------------------------------------------------" > $g
date >> $g
echo "-----------------------------------------------------" >> $g
echo "Grading Report for $stud" >> $g
echo "Assignment: PROG7" >> $g
echo "Program:    $src" >> $g
echo " " >> $g
echo "MAX Score = 63" >> $g
echo "Grading Deductions/Details: " >> $g
echo "-----------------------------------------------------" >> $g
echo " " >> $g

     # -----------------------------------------
P1:  #-| Check: MISSING ASSIGNMENT.
     # -----------------------------------------
echo "-------------------------------------------------------------" >> $g
echo "P1 - Program submission (0)"  >> $g
echo "-------------------------------------------------------------" >> $g
if (! -e $src) then
   echo "     -63  -> (Deduction Rationale: Source file $src NOT FOUND)"
   echo "     -63  -> (Deduction Rationale: Source file $src NOT FOUND)" >> $g
   @ score = $score - 63
   goto WRITESCORE
else
   echo "     +0  -> (Rationale: Assignment submitted)" >> $g
endif


if ( 1 == 0) then
   echo "SKIPPING COMPILATION STEP ... "
   repeat 1 echo " " >> $g
   echo "SKIPPING COMPILATION STEP ... " >> $g
   repeat 1 echo " " >> $g
   goto P3 
endif

COMPILE_SetUp:  # ================================= #
                # ================================= #

#-| ---------------------------------------------------------------------
#-| Check that the .cpp, .h and .o files needed to compile the source 
#-| program are in the directory where grading is being performed.
#-|
#-| NOTE: Files are either in the hidden grading directory (from stack),
#-|       or have been copied from student's project into grading directory.
#-| ---------------------------------------------------------------------

set CLEANUP_list = ( )
set includeF = (  )
@ missing = 0
foreach inclf ( $includeF )
  if (! -e $inclf) then
     echo "WARNING: MISSING INCLUDE file $inclf "
     @ missing++
  endif
end

set compileF = ( $src  )
set compileARGS = ( )

foreach compf ( $compileF )
  if (! -e $compf ) then
     echo "WARNING: MISSING compilation file $compf "
     @ missing++
  endif
end


if ($missing) then
   echo "RE-RUN after placing these files in the current directory ..."
   @ score = 0
   goto WRITESCORE 
endif

echo "COMPILER INPUT FILES: $compileF"
#echo -n "Hit ENTER to CONTINUE: "; set go = $<

     # -----------------------------------------
P2:  #-| Check: FAILURE TO COMPILE.
     # -----------------------------------------

echo "-------------------------------------------------------------" >> $g
echo "P2 - Program compilation (1)"  >> $g
echo "-------------------------------------------------------------" >> $g

csh ~/workspace/bin/filterSource.csh $src $srcFilter 
set complog = complog-$stud
if (-e $complog) rm -f $complog
g++ $compileF >& $complog
set nocompile = $status
if ($nocompile) then
   echo -n "     -1 -> (Deduction Rationale: DOES NOT COMPILE)" >> $g
   echo " - see compilation log below ..." >> $g
   echo -n "     -1  -> (Deduction Rationale: DOES NOT COMPILE)"
   echo " - see compilation log below ..." 

   echo "     **************************** " >> $g
   echo "     **************************** " >> $g
   sed 's/^/     /' $complog >> $g 
   echo "     **************************** " >> $g
   echo "     **************************** " >> $g

   @ score = $score - 1 

else
   echo "     +1  -> (Rationale: Successful compilation)" >> $g
   g++ $compileF -o $run
endif
if (-e $complog) rm -f $complog


     # ---------------------------------------------
P3:  #-| AUTO Check: DOCUMENTATION.
     # ---------------------------------------------

if (0 == 0) then
   echo "SKIPPING DOCUMENTATION CHECK STEP ... "
   repeat 1 echo " " >> $g
   echo "SKIPPING DOCUMENTATION CHECK STEP ... " >> $g
   repeat 1 echo " " >> $g
   goto P4 
endif

@ doc_maxpts = 0

echo "-------------------------------------------------------------" >> $g
echo "P3 - Quality of documentation ($doc_maxpts)" >> $g
echo "-------------------------------------------------------------" >> $g
echo "P3 - Quality of documentation ($doc_maxpts)" 
echo 

csh ~/workspace/bin/CheckDocnC.csh PROG7 utility_Billing $stud $doc_maxpts $g
@ docnpts = $status
@ docded = 0 - $docnpts
@ score = $score - $docded

#-- end P3

     # -----------------------------------------------------
P4:  #-| Check: EXECUTION output correctness and formatting.
     # -----------------------------------------------------

if (62 == 0) then
   echo "SKIPPING EXECUTION STEP ... "
   repeat 1 echo " " >> $g
   echo "SKIPPING EXECUTION STEP ... " >> $g
   repeat 1 echo " " >> $g
   goto WRITESCORE  
endif
     
echo "-------------------------------------------------------------" >> $g
echo "P4 - Execution Correctness and Layout (62)" >> $g
echo "-------------------------------------------------------------" >> $g
echo "P4 - Execution Correctness and Layout (62)" 
echo 
echo "" >> $g

if (! -e $run) then
   echo "      -62 (62)  -> (Deduction Rationale - NO EXECUTABLE PROGRAM FOUND.)"
   echo "      -62 (62)  -> (Deduction Rationale - NO EXECUTABLE PROGRAM FOUND.)" >> $g
   echo ""
   echo "" >> $g
   echo "       EXECUTION score = 0 / 62" >> $g
   echo "       EXECUTION score = 0 / 62" 

   @ score = $score - 62
   goto WRITESCORE
endif

echo "" >> $g

#-| ------------------------------------------------------------------
#-| Automated execution and scoring -- INTERACTIVE program.
#-| ------------------------------------------------------------------

csh ~/workspace/bin/CheckRunC.csh utility_Billing $stud $cor $g $inFile $outFile Codio
@ pts = $status
@ runded = $cor - $pts
@ score = $score - $runded


WRITESCORE:

#-| Print final score.
echo " " >> $g
echo "myPROG7:utility_Billing.cpp $stud SCORE = $score / 63  " >> $g
echo "myPROG7:utility_Billing.cpp $stud SCORE = $score / 63  " 
echo " " >> $g
echo "-----------------------------------------------------" >> $g

#-| ---------------------------------------------------------------------------
#-| Copy grading report to back to directory containing source file.
#-| ---------------------------------------------------------------------------
cp $g $curdir/
cd $curdir


goto STOPNOW
curl --retry 3 -s "$CODIO_AUTOGRADE_URL&grade=$score"
STOPNOW:
echo ""
echo "Grader gradeMy_utility_Billing.csh terminating ... "

exit 0

