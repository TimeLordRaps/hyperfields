import Std

/-!
# Finite sets over an explicit carrier

The five candidate field modules all need the same small vocabulary: a
finite set of points drawn from a carrier of known size, membership,
union, intersection, and difference.

The representation is a list of carrier elements with duplicates removed.
That is a deliberate choice rather than an accident of what Lean 4 core
happens to provide:

* Lean 4 core has no `Finset`. Its `Set` is an unbounded predicate, which
  cannot be decided and therefore cannot support `by decide` proofs.
* `Std.HashSet` exists, but its `contains` does not reduce for `decide`:
  the hash lookup is opaque to the kernel's evaluator. A port whose whole
  point is machine-checked finite consistency cannot rest on a predicate
  the compiler will not reduce.

A list does reduce. Membership is `List.any` with a decidable equality,
union is a fold that appends only new elements, and intersection is a
filter. Every one of those reduces, so `by decide` works over them.

The carrier is `Fin n`, so the number of points is fixed by the type and a
structure over it is decidable without any further work.
-/

namespace Hyperfields.Finite

/-!
## Membership
-/

-- L4DEL: title: Membership in a finite set
-- L4DEL: intuition: A finite set is a list without duplicates, so membership is a decidable scan rather than an unbounded predicate.
/--
Whether an element belongs to a finite set.

The carrier's equality is decidable, so membership is decidable and the
compiler can reduce it.
-/
def mem {α : Type} [BEq α] (x : α) (xs : List α) : Bool :=
  xs.any (fun y => y == x)

-- L4DEL: title: Every member of a finite set is distinct
-- L4DEL: intuition: A set that listed the same point twice would have a different size than its content, so duplicates are removed.
/--
Remove duplicates from a list, keeping the first occurrence of each element.

This is what makes a finite set a set: `List.eraseDups` guarantees that
two equal lists describe the same collection, so a list of opens is
compared by content rather than by how it was written.
-/
def toSet {α : Type} [BEq α] (xs : List α) : List α :=
  List.eraseDups xs

/-!
## Canonical ordering

A finite set is a list, and a list has an order.  Two lists with the same
members in different orders are the same set, so every set operation in
this module canonicalises its result.  Without that, `union [1] [0]` and
`union [0] [1]` would be different lists, and a frame that is closed under
union would be closed under an operation whose result depends on how the
operands were written.
-/

-- L4DEL: title: Inserting an element into a sorted list
-- L4DEL: intuition: Insertion keeps the list ordered, so a sorted list is the canonical form of a finite set.
/--
Insert an element into an ordered list, keeping the list ordered.

This is insertion sort rather than `List.mergeSort` on purpose.  The
carrier is always tiny, but `mergeSort` allocates and recurses in a way
that makes the kernel's evaluator give up before it can reduce a decision
procedure over a topology's axioms.  Insertion sort reduces in a fraction
of the depth, which is what makes `by decide` usable here.
-/
def insertOrdered {α : Type} [BEq α] (le : α → α → Bool) (x : α) (xs : List α) : List α :=
  match xs with
  | [] => [x]
  | y :: ys => if le x y then x :: xs else y :: insertOrdered le x ys

-- L4DEL: title: Canonical ordering of a finite set
-- L4DEL: intuition: A set has one order, and canonicalising is what lets two descriptions of the same set be compared.
/--
Order a list so that equal contents give equal lists.

The ordering is an explicit argument rather than a typeclass instance, so
the ordering in force is visible at every call site.
-/
def canonical {α : Type} [BEq α] (le : α → α → Bool) : List α → List α
  | [] => []
  | x :: xs => insertOrdered le x (canonical le xs)

/-!
## The lattice operations
-/

-- L4DEL: title: Union of two finite sets
-- L4DEL: intuition: Union adds what the other set has and keeps what both already share, so no point is counted twice.
/--
The union of two finite sets.

The result is sorted so that the union does not depend on which operand was
named first.  A union that returned `ys`'s elements before `xs`'s would
still have the right *membership* but the wrong *list*, and a topology that
is closed under union has to be closed under the operation the frame
actually uses.

The ordering is an explicit argument rather than a typeclass instance.
That keeps the operation total for any carrier the caller can order, and it
keeps the caller's ordering visible at the call site, which matters because
a *different* order would give a different list.
-/
def union {α : Type} [BEq α] (le : α → α → Bool) (xs ys : List α) : List α :=
  (canonical le (ys ++ xs)).eraseDups

-- L4DEL: title: Intersection of two finite sets
-- L4DEL: intuition: Intersection keeps exactly the points both sets name, so it is the filter of one by the other.
/--
The intersection of two finite sets.

Like `union`, the result is sorted, so the intersection does not depend on
which operand was named first.
-/
def inter {α : Type} [BEq α] (le : α → α → Bool) (xs ys : List α) : List α :=
  canonical le (xs.filter (fun x => mem x ys))

-- L4DEL: title: Difference of two finite sets
-- L4DEL: intuition: Difference keeps what the first set names and the second does not, so it is the complement of the intersection inside the first.
/--
The difference of two finite sets: the elements of `xs` that are not in `ys`.

The result is sorted, so it does not depend on how `xs` was written.
-/
def diff {α : Type} [BEq α] (le : α → α → Bool) (xs ys : List α) : List α :=
  canonical le (xs.filter (fun x => !mem x ys))

-- L4DEL: title: Containment of one finite set in another
-- L4DEL: intuition: A set is contained in another when every point of it is named by the other, and that is a filter over the points.
/--
Whether every element of `xs` is also in `ys`.
-/
def subset {α : Type} [BEq α] (xs ys : List α) : Bool :=
  xs.all (fun x => mem x ys)

/-!
## The carrier
-/

-- L4DEL: title: The carrier of a finite set
-- L4DEL: intuition: A finite set is a list of distinct elements, and the carrier is that list with its duplicates removed.
/--
The full carrier of `n` points.

`Fin n` is core Lean, so the carrier's size is part of its type and no
separate bound has to be checked.
-/
def carrier (n : Nat) : List (Fin n) :=
  List.ofFn (fun i => i)

-- L4DEL: title: The natural ordering on a finite carrier
-- L4DEL: intuition: A carrier of indexed points has a canonical order, and using it keeps every set operation independent of how the set was written.
/--
The natural ordering on `Fin n`, as a `Bool`-valued comparison.

`Fin n` has a decidable order, and the natural one is the order the
indices are written in.  Every finite set operation in this module takes
its ordering as an argument so that the ordering is visible at the call
site; this is the one the candidate field ports use.
-/
def finLe : (n : Nat) → Fin n → Fin n → Bool
  | _, a, b => decide (a < b)
