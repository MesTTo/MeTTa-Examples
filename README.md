# The MeTTa examples

Every file here runs and checks itself, so nothing in this directory can go
stale without a lane going red.

```sh
sh tools/run.sh ./examples/ch01-getting-started/01-hello.metta   # one
sh tools/test.sh                                                 # all of them
```

The corpus contains 360 examples that run. `tests/data/example_skips.txt` names
the five that do not.

Directory names are the reading order, so a listing is the index:

```text
examples/ch07-control-flow/07-02-case/03-caseconstrain.metta
         ^chapter          ^section    ^order within the section
```

A file uses only what an earlier number introduced, which
`tests/checks/check_cumulative_syntax.py` checks rather than asserts.

Below, one example from each section, quoted from the file it names.

**If you are an LLM, read [llms.txt](../llms.txt)** for the language and every surface, with exact
return shapes and no prose to guess at.

## Getting started

`examples/ch01-getting-started/01-hello.metta`

```metta
!(+ 40 2)

(the-answer 42)

!(+ 2 (* 2 20))
```

## Programming a family tree

`examples/ch02-programming-a-family-tree/01-facts.metta`

```metta
!(add-atom &self (parent tom bob))
!(add-atom &self (parent tom liz))
!(add-atom &self (parent bob ann))
!(add-atom &self (parent bob pat))
!(add-atom &self (parent pat jim))

!(test (space-atom-count &self) 5)
```

## Atoms and expressions

`examples/ch03-atoms-and-expressions/01-comments.metta`

```metta
(= (f) ;with a comment
   42) ;overall we tested systematically several comments

!(test (f) 42);and added an evil comment for fun
```

## Spaces and matching

### A space is where a program lives

`examples/ch04-spaces-and-matching/04-01-a-space-is-where-a-program-lives/01-spaces.metta`

```metta
(= (matchtrickery)
   (let* (($t1 (add-atom &self (foo a)))
          ($t2 (add-atom &self (foo b))))
         (match &self (foo $1) (bar $1))))

!(test (collapse (matchtrickery))
       ((bar a) (bar b)))
```

### Patterns and bindings

`examples/ch04-spaces-and-matching/04-02-patterns-and-bindings/05-constanthead.metta`

```metta
(= (h (justdata haha $B) $C)
   (+ $B $C))

!(test (h (justdata haha 30) 40) 70)
```

## Equations and evaluation

### An equation is a rewrite

`examples/ch05-equations-and-evaluation/05-01-an-equation-is-a-rewrite/09-multicall.metta`

```metta
(= (mycalc $x $y)
   (+ $x $y))

(= (mycalc $x $y)
   (- $x $y))

!(test (collapse (mycalc 1 2))
       (3 -1))
```

### Changing the equations

`examples/ch05-equations-and-evaluation/05-02-changing-the-equations/05-specialize_recursive_wrap.metta`

```metta
(= (derive $g) $g)
(= (twice $r $g) ($r ($r $g)))
(= (evolve $r $n $g) (if (== $n 0) $g (evolve (twice $r) (- $n 1) $g)))
!(test (evolve derive 2 stmt) stmt)
```

### The number library

`examples/ch05-equations-and-evaluation/05-03-the-number-library/02-math_exp_random.metta`

```metta
!(test (exp-math 0) 1.0)
!(test (exp-math 1.0) 2.718281828459045)
!(test (< (abs-math (- (exp-math 2.0) (* 2.718281828459045 2.718281828459045))) 1.0e-12) true)
!(test (< (abs-math (- (log-math 2.718281828459045 (exp-math 3.0)) 3.0)) 1.0e-12) true)

(= (in-range $lo $hi $x) (and (<= $lo $x) (<= $x $hi)))
!(test (in-range 1 6 (random-int 1 6)) true)
!(test (in-range 0.0 1.0 (random-float 0.0 1.0)) true)
!(test (in-range 5 5 (random-int 5 5)) true)
```

### Arithmetic that runs backwards

`examples/ch05-equations-and-evaluation/05-04-arithmetic-that-runs-backwards/04-relational_integer_division.metta`

