module [
    # ANSI
    Escape,
    toStr,
    style,
    color,

    # TUI
    DrawFn,
    Pixel,
    ScreenSize,
    Position,
    Input,
    parseCursor,
    updateCursor,
    inputToStr,
    parseRawStdin,
    drawScreen,
    drawText,
    drawVLine,
    drawHLine,
    drawBox,
    drawCursor,
    keyToStr,
]

import Color exposing [Color]
import Style exposing [Style]
import Control exposing [Control]

## [ANSI Escape Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)

Escape : [
    Reset,
    Control Control,
]

toStr : Escape -> Str
toStr = \escape -> "\u(001b)"
    |> Str.concat
        (
            when escape is
                Reset -> "c"
                Control control -> "[" |> Str.concat (Control.toCode control)
        )

## Add styles to a string
style : Str, List Style -> Str
style = \str, styles ->
    styles
    |> List.map Style
    |> List.map Control
    |> List.map toStr
    |> List.append str
    |> Str.joinWith ""

resetStyle = "" |> style [Default]

## Add color styles to a string and then resets to default
color : Str, { fg ? Color, bg ? Color } -> Str
color = \str, { fg ? Default, bg ? Default } -> str |> style [Foreground (fg), Background (bg)] |> Str.concat resetStyle

Key : [
    Up,
    Down,
    Left,
    Right,
    Escape,
    Enter,
    UpperA,
    LowerA,
    UpperB,
    LowerB,
    UpperC,
    LowerC,
    UpperD,
    LowerD,
    UpperE,
    LowerE,
    UpperF,
    LowerF,
    UpperG,
    LowerG,
    UpperH,
    LowerH,
    UpperI,
    LowerI,
    UpperJ,
    LowerJ,
    UpperK,
    LowerK,
    UpperL,
    LowerL,
    UpperM,
    LowerM,
    UpperN,
    LowerN,
    UpperO,
    LowerO,
    UpperP,
    LowerP,
    UpperQ,
    LowerQ,
    UpperR,
    LowerR,
    UpperS,
    LowerS,
    UpperT,
    LowerT,
    UpperU,
    LowerU,
    UpperV,
    LowerV,
    UpperW,
    LowerW,
    UpperX,
    LowerX,
    UpperY,
    LowerY,
    UpperZ,
    LowerZ,
    Space,
    ExclamationMark,
    QuotationMark,
    NumberSign,
    DollarSign,
    PercentSign,
    Ampersand,
    Apostrophe,
    RoundOpenBracket,
    RoundCloseBracket,
    Asterisk,
    PlusSign,
    Comma,
    Hyphen,
    FullStop,
    ForwardSlash,
    Colon,
    SemiColon,
    LessThanSign,
    EqualsSign,
    GreaterThanSign,
    QuestionMark,
    AtSign,
    SquareOpenBracket,
    Backslash,
    SquareCloseBracket,
    Caret,
    Underscore,
    GraveAccent,
    CurlyOpenBrace,
    VerticalBar,
    CurlyCloseBrace,
    Tilde,
    Number0,
    Number1,
    Number2,
    Number3,
    Number4,
    Number5,
    Number6,
    Number7,
    Number8,
    Number9,
    Delete,
]

Letter : [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]

Input : [
    KeyPress Key,
    Ctrl Letter,
    Unsupported (List U8),
]

