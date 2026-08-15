app [main] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br",
    ansi: "../package/main.roc",
}

import cli.Tty
import cli.Stdout
import cli.Utc
import ansi.ANSI

Spinner : List Str
SpinnerType : [Line, Dot, MiniDot, Jump, Pulse, Point, Meter, Hamburger, Ellipsis]

spinners : SpinnerType -> Spinner
spinners = \type ->
    when type is
        Line -> ["|", "/", "-", "\\"]
        Dot -> ["⣾ ", "⣽ ", "⣻ ", "⢿ ", "⡿ ", "⣟ ", "⣯ ", "⣷ "]
        MiniDot -> ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        Jump -> ["⢄", "⢂", "⢁", "⡁", "⡈", "⡐", "⡠"]
        Pulse -> ["█", "▓", "▒", "░"]
        Point -> ["∙∙∙", "●∙∙", "∙●∙", "∙∙●"]
        Meter -> ["▱▱▱", "▰▱▱", "▰▰▱", "▰▰▰", "▰▰▱", "▰▱▱", "▱▱▱"]
        Hamburger -> ["☱", "☲", "☴", "☲"]
        Ellipsis -> ["", ".", "..", "..."]

defaultSpinner : Spinner
defaultSpinner = spinners Dot

Model : {
    prevDraw : Utc.Utc,
    currDraw : Utc.Utc,
    keyframe : U64,
    frames : Spinner,
    interval : U128,
    running : Bool,
    state : [HomePage, SecondPage, ThirdPage, UserExited],
}

init : Model
init = {
    prevDraw: Utc.fromMillisSinceEpoch 0,
    currDraw: Utc.fromMillisSinceEpoch 0,
    keyframe: 0,
    frames: defaultSpinner,
    interval: 2000,
    running: Bool.true,
    state: HomePage,
}

runUILoop : Model -> Task.Task [Step Model, Done Model] _
runUILoop = \prevModel ->
    now = Utc.now! {}
    delta = Utc.deltaAsMillis prevModel.prevDraw now
    if prevModel.running then
        if delta >= prevModel.interval then
            keyframe = (prevModel.keyframe + 1) % List.len prevModel.frames
            model = { prevModel & keyframe, prevDraw: prevModel.currDraw, currDraw: now }
            Stdout.write! (List.get model.frames model.keyframe |> Result.withDefault "")
            Task.ok (Step model)
        else
            # Task.sleep (model.nextTick - now)
            Task.ok (Step prevModel)
    else
        Task.ok (Done prevModel)

# command =
#    when (input, model.state) is
#        (Arrow Up, _) -> MoveCursor Up
#        (Arrow Down, _) -> MoveCursor Down
#        (Arrow Left, _) -> MoveCursor Left
#        (Arrow Right, _) -> MoveCursor Right
#        (Lower D, _) -> ToggleDebug
#        (Action Enter, HomePage) -> UserToggledScreen
#        (Action Enter, ConfirmPage s) -> UserWantToDoSomthing s
#        (Action Escape, ConfirmPage _) -> UserToggledScreen
#        (Action Escape, _) -> Exit
#        (Ctrl C, _) -> Exit
#        (Unsupported _, _) -> Nothing
#        (_, _) -> Nothing

main =
    Tty.enableRawMode! {}
    model = Task.loop! init runUILoop
    Stdout.write! (ANSI.toStr Reset)
    Tty.disableRawMode! {}
    when model.state is
        HomePage -> Stdout.line "Doing something with $... now exiting..."
        _ -> Stdout.line "Exiting..."