```metta
!(test (#// 7 2) 3)
!(test (#div 7 2) 3)

!(test (#// -7 2) -3)
!(test (#div -7 2) -4)
!(test (#// 7 -2) -3)
!(test (#div 7 -2) -4)

!(test (+ (* (#div -7 2) 2) (#mod -7 2)) -7)
!(test (+ (* (#// -7 2) 2) (#mod -7 2)) -5)

!(test (let 3 (#// 7 $d) $d) 2)

!(test (let True (#< $n 7) (let 3 (#// $n 2) $n)) 6)
!(test (let True (#> $n 6) (let 3 (#// $n 2) $n)) 7)
```

## Many answers

`examples/ch06-many-answers/05-empty.metta`

```metta
(= (y) (empty))

!(test (collapse (y))
       ())
```

## Control flow

### If and booleans

`examples/ch07-control-flow/07-01-if-and-booleans/09-xor.metta`

```metta
(= (check_xor $source $destination)
   (if (xor (== $source $destination)
            (> $source $destination))
            42
            0))

!(test (check_xor 2 2) 42)
!(test (check_xor 4 2) 42)
```

### Case

`examples/ch07-control-flow/07-02-case/01-case.metta`

```metta
(= (casetest $x)
   (case $x ((4 42)
             ($otherpattern 44)
             ($otherother $45))))

!(test (casetest 5) 44)
```

### Let and sequencing

`examples/ch07-control-flow/07-03-let-and-sequencing/06-chain.metta`

```metta
!(test (chain (+ 2 4) $n (* 3 $n))
       18)

!(test (chain (+ 1 3) $n (chain (* 2 $n) $m (+ $n $m)))
       12)
```

### Bounded and committed searches

`examples/ch07-control-flow/07-04-bounded-and-committed-searches/07-foldallspacecount.metta`

```metta
(foo 1)
(foo 2)
(foo 3)

(= (countitem) (let $x (match &self (foo $1) (foo $1)) 1))
(= (merge $a $b) (+ $a $b))
(= (spacecount $x) (foldall merge (countitem) 0))

!(test (foldall merge (countitem) 0) 3)
```

### Recursion

`examples/ch07-control-flow/07-05-recursion/01-factorial.metta`

```metta
(= (facF $n)
   (if (== $n 0)
       1
       (* $n (facF (- $n 1)))))

!(test (facF 10) 3628800)
```

## Data

### Atoms lists and folds

`examples/ch08-data/08-01-atoms-lists-and-folds/01-nestedcons.metta`

```metta
(= (f (cons $a (cons $b $L)))
   $b)

!(test (f (a b c d)) b)
```

### Sequence variables

`examples/ch08-data/08-02-sequence-variables/03-the-one-sided-fragment.metta`

```metta
!(test (collapse (let ((:seg $pre) SEP (:seg $post)) (a b SEP c SEP d)
                      (pair $pre $post)))
       ((pair (a b) (c SEP d)) (pair (a b SEP c) (d))))

!(test (let (row (:seg $r)) (row) $r) ())
!(test (let (row (:seg $r)) (row a b c) $r) (a b c))

!(test (get-metatype (let (row (:seg $r)) (row a b) $r)) Expression)
!(test (size-atom (let (row (:seg $r)) (row a b) $r)) 2)
!(test (car-atom (let (row (:seg $r)) (row a b) $r)) a)

!(test (let (f (:seg $x) g (:seg $x)) (f a b g a b) $x) (a b))
!(test (collapse (let (f (:seg $x) g (:seg $x)) (f a b g c) $x)) ())
!(test (let (f (:seg $x) g (:seg $x)) (f 1 g 1.0) took) took)

!(test (collapse (let (f ... g ...) (f a g b c) done)) (done))

!(test (let (f (g ...) b) (f (g 1 2) b) nested) nested)
!(test (collapse (let (A ... D) (A b c E) never)) ())

!(add-atom &self (edge a b))
!(add-atom &self (edge b c d))
!(add-atom &self (tag b hot))
!(test (collapse (match &self (edge a ... $last) $last)) (b))
!(test (collapse (match &self (, (edge ... $mid) (tag $mid $heat)) ($mid $heat)))
       ((b hot)))
```

### The shipped libraries

`examples/ch08-data/08-03-the-shipped-libraries/01-library.metta`

```metta
!(import! &self (library lib_roman))

!(test (map-flat (+ 1) (1 2 3)) (2 3 4))
```

