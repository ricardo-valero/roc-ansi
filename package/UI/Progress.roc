module [Model]

Char : Str

import Color exposing [Color]
import Utils

Model a : {
    # behavior
    min : a,
    max : a,
    value : [Indeterminate, a],
    percent : Dec,

    # view/layout/style
    width : Int a,
    full : Char,
    fullColor : Color,
    empty : Char,
    emptyColor : Color,
    # This should be unnecessary and not part of the core progress bar,
    # it should be able to show it outside since the value is passed in
    showPercentage : Bool,
    percentFormat : Str,
    # percentageStyle : Str -> Str,
    # This is all animation
    spring : Spring a,
    springCustomized : Bool,
    velocity : Dec,
    useRamp : Bool,
    rampColorA : Color,
    rampColorB : Color,
    scaleRamp : Bool,
}

Spring a : {
    fps : Int a,
    frequency : Dec,
    damping : Dec,
}

init : Model U16
init = {
    min: 0,
    max: 100,
    value: 0,
    width: 40,
    full: "█",
    fullColor: Hex 0x7571F9,
    empty: "░",
    emptyColor: Hex 0x606060,
    showPercentage: Bool.true,
    percentFormat: " %3.0f%%",
    ## percentageStyle: identity,
    spring: { fps: 60, frequency: 18.0, damping: 1.0 },
    springCustomized: Bool.false,
    velocity: 0.0,
    useRamp: Bool.false,
    rampColorA: Rgb (0, 0, 0),
    rampColorB: Rgb (0, 0, 0),
    scaleRamp: Bool.false,
}

Posix : U124
Msg : [NextFrame Posix, UpdatePercent Dec]

update : Msg, Model a -> (Model a, Cmd Msg)
update = \msg, model ->
    when msg is
        NextFrame _ ->
            if !(isAnimating model) then
                (model, Cmd.none)
            else
                (newPercent, newVelocity) = springUpdate model.spring model.percentShown model.velocity model.targetPercent
                ({ model & percentShown: newPercent, velocity: newVelocity }, Task.perform NextFrame Time.now)

        UpdatePercent p ->
            newModel = { model & targetPercent: p |> (Utils.clamp 0 1) }
            (newModel, Task.perform NextFrame Time.now)

isAnimating : Model a -> Bool
isAnimating = \model ->
    dist = Num.abs (model.percentShown - model.targetPercent)
    !(dist < 0.001 && model.velocity < 0.01)

# A simple spring update calculation
springUpdate : Spring, Dec, Dec, Dec -> (Dec, Dec)
springUpdate = \spring, current, velocity, target ->
    (current + (target - current) * 0.1, velocity * 0.9)

# view : Model -> Str
# view = \model ->
#       percentView =
#           if model.showPercentage then
#               model.percentageStyle (String.fromFloat (model.percentShown * 100) ++ "%")
#           else
#               ""
#       filledWidth =  Num.round ((toFloat model.width) * model.percentShown)
#       emptyWidth = model.width - filledWidth
#    in
#    div []
#        [ div [ style "color" model.fullColor ] [ text (String.repeat filledWidth (String.fromChar model.full)) ]
#        , div [ style "color" model.emptyColor ] [ text (String.repeat emptyWidth (String.fromChar model.empty)) ]
#        , div [] [ text percentView ]
#        ]
