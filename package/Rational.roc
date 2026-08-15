module [
    Rational,
    # ops
    simplify,
    add,
    sub,
    mul,
    div,
    abs,
    # conversion
    to_dec,
    # utils
    compare,
    min,
    max,
    clamp,
    manhattan_distance,
    linear_interpolation,
]

## GCD (Greatest Common Divisor): The largest positive integer that divides each of the integers without leaving a remainder.
gcd = |a, b|
    if b == 0 then
        Num.abs a
    else
        b |> gcd (Num.rem a b)

## LCM (Least Common Multiple): The smallest positive integer that is divisible by both numbers without leaving a remainder.
lcm = |a, b|
    Num.abs (Num.mul a b) |> Num.div_trunc (gcd a b)

expect
    expected = 20
    actual = lcm 4 5
    actual == expected

# TODO: How to create an opaque type using `Int a` and `Eq`?
# A tuple with numerator and denominator
Temp : I64
Rational : (Temp, Temp)

simplify : Rational -> Rational
simplify = |a|
    g = gcd a.0 a.1
    (Num.div_trunc a.0 g, Num.div_trunc a.1 g)

expect
    expected = (1, 1)
    actual = simplify (5, 5)
    actual == expected

expect
    expected = (23, 24)
    actual = simplify (23, 24)
    actual == expected

expect
    expected = (200, 1)
    actual = simplify ((200 + 250 + 150), 3)
    actual == expected

expect
    expected = (0, 1)
    actual = simplify (0, 100)
    actual == expected

withCommonDenominator = |a, b|
    |f|
        if (a.1 == b.1) then
            # Rationals have the same denominator
            (f a.0 b.0, a.1)
        else
            # Find least common multiple of denominators
            d = lcm a.1 b.1
            # Get numerators by converting both rationals to have the same denominator
            n1 = Num.div_trunc d a.1 |> Num.mul a.0
            n2 = Num.div_trunc d b.1 |> Num.mul b.0
            (f n1 n2, d)

add : Rational, Rational -> Rational
add = |a, b| simplify ((withCommonDenominator a b) Num.add)

expect
    expected = (23, 20)
    actual = add (3, 4) (2, 5)
    actual == expected

expect
    expected = (5, 4)
    actual = add (1, 2) (3, 4)
    actual == expected

neg : Rational -> Rational
neg = |a| (-a.0, a.1)

sub : Rational, Rational -> Rational
sub = |a, b| add a (neg b)

expect
    expected = (7, 20)
    actual = sub (3, 4) (2, 5)
    actual == expected

expect
    expected = (-1, 4)
    actual = sub (1, 2) (3, 4)
    actual == expected

mul : Rational, Rational -> Rational
mul = |a, b| simplify (Num.mul a.0 b.0, Num.mul a.1 b.1)

expect
    expected = (25, 42)
    actual = mul (5, 6) (5, 7)
    actual == expected

expect
    expected = (5, 21)
    actual = mul (5, 6) (2, 7)
    actual == expected

inv : Rational -> Rational
inv = |a| (a.1, a.0)

div : Rational, Rational -> Rational
div = |a, b| mul a (inv b)

expect
    expected = (7, 6)
    actual = div (5, 6) (5, 7)
    actual == expected

expect
    expected = (35, 12)
    actual = div (5, 6) (2, 7)
    actual == expected

to_dec : Rational -> Dec
to_dec = |a|
    Num.div (Num.to_frac a.0) (Num.to_frac a.1)

expect
    expected = 0.9583333333333333333333333333333333333333333333333333333333333333
    actual = to_dec (23, 24)
    actual == expected

abs : Rational -> Rational
abs = |r| (Num.abs (r.0), Num.abs (r.1))

compare : Rational, Rational -> [EQ, GT, LT]
compare = |a, b|
    (
        (withCommonDenominator a b) |n1, n2|
            if n1 < n2 then
                LT
            else if n1 > n2 then
                GT
            else
                EQ
    ).0

max = |a, b|
    when compare a b is
        LT -> b
        GT -> a
        EQ -> a

min = |a, b|
    when compare a b is
        LT -> a
        GT -> b
        EQ -> a

clamp = |a, b|
    |value|
        value |> min b |> max a

expect
    expected = (5, 1)
    actual = (clamp (1, 1) (10, 1)) (5, 1)
    actual == expected

expect
    expected = (1, 1)
    actual = (clamp (1, 1) (10, 1)) (0, 1)
    actual == expected

expect
    expected = (10, 1)
    actual = (clamp (1, 1) (10, 1)) (20, 1)
    actual == expected

manhattan_distance : List Rational, List Rational -> Rational
manhattan_distance = |point1, point2|
    List.map2 point1 point2 sub
    |> List.map abs
    |> List.walk (0, 1) add

expect
    expected = (221, 105)
    actual = manhattan_distance [(1, 3), (2, 3), (4, 7)] [(4, 3), (6, 5), (8, 7)]
    actual == expected

# linear_interpolation = \(iMin, iMax), (oMin, oMax) -> \value ->
#         oMin |> Num.add value |> Num.sub iMin |> Num.mul (oMax |> Num.sub oMin |> Num.div iMax |> Num.sub iMin)

linear_interpolation = |a, b|
    |value|
        t = value |> sub a.0 |> div a.1 |> sub a.0
        b.1 |> sub b.0 |> mul t |> add b.0

expect
    expected = (15, 1)
    actual = (1, 2) |> (linear_interpolation ((0, 1), (1, 1)) ((10, 1), (20, 1)))
    actual == expected

expect
    expected = (9203, 34425)
    actual = (1, 3) |> (linear_interpolation ((0, 1), (255, 1)) ((12, 45), (35, 45)))
    actual == expected

# linear_interpolation : List Rational, List Rational -> Rational
# linear_interpolation = \ranges, values -> \input ->
#        t = List.map2 (\range, value -> div (sub input range.0) (sub range.1 range.0)) ranges values
#        result = List.walk (\acc, (value, valueRange) -> add acc (mul (sub value.1 value.0) value)) values t
#        result

# expect
#     expected = [(15, 1)]
#     actual = (1, 2) |> (linear_interpolation [((0, 1), (1, 1))] [((10, 1), (20, 1))])
#     actual == expected