## Types

`examples/ch09-types/06-dont_eval_type.metta`

```metta
(: OpaquePayload DontEvalType)
(: inspect-opaque (-> OpaquePayload Symbol))
(= (inspect-opaque $written) (get-metatype $written))

!(test (inspect-opaque (+ 1 2)) Expression)
```

## Errors and refusals

`examples/ch10-errors-and-refusals/02-throwing_and_tracing.metta`

```metta
!(test (throw (my-ball 1)) (Error (throw (my-ball 1)) (my-ball 1)))
!(test (throw "text") (Error (throw "text") "text"))

!(test (if-error (throw oops) caught fine) caught)
!(test (if-error 42 caught fine) fine)
!(test (return-on-error (throw oops) carried-on) (Error (throw oops) oops))
!(test (return-on-error 42 carried-on) carried-on)

!(test (throw (Error (inner 1) because)) (Error (inner 1) because))
!(test (throw (throw first)) (Error (throw first) first))

(= (half $n) (if (== (% $n 2) 0) (/ $n 2) (throw (odd $n))))
!(test (half 10) 5)
!(test (half 7) (Error (throw (odd 7)) (odd 7)))
!(test (if-error (half 7) refused (half 7)) refused)

!(test (trace! "the answer" 42) 42)
!(test (+ 1 (trace! "adding one to" 41)) 42)
!(test (trace! (half 10) (half 10)) 5)

!(test (trace! (checking (odd 7)) ok) ok)
```

## Python as a notation

`examples/ch11-python-as-a-notation/02-python_booleans.metta`

```metta
!(test (repr (py-call (str true))) "True")
!(test (repr (py-call (str false))) "False")
!(test (py-call (sorted (true false))) (false true))
!(test (py-call (len (true false true))) 3)
!(test (py-call (isinstance true (py-call (type false)))) true)
!(test (py-call (bool 1)) true)
!(test (py-call (bool 0)) false)
!(test (py-call (.bit_length true)) 1)
!(test (repr (py-call (.upper abc))) "ABC")
```

## Testing

`examples/ch12-testing/02-he_equalreduct.metta`

```metta
!(import! &self (library lib_he))

(= (add 1 2) 3)

!(test (id 5) 5)

!(test (=alpha (Father $X) (Father $Y)) True)

!(test (=alpha (Father $X) (Son $X)) False)

!(test (if-equal 1 1 "Equal" "Not Equal") "Equal")
```

## Seeing your program

`examples/ch14-seeing-your-program/03-the_clock_and_the_command_line.metta`

```metta
!(import! &self (library lib_string))

!(test (> (current-time) 1700000000.0) True)

!(test (<= (current-time) (current-time)) True)

!(test (format-time "abc") abc)
!(test (== (format-time "abc") "abc") False)
!(test (string-length (format-time "a literal")) 9)
!(test (string-length (format-time "")) 0)
!(test (string-length (format-time "%%")) 1)

!(test (string-length (format-time "%Y")) 4)
!(test (string-length (format-time "%Y-%m-%d")) 10)
!(test (string-length (format-time "%H:%M:%S")) 8)

!(test (collapse (argv 999)) ())
!(test (collapse (argv -1)) ())

!(test (== (argv 0) (argv 0)) True)

(= (argument-or $index $default)
   (let $found (collapse (argv $index))
        (if (== $found ()) $default (car-atom $found))))
!(test (argument-or 999 no-such-argument) no-such-argument)
!(test (== (argument-or 0 no-such-argument) no-such-argument) False)
```

## Writing transactions and worlds

`examples/ch15-writing-transactions-and-worlds/02-state.metta`

```metta
!(bind! state (new-state rest))
!(test (get-state state) rest)

!(test (change-state! state active) true)
!(test (get-state state) active)

!(test (get-type (new-state 5)) (StateMonad Number))
!(test (get-type (new-state "hi")) (StateMonad String))

!(test (let $cell (new-state 1)
            (let $_ (change-state! $cell 2) (get-state $cell)))
       2)
```

## Events and standing queries

`examples/ch16-events-and-standing-queries/01-event_catalog.metta`

