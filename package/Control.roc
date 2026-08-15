module [Control, to_code]

import Style exposing [Style]

## [Control](https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences) (commonly known as Control Sequence Introducer or CSI)
## represents the control sequences for terminal commands.
## The provided commands are common and well-supported, though not exhaustive.
Control : [
    Screen [Size],
    Cursor
        [
            Position [Get, Save, Restore],
            Display [On, Off],
            ## Move relatively by a specified number of rows up or down, or columns left or right.
            Rel [Up, Down, Left, Right] U16,
            ## Move relatively by a specified number of rows next or previous (and to the first column of the corresponding row).
            Row [Next, Prev] U16,
            ## Move absolutely to the specified row and column.
            Abs { row : U16, col : U16 },
            ## Move absolutely to the specified column in the current row.
            Col U16,
        ],
    Erase
        [
            Display [ToEnd, ToStart, All],
            Line [ToEnd, ToStart, All],
        ],
    Scroll [Up, Down] U16,
    Style Style,
]

to_code : Control -> Str
to_code = |a|
    when a is
        Screen(b) ->
            when b is
                Size -> "18t"

        Cursor(b) ->
            when b is
                Position(state) ->
                    when state is
                        Get -> "6n"
                        Save -> "s"
                        Restore -> "u"

                Display(state) ->
                    "?25"
                    |> Str.concat(
                        when state is
                            On -> "l"
                            Off -> "h",
                    )

                Rel(direction, number) ->
                    Num.to_str(number)
                    |> Str.concat(
                        when direction is
                            Up -> "A"
                            Down -> "B"
                            Right -> "C"
                            Left -> "D",
                    )

                Row(direction, number) ->
                    Num.to_str(number)
                    |> Str.concat(
                        when direction is
                            Next -> "E"
                            Prev -> "F",
                    )

                Abs({ row, col }) -> [row, col] |> List.map(Num.to_str) |> Str.join_with(";") |> Str.concat("H")
                Col(col) -> col |> Num.to_str |> Str.concat("G")

        Erase(b) ->
            when b is
                Display(d) ->
                    (
                        when d is
                            ToEnd -> 0
                            ToStart -> 1
                            All -> 2
                        # ClearScreen -> 3
                    )
                    |> Num.to_str
                    |> Str.concat("J")

                Line(l) ->
                    (
                        when l is
                            ToEnd -> 0
                            ToStart -> 1
                            All -> 2
                    )
                    |> Num.to_str
                    |> Str.concat("K")

        Scroll(direction, lines) ->
            Num.to_str(lines)
            |> Str.concat(
                when direction is
                    Up -> "S"
                    Down -> "T",
            )

        Style(style) -> style |> Style.to_code |> List.map(Num.to_str) |> Str.join_with(";") |> Str.concat("m")

# Build : [
#    Cursor
#        [
#            Abs { row ? U16, col ? U16 },
#            Rel { rows ? I16, cols ? I16 },
#            Line { lines ? I16 },
#        ],
#    Scroll I16,
#    Style (List Style),
# ]

# build : Build -> List Control
# build = \a ->
#    when a is
#        Style b -> b |> List.map Style
#        Cursor b ->
#            when b is
#                Abs { r ? 0, c ? 0 } ->
#                    # The exposed api is 0-based but ansi is 1-based so we need to convert it
#                    row = r |> (\n -> Num.toU16Checked (n + 1) |> Result.withDefault Num.maxU16)
#                    col = c |> (\n -> Num.toU16Checked (n + 1) |> Result.withDefault Num.maxU16)
#                    [Abs { row, col }]
#                    |> List.map Cursor

#                Rel { r ? 0, c ? 0 } ->
#                    rows = (
#                        if r > 0 then
#                            Rel Up (r |> Num.toU16)
#                        else if r < 0 then
#                            Rel Down (r |> Num.abs |> Num.toU16)
#                        else
#                            Rel Up 0
#                    )
#                    cols = (
#                        if c > 0 then
#                            Rel Right (c |> Num.toU16)
#                        else if c < 0 then
#                            Rel Left (c |> Num.abs |> Num.toU16)
#                        else
#                            Rel Up 0
#                    )
#                    [rows, cols] |> List.map Cursor

#                Line { l ? 0 } ->
#                    lines = (
#                        if l > 0 then
#                            Row Next (l |> Num.toU16)
#                        else if l < 0 then
#                            Row Prev (l |> Num.abs |> Num.toU16)
#                        else
#                            Row Next 0
#                    )
#                    [lines] |> List.map Cursor

#        Scroll l ->
#            [
#                if l > 0 then
#                    Scroll Up (Num.toU16 l)
#                else if l < 0 then
#                    Scroll Down (Num.toU16 (Num.abs l))
#                else
#                    Scroll Up 0,
#            ]
