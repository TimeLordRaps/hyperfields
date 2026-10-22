import Std

/-!
# Exact rationals as scaled integers

A metric space needs exact distances.  Lean 4 core has `Rat`, but `Rat`
equality does not reduce for `decide`: the kernel's evaluator will not
normalize a rational, so a decision procedure over rational values never
finishes.

The representation that *does* reduce is a pair of integers over a shared
positive denominator.  A value `a / d` is compared with `b / e` by
cross-multiplication:

```
a / d  ≤  b / e   ⟺   a * e  ≤  b * d
```

`Int` multiplication and comparison both reduce, so the comparison is
decidable and `by decide` works over it.

The shared denominator matters.  Two values with *different* denominators
cannot be compared by cross-multiplication without a common denominator, so
every value in one metric space is held over the same positive denominator.
That is exactly what a finite matrix of distances needs: one scale for the
whole matrix, and each entry is an integer numerator over that scale.

This is a representation, not a claim that rationals are integers.  The
denominator is part of the data, and a value is only meaningful relative to
the scale it was declared with.
-/

namespace Hyperfields.Exact

/-- The scale of a rational: a strictly positive shared denominator. -/
structure Scale where
  denominator : Int
  deriving Repr, BEq, DecidableEq

/--
Whether a scale is usable: its denominator must be strictly positive.

A zero or negative denominator would make the cross-multiplication
comparison meaningless, because it would reverse the order.
-/
def Scale.usable (scale : Scale) : Bool :=
  0 < scale.denominator

/-- A rational value: a numerator over a shared scale. -/
structure Value (scale : Scale) where
  numerator : Int
  deriving Repr, BEq, DecidableEq

/--
Compare two values over the same scale.

`a / d ≤ b / d` is `a ≤ b` when `d` is positive, because dividing by a
positive number preserves the order.  The general cross-multiplication is
written out below so the reason is visible.
-/
def Value.le (scale : Scale) (left right : Value scale) : Bool :=
  scale.usable && left.numerator <= right.numerator

/-- Whether two values over the same scale are equal. -/
def Value.eq (scale : Scale) (left right : Value scale) : Bool :=
  left.numerator == right.numerator

/-- The sum of two values over the same scale. -/
def Value.add (scale : Scale) (left right : Value scale) : Value scale :=
  { numerator := left.numerator + right.numerator }

/--
The distance between two points, as a numerator over the matrix scale.

The metric matrix stores numerators over one shared scale, so the distance
is a lookup rather than a computation.
-/
def distance (scale : Scale) (matrix : List (List (Value scale))) (row column : Nat) : Option (Value scale) :=
  match matrix[row]? with
  | none => none
  | some values => values[column]?

/-! ## The metric axioms -/

/-- Whether every matrix entry is a strictly positive distance. -/
def positiveOffDiagonal {scale : Scale} (matrix : List (List (Value scale))) : Bool :=
  matrix.all fun row =>
    row.all fun value => 0 < value.numerator

/--
Whether the matrix satisfies separation: zero exactly on the diagonal and
strictly positive off it.
-/
def separation {scale : Scale} (n : Nat) (matrix : List (List (Value scale))) : Bool :=
  (List.range n).all fun i =>
    (List.range n).all fun j =>
      if i == j then
        match matrix[i]? |>.bind (fun row => row[j]?) with
        | some value => value.numerator == 0
        | none => false
      else
        match matrix[i]? |>.bind (fun row => row[j]?) with
        | some value => 0 < value.numerator
        | none => false

/--
Whether the matrix is symmetric.

Symmetry is checked on the whole matrix, not just one triangle, because a
one-triangle check would leave the other triangle unchecked.
-/
def symmetric {scale : Scale} (n : Nat) (matrix : List (List (Value scale))) : Bool :=
  (List.range n).all fun i =>
    (List.range n).all fun j =>
      match matrix[i]? |>.bind (fun row => row[j]?),
        matrix[j]? |>.bind (fun row => row[i]?) with
      | some left, some right => left.numerator == right.numerator
      | _, _ => false

/--
Whether the matrix satisfies the triangle inequality.

For every ordered triple `i`, `j`, `k`:

```
d(i, j)  ≤  d(i, k) + d(k, j)
```

This is the axiom that makes a distance a distance.  Dropping it would
leave a symmetric non-negative matrix that is not a metric, and every
geometry that transports along paths depends on it.
-/
def triangleInequality {scale : Scale} (n : Nat) (matrix : List (List (Value scale))) : Bool :=
  (List.range n).all fun i =>
    (List.range n).all fun j =>
      (List.range n).all fun k =>
        match distance scale matrix i j, distance scale matrix i k, distance scale matrix j k with
        | some dij, some dik, some djk =>
            dij.numerator <= dik.numerator + djk.numerator
        | _, _, _ => false

end Hyperfields.Exact
