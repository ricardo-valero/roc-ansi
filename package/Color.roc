module [Color, to_code, up_scale, down_scale]

import C16 exposing [C16]
import C256 exposing [C256]
import Rgb exposing [Rgb]

## [Color](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors)
## it includes the 4-bit, 8-bit and 24-bit colors supported on *most* modern terminal emulators.
Color : [
    Default,
    C16 C16,
    C256 C256,
    Rgb Rgb,
    # Convenient to have
    Hex Rgb.Hex,
    Standard C16.Name,
    Bright C16.Name,
]

to_code : Color, U8 -> List U8
to_code = |color, offset|
    when color is
        Default -> [9 + offset]
        Rgb((red, green, blue)) -> [8 + offset, 2, red, green, blue]
        C256(index) -> [8 + offset, 5, index]
        C16(intensity) ->
            [
                (
                    when intensity is
                        Standard(name) -> 0 + C16.name_to_code(name)
                        Bright(name) -> 60 + C16.name_to_code(name)
                )
                |> Num.add(offset),
            ]

        Hex hex -> to_code (Rgb (Rgb.from_hex hex)) offset
        Standard name -> to_code (C16 (Standard name)) offset
        Bright name -> to_code (C16 (Bright name)) offset

ScaleOptions : [ToRgb Color, ToC256 Color, ToC16 Color]
# Scale : { up : ScaleOptions, down : ScaleOptions }

up_scale : ScaleOptions -> Color
up_scale = |s|
    when s is
        ToRgb c ->
            when c is
                C256 c256 -> Rgb (C256.to_rgb c256)
                C16 c16 -> up_scale (ToRgb (C256 (C16.to_c256 c16)))
                Standard name -> up_scale (ToRgb (C16 (Standard name)))
                Bright name -> up_scale (ToRgb (C16 (Bright name)))
                _ -> c

        ToC256 c ->
            when c is
                C16 c16 -> C256 (C16.to_c256 c16)
                Standard name -> up_scale (ToC256 (C16 (Standard name)))
                Bright name -> up_scale (ToC256 (C16 (Bright name)))
                _ -> c

        ToC16 c ->
            when c is
                _ -> c

# TODO
down_scale : ScaleOptions -> Color
down_scale = |s|
    when s is
        ToRgb c ->
            when c is
                _ -> c

        ToC256 c ->
            when c is
                # TODO: how to downscale from rgb?
                # Rgb rgb -> C256 (Rgb.to_c256 rgb)
                _ -> c

        ToC16 c ->
            when c is
                # TODO: how to downscale from rgb and c256?
                # C256 c256 -> C16 (C256.toC16 c256)
                # Rgb rgb -> C16 (rgb |> Rgb.to_c256 |> C256.toC16)
                _ -> c