```metta
!(test (match &metta (vocabulary delivery $a $b $c) ($a $b $c))
       (at-most-once at-least-once per-write-exactly))
!(test (match &metta (vocabulary event-order $a $b) ($a $b))
       (ordered unordered))
!(test (match &metta (kind events $ctx $delivery $order) $delivery)
       (one-of delivery))

!(test (if-error (catch (add-atom &metta (events &feed eventually)))
                 refused admitted)
       refused)

!(add-atom &native-events (reading 1))
!(test (collapse (match &metta (events &native-events $d $o) declared)) ())

!(test (match &metta (vocabulary agenda-policy $a $b $c $d $e) ($a $b $c $d $e))
       (declaration recency specificity priority user))
!(test (match &metta (policy reaction-order $knob $default) ($knob $default))
       (agenda declaration))
!(test (match &metta (kind agenda $ctx $policy $fn) $policy)
       (one-of agenda-policy))

!(test (match &metta (kind on $ctx $pattern $op $priority) $priority)
       (optional integer))
```

## Concurrency and the loop

`examples/ch17-concurrency-and-the-loop/09-class_values.metta`

```metta
!(add-atom &Point (: Point (-> Number Number Point)))
!(add-atom &Point (= (Point-x (Point $x $y)) $x))
!(add-atom &Point (= (Point-y (Point $x $y)) $y))

!(add-atom &Point
  (= (Point-norm (Point $x $y)) (sqrt-math (+ (* $x $x) (* $y $y)))))

!(add-atom &Point
  (= (Point-add (Point $x1 $y1) (Point $x2 $y2)) (Point (+ $x1 $x2) (+ $y1 $y2))))

!(add-atom &Point
  (= (Point-quadrant $p)
     (case $p (((Point 0 0) origin) ((Point 0 $y) axis) ((Point $x $y) plane)))))

!(add-atom &self (from &Point))

!(test (Point-norm (Point 3 4)) 5.0)
!(test (Point-add (Point 1 2) (Point 3 4)) (Point 4 6))
!(test (Point-quadrant (Point 0 0)) origin)
!(test (Point-quadrant (Point 0 4)) axis)
!(test (Point-quadrant (Point 3 4)) plane)
!(test (== (Point-add (Point 1 2) (Point 3 4)) (Point 4 6)) True)
```

## Performance

### Larger workloads

`examples/ch18-performance/18-01-larger-workloads/04-peanofast.metta`

```metta
(= (expandK $expression $n)
   (if (== $n 0)
       done
       (let $temp1 (add-atom &self (num $expression))
            (expandK (S $expression) (- $n 1)))))

(= (demo-peano $K)
   (expandK Z $K))

!(demo-peano 2500)
!(test (length (collapse (match &self (num $1) $1))) 2500)
```

### Memoisation and tabling

`examples/ch18-performance/18-02-memoisation-and-tabling/06-memo_dependency_invalidation.metta`

```metta
!(import! &self (library lib_memo))

!(memoize double)
(= (double $x) (+ $x $x))

!(test (double 5) 10)
!(test (double 5) 10)
```

## Spaces backed by anything

### Spaces of your own

`examples/ch19-spaces-backed-by-anything/19-01-spaces-of-your-own/01-inherited_spaces.metta`

```metta
!(add-atom &family-parent (edge a b))
!(add-atom &family-parent (parent-only kept))
!(add-atom &family-parent (layer parent))
!(new-space &family-child (inherits &family-parent))
!(add-atom &family-child (edge b c))
!(add-atom &family-child (child-only local))
!(add-atom &family-child (layer child))

!(test (collapse (match &family-child
                         (, (edge $x $y) (edge $y $z))
                         ($x $z)))
       ((a c)))

!(test (collapse (match &family-child (layer $x) $x)) (child parent))
!(test (space-atom-count &family-child) 3)

!(test (collapse (match &family-parent (parent-only $x) $x)) (kept))
!(test (collapse (match &family-child (parent-only $x) $x)) (kept))
!(test (collapse (match &family-parent (child-only $x) $x)) ())
```

### A space in c

`examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/01-c_space.metta`

