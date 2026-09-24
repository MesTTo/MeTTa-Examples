; Purpose: inspect a failing subterm and distinguish a generated closure's origin.
!(import! &self (library lib_observe))
!(bind! &errors (observe-source &self "division.metta" "(= (divide $x)\n  (+ 1 (/ 1 $x)))\n(= (caller $x)\n  (+ 2 (divide $x)))\n!(caller 0)"))
!(test (match &errors (source-error $id (Error (/ 1 0) DivisionByZero)) found) found)
!(test (match &errors (source-error $id (Error (/ 1 0) DivisionByZero))
  (match &errors (source-frame $id $depth divide "division.metta" 2 8 2 16 exact) located)) located)
!(test (match &errors (source-error $id (Error (/ 1 0) DivisionByZero))
  (match &errors (source-frame $id $depth caller "division.metta" 4 8 4 19 exact) located)) located)
;The division's native exception is recorded as text too, and the text is a
;function of the exception alone: its unbound context variable prints as _,
;whatever the engine ran before it, so a second observation of this source
;records the same text.
!(test (match &errors (source-error $id "error(evaluation_error(zero_divisor),context((/)/2,_))") recorded) recorded)
!(bind! &generated (observe-source &self "generated.metta" "(= (collect $x)\n  (collapse (+ 1 (/ 1 $x))))\n!(collect 0)"))
!(test (match &generated (source-error $id (Error (/ 1 0) DivisionByZero))
  (match &generated (source-frame $id $depth $function "generated.metta" $line $column $end-line $end-column (generated-by collapse)) explained)) explained)