parseRawStdin : List U8 -> Input
parseRawStdin = \bytes ->
    when bytes is
        [3, ..] -> Ctrl C
        [19, ..] -> Ctrl S
        [25, ..] -> Ctrl Y
        [26, ..] -> Ctrl Z
        [27, 91, 'A', ..] -> KeyPress Up
        [27, 91, 'B', ..] -> KeyPress Down
        [27, 91, 'C', ..] -> KeyPress Right
        [27, 91, 'D', ..] -> KeyPress Left
        [27, ..] -> KeyPress Escape
        [13, ..] -> KeyPress Enter
        [32, ..] -> KeyPress Space
        [127, ..] -> KeyPress Delete
        ['A', ..] -> KeyPress UpperA
        ['a', ..] -> KeyPress LowerA
        ['B', ..] -> KeyPress UpperB
        ['b', ..] -> KeyPress LowerB
        ['C', ..] -> KeyPress UpperC
        ['c', ..] -> KeyPress LowerC
        ['D', ..] -> KeyPress UpperD
        ['d', ..] -> KeyPress LowerD
        ['E', ..] -> KeyPress UpperE
        ['e', ..] -> KeyPress LowerE
        ['F', ..] -> KeyPress UpperF
        ['f', ..] -> KeyPress LowerF
        ['G', ..] -> KeyPress UpperG
        ['g', ..] -> KeyPress LowerG
        ['H', ..] -> KeyPress UpperH
        ['h', ..] -> KeyPress LowerH
        ['I', ..] -> KeyPress UpperI
        ['i', ..] -> KeyPress LowerI
        ['J', ..] -> KeyPress UpperJ
        ['j', ..] -> KeyPress LowerJ
        ['K', ..] -> KeyPress UpperK
        ['k', ..] -> KeyPress LowerK
        ['L', ..] -> KeyPress UpperL
        ['l', ..] -> KeyPress LowerL
        ['M', ..] -> KeyPress UpperM
        ['m', ..] -> KeyPress LowerM
        ['N', ..] -> KeyPress UpperN
        ['n', ..] -> KeyPress LowerN
        ['O', ..] -> KeyPress UpperO
        ['o', ..] -> KeyPress LowerO
        ['P', ..] -> KeyPress UpperP
        ['p', ..] -> KeyPress LowerP
        ['Q', ..] -> KeyPress UpperQ
        ['q', ..] -> KeyPress LowerQ
        ['R', ..] -> KeyPress UpperR
        ['r', ..] -> KeyPress LowerR
        ['S', ..] -> KeyPress UpperS
        ['s', ..] -> KeyPress LowerS
        ['T', ..] -> KeyPress UpperT
        ['t', ..] -> KeyPress LowerT
        ['U', ..] -> KeyPress UpperU
        ['u', ..] -> KeyPress LowerU
        ['V', ..] -> KeyPress UpperV
        ['v', ..] -> KeyPress LowerV
        ['W', ..] -> KeyPress UpperW
        ['w', ..] -> KeyPress LowerW
        ['X', ..] -> KeyPress UpperX
        ['x', ..] -> KeyPress LowerX
        ['Y', ..] -> KeyPress UpperY
        ['y', ..] -> KeyPress LowerY
        ['Z', ..] -> KeyPress UpperZ
        ['z', ..] -> KeyPress LowerZ
        ['!', ..] -> KeyPress ExclamationMark
        ['"', ..] -> KeyPress QuotationMark
        ['#', ..] -> KeyPress NumberSign
        ['$', ..] -> KeyPress DollarSign
        ['%', ..] -> KeyPress PercentSign
        ['&', ..] -> KeyPress Ampersand
        ['\'', ..] -> KeyPress Apostrophe
        ['(', ..] -> KeyPress RoundOpenBracket
        [')', ..] -> KeyPress RoundCloseBracket
        ['*', ..] -> KeyPress Asterisk
        ['+', ..] -> KeyPress PlusSign
        [',', ..] -> KeyPress Comma
        ['-', ..] -> KeyPress Hyphen
        ['.', ..] -> KeyPress FullStop
        ['/', ..] -> KeyPress ForwardSlash
        [':', ..] -> KeyPress Colon
        [';', ..] -> KeyPress SemiColon
        ['<', ..] -> KeyPress LessThanSign
        ['=', ..] -> KeyPress EqualsSign
        ['>', ..] -> KeyPress GreaterThanSign
        ['?', ..] -> KeyPress QuestionMark
        ['@', ..] -> KeyPress AtSign
        ['[', ..] -> KeyPress SquareOpenBracket
        ['\\', ..] -> KeyPress Backslash
        [']', ..] -> KeyPress SquareCloseBracket
        ['^', ..] -> KeyPress Caret
        ['_', ..] -> KeyPress Underscore
        ['`', ..] -> KeyPress GraveAccent
        ['{', ..] -> KeyPress CurlyOpenBrace
        ['|', ..] -> KeyPress VerticalBar
        ['}', ..] -> KeyPress CurlyCloseBrace
        ['~', ..] -> KeyPress Tilde
        ['0', ..] -> KeyPress Number0
        ['1', ..] -> KeyPress Number1
        ['2', ..] -> KeyPress Number2
        ['3', ..] -> KeyPress Number3
        ['4', ..] -> KeyPress Number4
        ['5', ..] -> KeyPress Number5
        ['6', ..] -> KeyPress Number6
        ['7', ..] -> KeyPress Number7
        ['8', ..] -> KeyPress Number8
        ['9', ..] -> KeyPress Number9
        _ -> Unsupported bytes