```metta
!(import! &self (library lib_import))
!(import! &self (library lib_file))
!(import! &self (library lib_conformance))

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.so")
     (let "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.pl" (consult_global) provider)
     (println! "SKIPPED c_space: cstore.so is not built, see the README beside this file"))

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.so")
     (progn (add-atom &cstore (edge a b))
            (add-atom &cstore (edge a c))
            (add-atom &cstore (edge b c))
            (test (collapse (match &cstore (edge a $x) $x)) (b c)))
     True)

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.so")
     (progn (remove-atom &cstore (edge a $any))
            (test (collapse (match &cstore (edge $x $y) ($x $y))) ((b c))))
     True)

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.so")
     (progn (add-atom &cstore (dup 1))
            (add-atom &cstore (dup 1))
            (add-atom &cstore (dup 1))
            (remove-atom &cstore (dup 1))
            (test (let $answers (collapse (match &cstore (dup $n) $n))
                    (size-atom $answers))
                  0)
            (test (remove-atom &cstore (dup 1)) True))
     True)

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.so")
     (test (check-space-provider &cstore)
           ("enumerate: declared, seam:foreign_atoms/2 has clauses"
            "add: declared, seam:foreign_add/2 has clauses"
            "remove: declared, seam:foreign_remove/3 has clauses"
            "clear: declared, seam:foreign_clear/1 has clauses"
            "match: over-approximation holds over 1 atoms and their pattern families"
            "source: repeated, two enumerations agree"
            "round trip: add then enumerate answers the atom, and remove takes it back"
            "pushdown: 0 of 1 patterns claimed exact, and are"
            "plan: not declared, so a conjunction takes the engine's split"))
     True)

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-02-a-space-in-c/cstore.so")
     (progn (collapse (hyperpose ((add-atom &cstore (row 1))
                                  (add-atom &cstore (row 2))
                                  (add-atom &cstore (row 3))
                                  (add-atom &cstore (row 4)))))
            (test (let $answers (collapse (match &cstore (row $n) $n))
                    (size-atom $answers))
                  4))
     True)
```

### A builtin in c

`examples/ch19-spaces-backed-by-anything/19-03-a-builtin-in-c/01-c_extension.metta`

```metta
!(import! &self (library lib_import))
!(import! &self (library lib_file))

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-03-a-builtin-in-c/cbump.so")
     (import_prolog_functions_from_file
        "./examples/ch19-spaces-backed-by-anything/19-03-a-builtin-in-c/loader.pl" (c-bump))
     (println! "SKIPPED c_extension: cbump.so is not built, see the README beside this file"))

!(if (file-exists "./examples/ch19-spaces-backed-by-anything/19-03-a-builtin-in-c/cbump.so")
     (test (eval (c-bump 41)) 42)
     True)
```

### A space on mork

`examples/ch19-spaces-backed-by-anything/19-04-a-space-on-mork/01-mm2-operators.metta`

```metta
!(import! &self (library lib_file))

!(test (repr (catch (require-extension! nosuchseat)))
       "(Error (metta_extension_required nosuchseat unknown) none)")

!(test (require-extension! python) ())

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (import! &self (library lib_mm2))
     (println! "SKIPPED mm2-operators: libmork_ffi.so is not built, see extensions/mork/build.sh"))

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (progn (＋ (edge a b))
            (test (sort-atom (collapse (? (edge $x $y) ($x $y)))) ((a b)))
            (－ (edge a b))
            (test (collapse (? (edge $x $y) ($x $y))) ()))
     True)

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (progn (＋* ((edge a b) (edge b c) (edge c d)))
            (test (sort-atom (collapse (? (edge $x $y) ($x $y))))
                  ((a b) (b c) (c d))))
     True)

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (progn (mork-add-atoms &mork ((tag 1) (tag 2)))
            (mork-flush &mork)
            (test (sort-atom (collapse (? (tag $n) $n))) (1 2)))
     True)

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (progn (~> (, (edge $x $y)) (O (+ (path $x $y))))
            (test (sort-atom (collapse (? (path $x $y) ($x $y))))
                  ((a b) (b c) (c d))))
     True)

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (progn (~> (, (path $x $y)) (O (- (path $x $y)) (+ (route $x $y))))
            (mm2-exec &mork 1)
            (test (sort-atom (collapse (? (route $x $y) ($x $y))))
                  ((a b) (b c) (c d)))
            (test (collapse (? (path $x $y) ($x $y))) ()))
     True)

!(if (file-exists "./extensions/mork/mork_ffi/target/release/libmork_ffi.so")
     (progn (collapse (let ($x $y) (? (edge $x $y) ($x $y)) (－ (edge $x $y))))
            (collapse (let ($x $y) (? (route $x $y) ($x $y)) (－ (route $x $y))))
            (collapse (let $n (? (tag $n) $n) (－ (tag $n))))
            True)
     True)
```

