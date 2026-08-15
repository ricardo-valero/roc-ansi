module [Model]

import Utils
import Tui.Binding exposing [Binding]

Maybe value : [Some value, None]
Char : Str
Node : Str

# TODO: How to do Str.length?

Model a : {
    prompt : Node,
    placeholder : Node,
    charLimit : Int a,
    value : Str,
    cursorIndex : Int a,
    lineCount : Int a,
    lineNumbers : List (Int a),
    focused : Bool,
    error : Maybe Str,
    bindings : BindingMap,
    styles : StyleMap,
    width : Int a,
    height : Int a,
    maxWidth : Int a,
    maxHeight : Int a,
}

StyleMap : {
    base : Str,
    cursorLine : Str,
    cursorLineNumber : Str,
    endOfBuffer : Str,
    lineNumber : Str,
    placeholder : Str,
    prompt : Str,
    text : Str,
}

BindingMap : {
    move : {
        charBackward : Binding,
        charForward : Binding,
        wordBackward : Binding,
        wordForward : Binding,
        lineEnd : Binding,
        lineStart : Binding,
        linePrev : Binding,
        lineNext : Binding,
        inputStart : Binding,
        inputEnd : Binding,
    },
    delete : {
        charBackward : Binding,
        charForward : Binding,
        wordBackward : Binding,
        wordForward : Binding,
        afterCursor : Binding,
        beforeCursor : Binding,
    },
    insertLine : Binding,
    paste : Binding,
    capitalizeWordForward : Binding,
    lowercaseWordForward : Binding,
    uppercaseWordForward : Binding,
    transposeCharBackward : Binding,
}

defaultBindings : BindingMap
defaultBindings = {
    move: {
        charForward: Tui.Binding.make { keys: ["right", "ctrl+f"], description: Some "character forward" },
        charBackward: Tui.Binding.make { keys: ["left", "ctrl+b"], description: Some "character backward" },
        wordForward: Tui.Binding.make { keys: ["alt+right", "alt+f"], description: Some "word forward" },
        wordBackward: Tui.Binding.make { keys: ["alt+left", "alt+b"], description: Some "word backward" },
        lineStart: Tui.Binding.make { keys: ["home", "ctrl+a"], description: Some "line start" },
        lineEnd: Tui.Binding.make { keys: ["end", "ctrl+e"], description: Some "line end" },
        linePrev: Tui.Binding.make { keys: ["up", "ctrl+p"], description: Some "previous line" },
        lineNext: Tui.Binding.make { keys: ["down", "ctrl+n"], description: Some "next line" },
        inputStart: Tui.Binding.make { keys: ["alt+<", "ctrl+home"], description: Some "input begin" },
        inputEnd: Tui.Binding.make { keys: ["alt+>", "ctrl+end"], description: Some "input end" },
    },
    delete: {
        charBackward: Tui.Binding.make { keys: ["backspace", "ctrl+h"], description: Some "delete character backward" },
        charForward: Tui.Binding.make { keys: ["delete", "ctrl+d"], description: Some "delete character forward" },
        wordBackward: Tui.Binding.make { keys: ["alt+backspace", "ctrl+w"], description: Some "delete word backward" },
        wordForward: Tui.Binding.make { keys: ["alt+delete", "alt+d"], description: Some "delete word forward" },
        afterCursor: Tui.Binding.make { keys: ["ctrl+k"], description: Some "delete after cursor" },
        beforeCursor: Tui.Binding.make { keys: ["ctrl+u"], description: Some "delete before cursor" },
    },
    insertLine: Tui.Binding.make { keys: ["enter", "ctrl+m"], description: Some "insert newline" },
    paste: Tui.Binding.make { keys: ["ctrl+v"], description: Some "paste" },
    capitalizeWordForward: Tui.Binding.make { keys: ["alt+c"], description: Some "capitalize word forward" },
    lowercaseWordForward: Tui.Binding.make { keys: ["alt+l"], description: Some "lowercase word forward" },
    uppercaseWordForward: Tui.Binding.make { keys: ["alt+u"], description: Some "uppercase word forward" },
    transposeCharBackward: Tui.Binding.make { keys: ["ctrl+t"], description: Some "transpose character backward" },
}

defaultStyles : StyleMap
defaultStyles = {
    base: "",
    cursorLine: "",
    cursorLineNumber: "",
    endOfBuffer: "",
    lineNumber: "",
    placeholder: "",
    prompt: "",
    text: "",
}

init : Model U16
init = {
    prompt: "",
    placeholder: "",
    charLimit: 400,
    value: "",
    cursorIndex: 0,
    lineCount: 1,
    lineNumbers: [1],
    focused: Bool.false,
    width: 40,
    height: 6,
    maxWidth: 500,
    maxHeight: 99,
    bindings: defaultBindings,
    styles: defaultStyles,
    error: None,
}

Msg a : [SetValue Str, InsertChar Char, DeleteChar, MoveCursorForward, MoveCursorBackward, SetCursor (Int a), Focus, Blur, NoOp]

splitAt : Int *, Str -> (Str, Str)
splitAt = \index, str ->
    (Str.left index str, dropLeft index str)

update : Msg *, Model a -> Model a
update = \msg, model ->
    when msg is
        SetValue val -> { model & value: val, cursorIndex: Num.intCast (Str.countUtf8Bytes val) }
        InsertChar char ->
            if model.cursorIndex < model.charLimit then
                (before, after) = splitAt model.cursorIndex model.value
                { model & value: [before, char, after] |> Str.joinWith "", cursorIndex: model.cursorIndex + 1 }
            else
                model

        DeleteChar ->
            if model.cursorIndex > 0 then
                (before, after) = splitAt (model.cursorIndex - 1) model.value
                { model & value: [before, "dropLeft 1 after"] |> Str.joinWith "", cursorIndex: model.cursorIndex - 1 }
            else
                model

        MoveCursorForward -> { model & cursorIndex: Num.min (model.cursorIndex + 1) (Num.intCast (Str.countUtf8Bytes model.value)) }
        MoveCursorBackward -> { model & cursorIndex: Num.max 0 (model.cursorIndex - 1) }
        SetCursor pos -> { model & cursorIndex: pos |> (Utils.clamp 0 (Num.intCast (Str.countUtf8Bytes model.value))) |> Num.intCast }
        Focus -> { model & focused: Bool.true }
        Blur -> { model & focused: Bool.false }
        NoOp -> model

## VIEW

# view : Model -> Html Msg
# view model =
#    div []
#        [ input [ placeholder model.placeholder, value model.value, onInput SetValue ] []
#        ]
