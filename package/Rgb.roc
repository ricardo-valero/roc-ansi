module [Rgb, Hex, from_hex]

import Utils

Rgb : (U8, U8, U8)

Hex : U32

from_hex : Hex -> Rgb
from_hex = |hex|
    u24 = (Utils.clamp(0x000000, 0xFFFFFF))(hex)
    c = |a| u24 |> Num.shift_right_by(Num.mul(8, (2 - a))) |> Num.bitwise_and(0xFF) |> Num.to_u8
    (c(0), c(1), c(2))

expect from_hex(0xFF0000) == (255, 0, 0)
expect from_hex(0x00FF00) == (0, 255, 0)
expect from_hex(0x0000FF) == (0, 0, 255)
expect from_hex(0xFFFFFFFF) == (255, 255, 255)

import Rational exposing [Rational]

to_C256 : Rgb -> Rational
to_C256 = |(red, green, blue)|
    avg = (
        if red == green and green == blue then
            Rational.simplify (Num.int_cast red, 1)
        else
            # FIXME: How to properly add U8s without overflowing or converting them to U64
            sum = [red, green, blue] |> List.map Num.to_u64 |> List.walk 0 Num.add
            Rational.simplify (Num.int_cast sum, 3)
    )
    gray = avg |> Rational.sub (8, 1) |> Rational.mul (1, 10) |> Rational.add (232, 1)
    gray

expect
    expected = (1256, 5)
    actual = to_C256 (200, 250, 150)
    actual == expected

Hsl : (U64, Rational, Rational)

to_hsl : Rgb -> Hsl
to_hsl = |(r, g, b)|
    # When 0 ≤ r, g, b ≤ 255
    cN = |a| (Num.to_i64 a, 1) |> (Rational.linear_interpolation ((0, 1), (255, 1)) ((0, 1), (1, 1)))
    rN = cN r
    gN = cN g
    bN = cN b

    low = [rN, gN, bN] |> List.walk (1, 1) Rational.min
    high = [rN, gN, bN] |> List.walk (0, 1) Rational.max

    diff = Rational.sub high low
    sum = Rational.add high low

    lightness = sum |> Rational.div (2, 1)

    if (diff == (0, 1)) then
        # Achromatic
        (0, (0, 1), lightness)
    else
        # Chromatic
        saturation = diff |> Rational.div (Rational.sub (1, 1) (Rational.abs (Rational.sub sum (1, 1))))
        hue =
            (
                if (rN == high) then
                    when Rational.compare gN bN is
                        LT -> Rational.sub (6, 1) (Rational.div (Rational.sub bN gN) diff)
                        _ -> Rational.add (0, 1) (Rational.div (Rational.sub gN bN) diff)
                else if (gN == high) then
                    Rational.add (2, 1) (Rational.div (Rational.sub bN rN) diff)
                else
                    Rational.add (4, 1) (Rational.div (Rational.sub rN gN) diff)
            )
            |> Rational.mul (60, 1)
            |> Rational.to_dec
            |> Num.round

        (hue, saturation, lightness)

expect
    expected = (0, Rational.simplify (0, 100), Rational.simplify (100, 255))
    actual = to_hsl (100, 100, 100)
    actual == expected
expect
    # Black     #000000
    expected = (0, Rational.simplify (0, 100), Rational.simplify (0, 1))
    actual = to_hsl (0, 0, 0)
    actual == expected
# expect
#    # White     #FFFFFF
#    expected = (0, Rational.simplify (0, 100), Rational.simplify (1, 1))
#    actual = to_hsl (255, 255, 255)
#    actual == expected
# expect
#    # Red       #FF0000
#    expected = (0, Rational.simplify (100, 100), Rational.simplify (50, 100))
#    actual = to_hsl (255, 0, 0)
#    actual == expected
# expect
#    # Lime      #00FF00
#    expected = (120, Rational.simplify (100, 100), Rational.simplify (50, 100))
#    actual = to_hsl (0, 255, 0)
#    actual == expected
# expect
#     # Blue      #0000FF
#     expected = (240, (100, 100), (50, 100))
#     actual = to_hsl (0, 0, 255)
#     actual == expected
# expect
#     # Yellow    #FFFF00
#     expected = (60, (100, 100), (50, 100))
#     actual = to_hsl (255, 255, 0)
#     actual == expected
# expect
#     # Cyan      #00FFFF
#     expected = (180, (100, 100), (50, 100))
#     actual = to_hsl (0, 255, 255)
#     actual == expected
# expect
#     # Magenta   #FF00FF
#     expected = (300, (100, 100), (50, 100))
#     actual = to_hsl (255, 0, 255)
#     actual == expected

# hlsToRgb = \(h, s, l) ->
#     # When 0 ≤ h < 360, 0 ≤ s, l ≤ 1 and 0 ≤ l ≤ 1
#     if s == 0.0 then
#         # Achromatic
#         (l, l, l)
#     else
#         c = (1 - Num.abs (2 * l - 1)) * s
#         x = 0
#         # x = c * (1 - Num.abs (Num.rem (h / 60) 2 - 1))
#         # m = l - c / 2

#         norm = (
#             if h < 60 then
#                 (c, x, 0)
#             else if h < 120 then
#                 (x, c, 0)
#             else if h < 180 then
#                 (0, c, x)
#             else if h < 240 then
#                 (0, x, c)
#             else
#                 (0, 0, 0)
#         )
#         norm

# expect
#     expected = (255, 0, 255)
#     actual = hlsToRgb (300, 100 / 100, 50 / 100)
#     actual == expected

# rgbToAnsiColor8 = \(r, g, b) ->
#     ci = (36 * r) + (6 * g) + b
#     v = ci + 16
#     v
#     list = [r, g, b] |> List.sortDesc
#     high = list |> List.first |> Result.withDefault upperLimit
#     low = list |> List.last |> Result.withDefault lowerLimit