## Extending the engine

### Translator rules

`examples/ch20-extending-the-engine/20-01-translator-rules/01-translatorrule.metta`

```metta
(= (runtime42 $arg)
   (cons 42 $arg))

(= (compileeval42 $arg)
   (cons 42 $arg))

(= (compile42 $arg)
   (noeval (cons 42 $arg)))

!(add-translator-rule! compileeval42)
!(add-translator-rule! compile42)

!(test (runtime42 (43)) (42 43))
!(test (compileeval42 (43)) (42 43))
!(test (compile42 (43)) (42 43))
```

### Metta written in metta

`examples/ch20-extending-the-engine/20-02-metta-written-in-metta/03-myinterpreter.metta`

```metta
(: myinterpreter (-> Atom %Undefined%))
(= (myinterpreter $code)
   (let $temp (println! ("Runtime-interpreting code" $code))
        (eval $code)))

(= (w) 42)
(= (v) 43)

!(test (myinterpreter (if (== 1 1) (w) (v))) 42)
!(test (myinterpreter (if (== 1 2) (w) (v))) 43)
```

### Prolog underneath

`examples/ch20-extending-the-engine/20-03-prolog-underneath/01-translatepredicate.metta`

```metta
!(test (progn (translatePredicate (is $x 2))
              (translatePredicate (+ $x 40 $z)) $z)
       42)
```

### Modules and the catalog

`examples/ch20-extending-the-engine/20-04-modules-and-the-catalog/04-import_error_surface.metta`

```metta
!(import! &self (library lib_he))

!(test (if-error (catch (import! &self _fixtures/imports/import_error_broken))
                 Error
                 NoError)
       Error)

!(test (if-error (catch (import! &self _fixtures/imports/definitely_missing_import))
                 Error
                 NoError)
       Error)
```

### Observing execution

`examples/ch20-extending-the-engine/20-05-observing-execution/02-source-coverage.metta`

```metta
!(import! &self (library lib_observe))
!(bind! &coverage (observe-source &self "branches.metta" "(= (choose $flag $x)\n  (if $flag\n    (+ $x 2)\n    (+ $x 2)))\n!(choose True 1)"))
!(test (match &coverage (observation-status $status) $status) complete)
!(test (match &coverage (observation-answer 0 $answer) $answer) 3)
!(test (match &coverage (source-coverage "branches.metta" 3 5 3 13 $hits) (> $hits 0)) True)
!(test (match &coverage (source-coverage "branches.metta" 4 5 4 13 $hits) $hits) 0)
```

### Files and processes

`examples/ch20-extending-the-engine/20-06-files-and-processes/03-a-fresh-directory.metta`

```metta
!(import! &self (library lib_file))

!(bind! &work (temp-dir! "fresh-directory"))
!(test (dir-exists &work) True)
!(test (list-dir! &work) ())

!(bind! &report (path-join &work "report.txt"))
!(test (write-file! &report "one line\n") True)
!(test (list-dir! &work) ("report.txt"))
!(test (match (file-metadata! &report) (kind $kind) $kind) file)

!(test (if-error (catch (temp-dir! "logs/run")) refused fine) refused)

!(test (delete-file! &report) True)
!(test (delete-dir! &work) True)
!(test (dir-exists &work) False)
```

### Tokens and the reader

`examples/ch20-extending-the-engine/20-07-tokens-and-the-reader/01-reader-tokens.metta`

