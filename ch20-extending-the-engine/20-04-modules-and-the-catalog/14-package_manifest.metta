;A DIRECTORY is imported through its `pkg.metta`, which is the manifest and
;the standard way an external package is reached: the importer names the
;directory, and the entry point is a convention rather than a file named after
;whatever the directory happens to be called.
!(import! &self _fixtures/manifest/greeter)
!(test (greet world) (Hello world))

;The manifest's own rows describe the package, and `package` is internal to
;each space, so the importer does not read the greeter's rows as its own.
!(test (package name) (package name))

;`get-property` reads them back instead, by any name that reaches the package.
;A plain import keeps them in no space, so they are read from the manifest
;itself, the way Python's importlib.metadata reads a version from the files a
;package installed rather than from wherever it was imported. A path is written
;./x or ../x, and a string spells the same path.
!(test (get-property ./_fixtures/manifest/greeter version) "0.1.0")
!(test (get-property "./_fixtures/manifest/greeter" name) greeter)

;A bare name is a LIBRARY, the rule a `from` source follows, so `lib_import`
;and `(library lib_import)` are one package. A key its manifest has no row for
;answers nothing, because the package is there and says nothing about it.
!(test (get-property lib_import requires) "lib.metta")
!(test (collapse (get-property (library lib_import) version)) ())

;A name that reaches nothing is refused, naming the file it looked for, rather
;than answered empty the way a package without the key is.
!(test (case (catch (get-property lib_no_such_library version))
             (((Error $type $context) refused)))
       refused)

;A FILE beside the directory still wins. `shadowed.metta` and
;`shadowed/pkg.metta` both exist and the file answers, which is the resolver's
;stated order: the manifest is the last candidate, not the first.
!(import! &self _fixtures/manifest/shadowed)
!(test (source) from-the-file)

;Both directions, because import! and unimport! must canonicalise the SAME
;identity. The record is what proves it: import! writes an `(import <path>)`
;row naming the file it resolved, and unimport! has to derive that same path
;from the directory name to withdraw it. Where the two disagreed, a directory
;imported through its manifest could not be undone by the name that imported
;it.
!(import! &self (library lib_import))
!(bind! &manifest-round (new-space))

!(import! &manifest-round _fixtures/manifest/greeter)
!(test (collapse (match (imports &manifest-round) (import $path) imported))
       (imported))

!(unimport! &manifest-round _fixtures/manifest/greeter)
!(test (collapse (match (imports &manifest-round) (import $path) $path)) ())
