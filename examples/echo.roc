app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
}

import cli.Stdin
import cli.Stdout

main! = |{}|
    _ = Stdout.line! "Shout into this cave and hear the echo!"
    tick!

# tick! : {} -> Task [Step {}, Done {}] _
tick! = |{}|
    when Stdin.line! {} is
        Ok str -> Stdout.line! (echo str) |> Step
        Err EndOfFile -> Stdout.line! (echo "Received end of input (EOF).") |> Done
        Err (StdinErr err) -> Stdout.line! (echo "Unable to read input ${Inspect.to_str err}") |> Done

# echo : Str -> Str
echo = |shout|
    silence = |length|
        List.repeat ' ' length

    shout
    |> Str.to_utf8
    |> List.map_with_index
        (|_, i|
            length = (List.len (Str.to_utf8 shout) - i)
            phrase = (List.split_at (Str.to_utf8 shout) length).before

            List.concat (silence (if i == 0 then 2 * length else length)) phrase)
    |> List.join
    |> Str.from_utf8
    |> Result.with_default ""
