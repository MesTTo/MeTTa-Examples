;The declarative spelling of the file before this one. Where
;`import_prolog_functions_from_file` REGISTERS names, a package says what a
;library is as equations, and two heads perform what it says.
;
;`(= (package backing) (prolog File (heads)))` is the row a library writes to
;declare which heads its artifact exports. `package-prolog` is what performs
;that row: it loads the file and registers exactly the names the row lists.
;`setup!` is the other half, performing a package file's rows and publishing a
;receipt beside it so a second run reuses the work rather than repeating it.
!(import! &self (library lib_file))

;The row lists two of the three heads the artifact defines, so the third stays
;the artifact's own. Registration is a load-time effect: the heads are callable
;from here on, which is why this is a top-level form rather than a step inside
;a function whose body was compiled before it ran.
!(package-prolog "./examples/ch20-extending-the-engine/20-03-prolog-underneath/_fixtures/package_backing.pl" (greeting doubled))

;A Prolog clause of arity N+1 is a MeTTa function of arity N, its last argument
;the answer.
!(test (greeting) hello)
!(test (doubled 21) 42)

;`unlisted` is defined in the same file and absent from the row, so nothing
;registered it and it stays an ordinary expression.
!(test (unlisted) (unlisted))

;setup! performs a package file's rows. This one writes its package into a
;temporary directory the scope owns, because publishing a receipt is a real
;effect and an example may not leave one in the tree.
(= (a-package-of-our-own $work)
   (let* (($file (path-join $work "package.metta"))
          ($written (write-file! $file "(= (package name) example)")))
     (setup! $file)))

!(test (with-temp-dir "package-rows" a-package-of-our-own) True)
