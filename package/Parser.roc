module []

screenSize = \input ->
    when Str.split input ";" is
        [cmd, rows, colsWithT] ->
            if Str.startsWith cmd "^[[8" then
                when colsWithT |> Str.replaceFirst "t" "" |> Str.toI64 is
                    Ok cols -> Ok { rows: Str.toI64 rows |> Result.withDefault 0, cols }
                    Err _ -> Err InvalidFormat
            else
                Err InvalidFormat

        _ ->
            Err InvalidFormat

expect screenSize "^[[8;10;159" == Ok { rows: 10, cols: 159 }

cursorPosition = \input ->
    when Str.split input ";" is
        [cmd, rowWithR] ->
            if Str.startsWith cmd "^[[" then
                when rowWithR |> Str.replaceFirst "R" "" |> Str.toI64 is
                    Ok row -> Ok { row, col: Str.toI64 (Str.replaceFirst cmd "^[[" "") |> Result.withDefault 0 }
                    Err _ -> Err InvalidFormat
            else
                Err InvalidFormat

        _ ->
            Err InvalidFormat

expect cursorPosition "^[[7;26R" == Ok { row: 26, col: 7 }

takeNumber : { val : U16, rest : List U8 } -> { val : U16, rest : List U8 }
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

parseCursor = \bytes ->
    { val: row, rest: afterFirst } = takeNumber { val: 0, rest: List.dropFirst bytes 2 }
    { val: col } = takeNumber { val: 0, rest: List.dropFirst afterFirst 1 }
    { row, col }

# test "^[[33;1R"
expect parseCursor (List.join [[27], Str.toUtf8 "[33;1R"]) == { row: 33, col: 1 }

parseScreen = \bytes ->
    { val: rows, rest: afterFirst } = takeNumber { val: 0, rest: List.dropFirst bytes 4 }
    { val: cols } = takeNumber { val: 0, rest: List.dropFirst afterFirst 1 }
    { rows, cols }

# test "^[[8;10;159"
expect parseScreen (List.join [[27], Str.toUtf8 "[8;10;159"]) == { rows: 10, cols: 159 }
