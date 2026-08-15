app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
    ansi: "../package/main.roc",
}

import cli.Stdout
import cli.Stdin
import ansi.ANSI

tick : {} -> Task [Step {}, Done {}] _
tick! = |_|
    when Stdin.line |> Task.result! is
        Ok _ -> Stdout.line (talk {}) |> Task.map Step
        Err (StdinErr EndOfFile) -> Stdout.line ("Received end of input (EOF).") |> Task.map Done
        Err (StdinErr err) -> Stdout.line ("Unable to read input ${Inspect.toStr err}") |> Task.map Done

talk! = |_|
    [
        "Your screen size is: ",
        (Screen Size) |> Control |> ANSI.toStr,
        "\nYour cursor position is: ",
        (Position Get) |> Cursor |> Control |> ANSI.toStr,
    ]
    |> Str.joinWith ""

main! =
    Stdout.line! "Send anything to see your terminal's screen size"
    Task.loop {} tick