expect parseRawStdin [27, 91, 65] == KeyPress Up
expect parseRawStdin [27] == KeyPress Escape

letterToStr : [Upper Letter, Lower Letter] -> Str
letterToStr = \case ->
    when case is
        Upper letter ->
            when letter is
                A -> "A"
                B -> "B"
                C -> "C"
                D -> "D"
                E -> "E"
                F -> "F"
                G -> "G"
                H -> "H"
                I -> "I"
                J -> "J"
                K -> "K"
                L -> "L"
                M -> "M"
                N -> "N"
                O -> "O"
                P -> "P"
                Q -> "Q"
                R -> "R"
                S -> "S"
                T -> "T"
                U -> "U"
                V -> "V"
                W -> "W"
                X -> "X"
                Y -> "Y"
                Z -> "Z"

        Lower letter ->
            when letter is
                A -> "a"
                B -> "b"
                C -> "c"
                D -> "d"
                E -> "e"
                F -> "f"
                G -> "g"
                H -> "h"
                I -> "i"
                J -> "j"
                K -> "k"
                L -> "l"
                M -> "m"
                N -> "n"
                O -> "o"
                P -> "p"
                Q -> "q"
                R -> "r"
                S -> "s"
                T -> "t"
                U -> "u"
                V -> "v"
                W -> "w"
                X -> "x"
                Y -> "y"
                Z -> "z"

inputToStr : Input -> Str
inputToStr = \input ->
    when input is
        KeyPress key -> "Key $(keyToStr key)"
        Ctrl key -> "Ctrl-" |> Str.concat (letterToStr (Upper key))
        Unsupported bytes ->
            bytesStr = bytes |> List.map Num.toStr |> Str.joinWith ","
            "Unsupported [$(bytesStr)]"

keyToStr : Key -> Str
keyToStr = \key ->
    when key is
        Up -> "Up"
        Down -> "Down"
        Left -> "Left"
        Right -> "Right"
        Escape -> "Escape"
        Enter -> "Enter"
        Space -> "Space"
        UpperA -> "A"
        LowerA -> "a"
        UpperB -> "B"
        LowerB -> "b"
        UpperC -> "C"
        LowerC -> "c"
        UpperD -> "D"
        LowerD -> "d"
        UpperE -> "E"
        LowerE -> "e"
        UpperF -> "F"
        LowerF -> "f"
        UpperG -> "G"
        LowerG -> "g"
        UpperH -> "H"
        LowerH -> "h"
        UpperI -> "I"
        LowerI -> "i"
        UpperJ -> "J"
        LowerJ -> "j"
        UpperK -> "K"
        LowerK -> "k"
        UpperL -> "L"
        LowerL -> "l"
        UpperM -> "M"
        LowerM -> "m"
        UpperN -> "N"
        LowerN -> "n"
        UpperO -> "O"
        LowerO -> "o"
        UpperP -> "P"
        LowerP -> "p"
        UpperQ -> "Q"
        LowerQ -> "q"
        UpperR -> "R"
        LowerR -> "r"
        UpperS -> "S"
        LowerS -> "s"
        UpperT -> "T"
        LowerT -> "t"
        UpperU -> "U"
        LowerU -> "u"
        UpperV -> "V"
        LowerV -> "v"
        UpperW -> "W"
        LowerW -> "w"
        UpperX -> "X"
        LowerX -> "x"
        UpperY -> "Y"
        LowerY -> "y"
        UpperZ -> "Z"
        LowerZ -> "z"
        ExclamationMark -> "!"
        QuotationMark -> "\""
        NumberSign -> "#"
        DollarSign -> "\$"
        PercentSign -> "%"
        Ampersand -> "&"
        Apostrophe -> "'"
        RoundOpenBracket -> "("
        RoundCloseBracket -> ")"
        Asterisk -> "*"
        PlusSign -> "+"
        Comma -> ","
        Hyphen -> "-"
        FullStop -> "."
        ForwardSlash -> "/"
        Colon -> ":"
        SemiColon -> ";"
        LessThanSign -> "<"
        EqualsSign -> "="
        GreaterThanSign -> ">"
        QuestionMark -> "?"
        AtSign -> "@"
        SquareOpenBracket -> "["
        Backslash -> "\\"
        SquareCloseBracket -> "]"
        Caret -> "^"
        Underscore -> "_"
        GraveAccent -> "`"
        CurlyOpenBrace -> "{"
        VerticalBar -> "|"
        CurlyCloseBrace -> "}"
        Tilde -> "~"
        Number0 -> "0"
        Number1 -> "1"
        Number2 -> "2"
        Number3 -> "3"
        Number4 -> "4"
        Number5 -> "5"
        Number6 -> "6"
        Number7 -> "7"
        Number8 -> "8"
        Number9 -> "9"
        Delete -> "Delete"

