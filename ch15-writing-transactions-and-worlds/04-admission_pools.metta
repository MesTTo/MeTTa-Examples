; Purpose: specify the shipped space-admission-verdict builtin in MeTTa, claim a
;   pool's pre-add hook with that chain, and hold the two to the same verdict.
; Guarantees: the chain and the builtin answer alike for a missing type, an
;   open pool, a full pool, an uncapped pool, and a pool with two capacity
;   rows, where the first row the count reaches decides.
; [tested: examples/ch15-writing-transactions-and-worlds/04-admission_pools.metta; commit=WORKTREE]

;(admits <pool> <type>) and (capacity <pool> <n>) in &metta are data: a pool
;is a space whose pre-add hook is claimed with a judge over them. The engine
;ships that judge as the builtin space-admission-verdict, Prolog-bodied by
;measurement, and this file is its executable specification: the same judge
;written in MeTTa, claimed through the same general hook, refusing and
;accepting the same atoms, with a differential asserting the two agree
;verdict for verdict.

;The MeTTa-bodied judge. Every declared admits type must be carried, the
;witness reading: an atom whose type nothing declares is not evidence that
;it is one of these, and a judge that let it in would admit everything a
;program never got round to declaring. The Atom masks keep the offered atom
;unreduced the whole way down: a pool judges the atom AS ITSELF.
(: metta-admission-verdict (-> %Undefined% Atom %Undefined%))
(= (metta-admission-verdict $pool $atom)
   (metta-admission-typed $pool $atom
      (collapse (match &metta (admits $pool $type) $type))))

(: metta-admission-typed (-> %Undefined% Atom %Undefined% %Undefined%))
(= (metta-admission-typed $pool $atom $types)
   (if (== $types ())
       (metta-admission-bounded $pool)
       (if (has-declared-type $atom (car-atom $types))
           (metta-admission-typed $pool $atom (cdr-atom $types))
           (Refuse (does-not-carry (car-atom $types))))))

(= (metta-admission-bounded $pool)
   (metta-admission-within $pool
      (collapse (match &metta (capacity $pool $limit) $limit))))

;space-atom-count is the store's own clause bookkeeping, a property read per
;add rather than an enumeration of everything the pool holds. Every capacity
;row binds, walked the way metta-admission-typed walks its types: the first
;limit the count has reached refuses, in the order the rows were added, and a
;pool that reaches none of them is admitted.
(= (metta-admission-within $pool $limits)
   (if (== $limits ())
       (Accept)
       (if (>= (space-atom-count $pool) (car-atom $limits))
           (Refuse (pool-at-capacity (car-atom $limits)))
           (metta-admission-within $pool (cdr-atom $limits)))))

;Contract atoms for one pool: Ticket-typed members, at most two of them.
!(add-atom &metta (admits &metta-pool Ticket))
!(add-atom &metta (capacity &metta-pool 2))
(: (ticket a) Ticket)
(: (ticket b) Ticket)

;The guard equation is one line, and the claim is the ordinary general hook:
;nothing about admission is special-cased in the engine's write path.
(= (metta-pool-guard $incoming) (metta-admission-verdict &metta-pool $incoming))
!(declare-pre-add! &metta-pool metta-pool-guard)

;A typed atom enters; an untyped one is refused naming the missing type.
!(add-atom &metta-pool (ticket a))
!(test (match &metta-pool (ticket $x) $x) a)
!(test (repr (catch (add-atom &metta-pool (stowaway 1))))
       "(Error (metta_add_refused &metta-pool (stowaway 1) (does-not-carry Ticket)) none)")

;The bound holds: the second ticket fills the pool and the third is refused.
!(add-atom &metta-pool (ticket b))
!(test (repr (catch (add-atom &metta-pool (ticket a))))
       "(Error (metta_add_refused &metta-pool (ticket a) (pool-at-capacity 2)) none)")

;The differential, across the judge's three verdict classes: the shipped
;builtin and the MeTTa chain answer the same verdict for the same pool and
;atom, which is what licenses the Prolog body as an implementation choice.
!(assertEqual (space-admission-verdict &metta-pool (stowaway 1))
              (metta-admission-verdict &metta-pool (stowaway 1)))
!(assertEqual (space-admission-verdict &metta-pool (ticket a))
              (metta-admission-verdict &metta-pool (ticket a)))
!(remove-atom &metta (capacity &metta-pool 2))
!(assertEqual (space-admission-verdict &metta-pool (ticket a))
              (metta-admission-verdict &metta-pool (ticket a)))
!(test (space-admission-verdict &metta-pool (ticket a)) (Accept))

;Two capacity rows, the second tighter than the first. The pool holds two
;tickets, under the first bound and at the second, so the second decides: the
;builtin reads every row and names the first one the count reaches, and a
;chain that tested only its first limit admitted what the builtin refused.
!(add-atom &metta (capacity &metta-pool 5))
!(add-atom &metta (capacity &metta-pool 2))
!(assertEqual (space-admission-verdict &metta-pool (ticket a))
              (metta-admission-verdict &metta-pool (ticket a)))
!(test (metta-admission-verdict &metta-pool (ticket a))
       (Refuse (pool-at-capacity 2)))
!(remove-atom &metta (capacity &metta-pool 5))
!(remove-atom &metta (capacity &metta-pool 2))