```metta
!(test (repr (parse "12px")) "12px")

!(test (register-token! "[0-9]+px" Pixels) True)

!(test (repr (parse "12px")) "(Pixels \"12px\")")

!(test (repr (parse "(width 12px)")) "(width (Pixels \"12px\"))")
!(test (repr (parse "(box 12px 4px)")) "(box (Pixels \"12px\") (Pixels \"4px\"))")

!(test (repr (parse "12pxy")) "12pxy")
!(test (repr (parse "px")) "px")

!(test (register-token! "[0-9]+%" Percent) True)
!(test (repr (parse "(size 50% 12px)"))
       "(size (Percent \"50%\") (Pixels \"12px\"))")

!(test (register-token! "[0-9]+px" Device) True)
!(test (repr (parse "12px")) "(Device \"12px\")")

!(test (unregister-token! "[0-9]+px") True)
!(test (repr (parse "12px")) "12px")
!(test (unregister-token! "[0-9]+px") True)
!(test (repr (parse "50%")) "(Percent \"50%\")")
!(test (unregister-token! "[0-9]+%") True)
!(test (repr (parse "50%")) "50%")

!(test (repr (catch (register-token! 12 Pixels)))
       "(Error (type_error text 12) (context register-token! a token pattern is text))")

!(test (repr (catch (register-token! "[0-9]+em" "not a symbol")))
       "(Error (domain_error metta_reader_constructor \"not a symbol\") (context (/ register-token! 3) the constructor must be a readable symbol))")
```

### Csv row spaces

`examples/ch20-extending-the-engine/20-08-csv-row-spaces/01-csv-space.metta`

```metta
!(import! &self (library lib_csv))
!(import! &self (library lib_file))

!(bind! &csv-path (temp-path! "metta-csv-example"))
!(write-file! &csv-path "id,amount\n001,12.50\n002,9\n002,9\n")
!(bind! &sales (csv-space &csv-path))

!(test (collapse (match &sales (row $id $amount) ($id $amount)))
       (("id" "amount") ("001" "12.50") ("002" "9") ("002" "9")))
!(test (match &sales (row "001" $amount) (parse-number $amount)) 12.5)

!(write-file! &csv-path "003,42\n")
!(test (collapse (match &sales (row $id $amount) ($id $amount)))
       (("003" "42")))
!(delete-file! &csv-path)
```

## A reasoner you can serve

### Logic programs

`examples/ch22-a-reasoner-you-can-serve/22-01-logic-programs/02-logicprogset.metta`

```metta
(= (myf $M)
   (and (and (member a $M)
             (member b $M))
        (== (size-atom $M) 2)))

!(test (if (once (myf $M)) $M)
       (a b))
```

### Weighted answers

`examples/ch22-a-reasoner-you-can-serve/22-02-weighted-answers/06-pln_roman.metta`

```metta
!(import! &self (library lib_pln))

(= (STV A) (stv 0.5 0.9))
(= (STV B) (stv 0.25 0.9))
(= (STV C) (stv 0.25 0.9))
(= (STV D) (stv 0.5 0.9))

(= (kb)
   ((Sentence ((Inheritance A B) (stv 0.25 0.9)) (1))
    (Sentence ((Inheritance A C) (stv 0.25 0.9)) (2))
    (Sentence ((Inheritance B D) (stv 0.5 0.9)) (3))
    (Sentence ((Inheritance C D) (stv 0.5 0.9)) (4))
   ))

!(test (with-pragma! ((max-stack-depth 100000000))
                     (PLN.Query (kb) (Inheritance A D)))
       ((stv 0.5 0.9473684210526316) (1 2 3 4)))
```

### Search

`examples/ch22-a-reasoner-you-can-serve/22-03-search/05-fibadd.metta`

```metta
!(add-atom &self (= (fib $N)
                    (if (< $N 2)
                        $N
                        (+ (fib (- $N 1))
                           (fib (- $N 2))))))

!(test (with-pragma! ((max-stack-depth 100000000)) (fib 30)) 832040)
```

## Origins

143 of the 365 programs here derive from the MeTTa examples of the project at
https://github.com/patham9/PeTTa, MIT licensed, at commit
`43705f5d9ff8958ffe7f0aa6777fb8477f2401f2` (2026-07-24). They were reorganised
into the reading order above, and some were edited. 13 people wrote them
there, most of them Patrick Hammer; the rest are credited file by file, because
naming only the most prolific contributor would miscredit the others. The other
242 examples were written for this repository.

`ORIGINS.tsv` names every derived file beside the upstream file it came from,
how much of the original body survives with comments ignored, and who wrote it
upstream. That list is derived rather than remembered:
`extensions/python/tools/example_origins.py --write` recomputes it by comparing
bodies against the upstream checkout, and the same tool without `--write`
answers nonzero when the committed list has stopped describing the directory.