ScreenSize : { width : I32, height : I32 }
Position : { row : I32, col : I32 }
DrawFn : Position, Position -> Result Pixel {}
Pixel : { char : Str, fg : Color, bg : Color, styles : List Style }

parseCursor : List U8 -> Position
parseCursor = \bytes ->
    { val: row, rest: afterFirst } = takeNumber { val: 0, rest: List.dropFirst bytes 2 }
    { val: col } = takeNumber { val: 0, rest: List.dropFirst afterFirst 1 }

    { row, col }

# test "ESC[33;1R"
expect parseCursor [27, 91, 51, 51, 59, 49, 82] == { col: 1, row: 33 }

takeNumber : { val : I32, rest : List U8 } -> { val : I32, rest : List U8 }
takeNumber = \in ->
    when in.rest is
        [a, ..] if a == '0' -> takeNumber { val: in.val * 10 + 0, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '1' -> takeNumber { val: in.val * 10 + 1, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '2' -> takeNumber { val: in.val * 10 + 2, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '3' -> takeNumber { val: in.val * 10 + 3, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '4' -> takeNumber { val: in.val * 10 + 4, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '5' -> takeNumber { val: in.val * 10 + 5, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '6' -> takeNumber { val: in.val * 10 + 6, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '7' -> takeNumber { val: in.val * 10 + 7, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '8' -> takeNumber { val: in.val * 10 + 8, rest: List.dropFirst in.rest 1 }
        [a, ..] if a == '9' -> takeNumber { val: in.val * 10 + 9, rest: List.dropFirst in.rest 1 }
        _ -> in

expect takeNumber { val: 0, rest: [27, 91, 51, 51, 59, 49, 82] } == { val: 0, rest: [27, 91, 51, 51, 59, 49, 82] }
expect takeNumber { val: 0, rest: [51, 51, 59, 49, 82] } == { val: 33, rest: [59, 49, 82] }
expect takeNumber { val: 0, rest: [49, 82] } == { val: 1, rest: [82] }

updateCursor : { cursor : Position, screen : ScreenSize }a, [Up, Down, Left, Right] -> { cursor : Position, screen : ScreenSize }a
updateCursor = \state, direction ->
    when direction is
        Up ->
            { state &
                cursor: {
                    row: ((state.cursor.row + state.screen.height - 1) % state.screen.height),
                    col: state.cursor.col,
                },
            }

        Down ->
            { state &
                cursor: {
                    row: ((state.cursor.row + 1) % state.screen.height),
                    col: state.cursor.col,
                },
            }

        Left ->
            { state &
                cursor: {
                    row: state.cursor.row,
                    col: ((state.cursor.col + state.screen.width - 1) % state.screen.width),
                },
            }

        Right ->
            { state &
                cursor: {
                    row: state.cursor.row,
                    col: ((state.cursor.col + 1) % state.screen.width),
                },
            }

## Loop through each pixel in screen and build up a single string to write to stdout
drawScreen : { cursor : Position, screen : ScreenSize }*, List DrawFn -> Str
drawScreen = \{ cursor, screen }, drawFns ->
    pixels =
        row <- List.range { start: At 0, end: Before screen.height } |> List.map
        col <- List.range { start: At 0, end: Before screen.width } |> List.map

        List.walkUntil
            drawFns
            { char: " ", fg: Default, bg: Default, styles: [] }
            \defaultPixel, drawFn ->
                when drawFn cursor { row, col } is
                    Ok pixel -> Break pixel
                    Err _ -> Continue defaultPixel

    pixels
    |> joinAllPixels

joinAllPixels : List (List Pixel) -> Str
joinAllPixels = \rows ->

    walkWithIndex = \remaining, idx, state, fn ->
        when remaining is
            [] -> state
            [head, .. as rest] -> walkWithIndex rest (idx + 1) (fn state head idx) fn

    init = {
        char: " ",
        fg: Default,
        bg: Default,
        lines: List.withCapacity (List.len rows),
        styles: [],
    }

    walkWithIndex rows 0 init joinPixelRow
    |> .lines
    |> Str.joinWith ""

joinPixelRow : { char : Str, fg : Color, bg : Color, lines : List Str, styles : List Style }, List Pixel, U64 -> { char : Str, fg : Color, bg : Color, lines : List Str, styles : List Style }
joinPixelRow = \{ char, fg, bg, lines, styles }, pixelRow, row ->

    { rowStrs, prev } =
        List.walk
            pixelRow
            { rowStrs: List.withCapacity (Num.intCast (List.len pixelRow)), prev: { char, fg, bg, styles } }
            joinPixels

    line =
        rowStrs
        |> Str.joinWith "" # Set cursor at the start of line we want to draw
        |> Str.withPrefix (toStr (Control (Cursor (Abs { row: Num.toU16 (row + 1), col: 0 }))))

    { char: " ", fg: prev.fg, bg: prev.bg, lines: List.append lines line, styles: prev.styles }

joinPixels : { rowStrs : List Str, prev : Pixel }, Pixel -> { rowStrs : List Str, prev : Pixel }
joinPixels = \{ rowStrs, prev }, curr ->
    pixelStr =
        # Prepend an ASCII escape ONLY if there is a change between pixels
        curr.char
        |> \str -> if curr.fg != prev.fg then Str.concat (toStr (Control (Style (Foreground curr.fg)))) str else str
        |> \str -> if curr.bg != prev.bg then Str.concat (toStr (Control (Style (Background curr.bg)))) str else str

    { rowStrs: List.append rowStrs pixelStr, prev: curr }

drawBox : { r : I32, c : I32, w : I32, h : I32, fg ? Color, bg ? Color, char ? Str, styles ? List Style } -> DrawFn
drawBox = \{ r, c, w, h, fg ? Default, bg ? Default, char ? "#", styles ? [] } -> \_, { row, col } ->

        startRow = r
        endRow = (r + h)
        startCol = c
        endCol = (c + w)

        if row == r && (col >= startCol && col < endCol) then
            Ok { char, fg, bg, styles } # TOP BORDER
        else if row == (r + h - 1) && (col >= startCol && col < endCol) then
            Ok { char, fg, bg, styles } # BOTTOM BORDER
        else if col == c && (row >= startRow && row < endRow) then
            Ok { char, fg, bg, styles } # LEFT BORDER
        else if col == (c + w - 1) && (row >= startRow && row < endRow) then
            Ok { char, fg, bg, styles } # RIGHT BORDER
        else
            Err {}

drawVLine : { r : I32, c : I32, len : I32, fg ? Color, bg ? Color, char ? Str, styles ? List Style } -> DrawFn
drawVLine = \{ r, c, len, fg ? Default, bg ? Default, char ? "|", styles ? [] } -> \_, { row, col } ->
        if col == c && (row >= r && row < (r + len)) then
            Ok { char, fg, bg, styles }
        else
            Err {}

drawHLine : { r : I32, c : I32, len : I32, fg ? Color, bg ? Color, char ? Str, styles ? List Style } -> DrawFn
drawHLine = \{ r, c, len, fg ? Default, bg ? Default, char ? "-", styles ? [] } -> \_, { row, col } ->
        if row == r && (col >= c && col < (c + len)) then
            Ok { char, fg, bg, styles }
        else
            Err {}

drawCursor : { fg ? Color, bg ? Color, char ? Str, styles ? List Style } -> DrawFn
drawCursor = \{ fg ? Default, bg ? Default, char ? " ", styles ? [] } -> \cursor, { row, col } ->
        if (row == cursor.row) && (col == cursor.col) then
            Ok { char, fg, bg, styles }
        else
            Err {}

drawText : Str, { r : I32, c : I32, fg ? Color, bg ? Color, styles ? List Style } -> DrawFn
drawText = \text, { r, c, fg ? Default, bg ? Default, styles ? [] } -> \_, pixel ->
        bytes = Str.toUtf8 text
        len = text |> Str.toUtf8 |> List.len |> Num.toI32
        if pixel.row == r && pixel.col >= c && pixel.col < (c + len) then
            bytes
            |> List.get (Num.intCast (pixel.col - c))
            |> Result.try \b -> Str.fromUtf8 [b]
            |> Result.map \char -> { char, fg, bg, styles }
            |> Result.mapErr \_ -> {}
        else
            Err {}
