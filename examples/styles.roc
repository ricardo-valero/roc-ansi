app "styles"
    packages {
        cli: "https://github.com/roc-lang/basic-cli/releases/download/0.8.1/x8URkvfyi9I0QhmVG98roKBUs_AZRkLFwFJVJ3942YA.tar.br",
        ansi: "../package/main.roc",
    }
    imports [cli.Stdout, ansi.Core]
    provides [main] to cli

main =
    [
        "Bold On" |> Core.withStyles [Bold On] |> Core.withStyles [Default],
        "Faint On" |> Core.withStyles [Faint On] |> Core.withStyles [Default],
        "Italic On" |> Core.withStyles [Italic On] |> Core.withStyles [Default], # TODO why is bold not kept after using italic?
        "Strikethrough On" |> Core.withStyles [Strikethrough On] |> Core.withStyles [Default],
        "Underline On" |> Core.withStyles [Underline On] |> Core.withStyles [Default],
        "Invert On" |> Core.withStyles [Invert On] |> Core.withStyles [Default],
        "Blink Slow" |> Core.withStyles [Blink Slow] |> Core.withStyles [Default],
        "Blink Rapid" |> Core.withStyles [Blink Rapid] |> Core.withStyles [Default],
        "Combination" |> Core.withStyles [Bold On, Faint On, Italic On, Strikethrough On, Underline On],
        "This should have the last style",
        "This shouldn't have any style" |> Core.withStyles [Default],
    ]
    |> Str.joinWith "\n"
    |> Stdout.line
