; Purpose: claim a space's pre-add hook for one function and show its four
;   verdicts, (Accept), (Accept <atom>), (Refuse <words>) and (Drop).
; [tested: examples/ch15-writing-transactions-and-worlds/03-pre_add_hooks.metta; commit=WORKTREE]

;A pre-add hook claims the write door of one space for one function of one
;argument, the incoming atom. Every write into the claimed space consults it
;first, and the handler answers with one of four verdicts: (Accept) lets the
;atom in as offered, (Accept <atom>) lets a TRANSFORMED atom in instead,
;(Refuse <words>) throws carrying the handler's own words, and (Drop)
;skips the write silently while the caller sees success. This is the general
;mechanism behind capacity and admission: arbitrary MeTTa deciding what a
;space contains.
;The verdicts are capitalized, the way MeTTa writes its data and control
;values (True, Empty, Error). A lowercase (drop) would be a CALL wherever a
;library defines drop, lib_functional's list drop among them, and a handler
;answering it there would stop covering the atom it was written for.

(= (guard (secret $x)) (Refuse "no secrets in this pool"))
(= (guard (raw $x)) (Accept (cooked $x)))
(= (guard (dup $x)) (Drop))
(= (guard (plain $x)) (Accept))

!(declare-pre-add! &pool guard)

;An accepted atom lands as offered.
!(add-atom &pool (plain 1))
!(test (match &pool (plain $x) $x) 1)

;A transformed atom lands in the handler's chosen form. The handler's output
;is the granted form and is not re-asked: one decision per request, the way
;a database BEFORE trigger's modified row does not re-fire the trigger. A
;handler that wants chained rewriting composes it in its own body.
!(add-atom &pool (raw 7))
!(test (match &pool (cooked $x) $x) 7)

;A dropped atom is skipped and the caller sees the success an accepted add
;answers, which is how set semantics is written as a rule.
!(add-atom &pool (dup 3))
!(test (collapse (match &pool (dup $x) $x)) ())

;A refusal carries the handler's own sentence to the caller.
!(test (repr (catch (add-atom &pool (secret 1))))
       "(Error (metta_add_refused &pool (secret 1) \"no secrets in this pool\") none)")

;A claimed handler whose equations do not cover the atom is a stuck state
;that says so, naming the space, the slot, the handler and the atom. Nothing
;is silently admitted and nothing silently vanishes; a handler that wants a
;default writes its own catch-all equation, one visible line.
!(test (repr (catch (add-atom &pool (uncovered 9))))
       "(Error (metta_hook_stuck &pool pre-add guard (uncovered 9)) none)")

;One claimant per name, checked when the claim is made: a second claimant is
;refused with both named, never raced at call time.
(= (other-guard $a) (Accept))
!(test (repr (catch (declare-pre-add! &pool other-guard)))
       "(Error (metta_hook_conflict &pool pre-add guard other-guard) none)")

;Undeclaring is explicit and frees the claim; the space is direct again.
!(undeclare-pre-add! &pool)
!(add-atom &pool (uncovered 10))
!(test (match &pool (uncovered $x) $x) 10)
