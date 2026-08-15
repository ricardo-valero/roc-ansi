module []

# drawVertical : List (List Str),
#    List U64,
#    {
#        top ? (Int *, LineFill Str),
#        middle ? (Int *, LineFill Str),
#        bottom ? (Int *, LineFill Str),
#    }
#    -> Str
fill_list = |elem, size| List.range { start: At 0, end: Before size } |> List.map (|_| elem)

# draw_space = |data, { a ?? 1, b ?? 1, c ?? 1 }|
#    data
#    |> List.intersperse (fill_list MarginBetween b)
#    |> List.prepend (fill_list MarginTop a)
#    |> List.append (fill_list MarginBottom c)
#    |> List.join

drawBorder = |separator, { base ?? (" ", [1, 1]), sep ?? ("░", 1), start ?? ("░", 1), end ?? ("░", 1) }|
    base.1
    |> List.map (|b| fill_list base.0 b)
    |> List.intersperse (fill_list sep.0 sep.1)
    |> List.prepend (fill_list start.0 start.1)
    |> List.append (fill_list end.0 end.1)
    |> List.join
    |> Str.join_with separator

expect
    actual = drawBorder "" { base: (" ", [1, 1]), sep: ("░", 2), start: ("░", 3), end: ("░", 4) }
    expected = "░░░ ░░ ░░░░"
    actual == expected

# expect
#    actual = drawBorder "\n" { base: (" ", [1, 1]), sep: ("░", 2), start: ("░", 3), end: ("░", 4) }
#    expected =
#        """
#        ░
#        ░
#        ░

#        ░
#        ░

#        ░
#        ░
#        ░
#        ░
#        """
#    actual == expected

# expect
#    actual = drawBorder
#        [
#            [draw_space [["A"], ["B"]] "" {}],
#            [draw_space [["C"], ["D"]] "" {}],
#        ]
#        "\n"
#        {}
#    expected =
#        """
#        ░░░░░
#        ░A░B░
#        ░░░░░
#        ░C░D░
#        ░░░░░
#        """
#    actual == expected

## Truncates or pads a string to fit a specified size.
## It only works for left-to-right writing.
## It only truncates for single line words (horizontal size only). TODO: Add multiline support (breakdown words, add hyphen)?
## It only pads to the right. TODO: Add word alignment support?
trunc_or_pad : Str, Str -> (Str, U64 -> Str)
trunc_or_pad = |trunc_char, fill_char|
    |str, size|
        if size == 0 then
            ""
        else
            data = Str.to_utf8 str
            len = List.len data
            if len > size then
                ## The string is larger the specified size, truncate it and append the truncation character.
                truncated = data |> List.take_first (size - 1) |> Str.from_utf8 |> Result.with_default ""
                truncated |> Str.concat trunc_char
            else if len < size then
                ## The string is shorter than the specified size, pad it with the padding character.
                right_pad = size - len
                str |> Str.concat (Str.repeat fill_char right_pad)
            else
                ## If the string is exactly the specified size, return it as is.
                str

text_to_node = |str|
    str

draw_text = |(width, height), str|
    str
    |> Str.split_on " " # Split into words
    |> breakIntoLines width
    |> List.join "\n"

breakIntoLines = |width, words|
    List.walk words ([], "") |(lines, currentLine), word|
        newLine =
            if Str.is_empty currentLine then
                word
            else
                "${currentLine} ${word}"

        if Str.count_utf8_bytes newLine <= width then
            # Word fits on current line
            (lines, newLine)
        else
            # Start new line
            (List.append lines currentLine, word)
    |> |(lines, lastLine)|
        # Don't forget to add the last line
        List.append lines lastLine

expect
    actual = draw_text (14, 2) "Hello Roc! this is the best!"
    expected = "Hello Roc!    \nthis is great!"
    actual == expected

# draw_border should calculate the size based on text
# draw_cell size should be an input

draw_cell = |width, text, start, base, end|
    [[base.0, trunc_or_pad("…", base.1)(text, width), base.2]]
    |> List.prepend [start.0, Str.repeat start.1 width, start.2]
    |> List.append [end.0, Str.repeat end.1 width, end.2]
    |> draw_2d

draw_2d = |nodes|
    nodes
    |> List.map (|x| x |> Str.join_with "")
    |> Str.join_with "\n"

expect
    actual = draw_cell 10 "Hello!" ("╭", "─", "╮") ("│", " ", "│") ("╰", "─", "╯")
    expected =
        """
        ╭──────────╮
        │Hello!    │
        ╰──────────╯
        """
    actual == expected

expect
    actual = draw_cell 10 "Hello World!" ("╭", "─", "┬") ("│", " ", "│") ("├", "─", "┼")
    expected =
        """
        ╭──────────┬
        │Hello Wor…│
        ├──────────┼
        """
    actual == expected
