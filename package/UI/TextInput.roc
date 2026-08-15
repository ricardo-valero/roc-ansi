module [Model]

import Ui.Binding exposing [Binding]
import Ui.Cursor
import Style exposing [Style]

## Text Input
Model : {
    # behavior
    echoMode : EchoMode,
    cursor : Ui.Cursor.Model,
    # Indicates whether user input focus should be on this input
    # component. When false, ignore keyboard input and hide the cursor.
    focus : Bool,
    # Cursor position.
    position : U16,
    # The maximum amount of characters this input element will
    # accept. If 0, there's no limit.
    charLimit : U16,
    binding : BindingMap,
    # Underlying text value.
    value : Str,

    # style/view/layout
    style : StyleMap,
    # Width is the maximum number of characters that can be displayed at once.
    # It essentially treats the text field like a horizontally scrolling
    # viewport. If 0 this setting is ignored.
    width : U16,
    # Used to emulate a viewport when width is set and the content is
    # overflowing.
    offset ? U16,
    offsetRight ? U16,

    # These can live outside the element (Maybe create a FormInput?)
    error : Str,
    prompt : Str,
    placeholder : Str,

    # Checks whether or not the text within the input is valid.
    validate : Result Str [ValidationError Str],
    # rune sanitizer for input.
    sanitizer : Result Str [SanitizerError Str],
    # Should the input suggest to complete
    showSuggestions : Bool,
    # List of suggestions that may be used to complete the input.
    suggestions : List Str,
    # matchedSuggestions : List Str,
    # currentSuggestionIndex : U16,
}

BindingMap : {
    move : {
        charBackward : Binding,
        charForward : Binding,
        wordBackward : Binding,
        wordForward : Binding,
        lineStart : Binding,
        lineEnd : Binding,
    },
    delete : {
        charBackward : Binding,
        charForward : Binding,
        wordBackward : Binding,
        wordForward : Binding,
        beforeCursor : Binding,
        afterCursor : Binding,
    },
    paste : Binding,
    suggestion : {
        accept : Binding,
        next : Binding,
        prev : Binding,
    },
}

defaultBinding : BindingMap
defaultBinding = {
    move: {
        charBackward: Tui.Binding.make { keys: ["left", "ctrl+b"] },
        charForward: Tui.Binding.make { keys: ["right", "ctrl+f"] },
        wordBackward: Tui.Binding.make { keys: ["alt+left", "ctrl+left", "alt+b"] },
        wordForward: Tui.Binding.make { keys: ["alt+right", "ctrl+right", "alt+f"] },
        lineStart: Tui.Binding.make { keys: ["home", "ctrl+a"] },
        lineEnd: Tui.Binding.make { keys: ["end", "ctrl+e"] },
    },
    delete: {
        charBackward: Tui.Binding.make { keys: ["backspace", "ctrl+h"] },
        charForward: Tui.Binding.make { keys: ["delete", "ctrl+d"] },
        wordBackward: Tui.Binding.make { keys: ["alt+backspace", "ctrl+w"] },
        wordForward: Tui.Binding.make { keys: ["alt+delete", "alt+d"] },
        beforeCursor: Tui.Binding.make { keys: ["ctrl+u"] },
        afterCursor: Tui.Binding.make { keys: ["ctrl+k"] },
    },
    paste: Tui.Binding.make { keys: ["ctrl+v"] },
    suggestion: {
        accept: Tui.Binding.make { keys: ["tab"] },
        next: Tui.Binding.make { keys: ["down", "ctrl+n"] },
        prev: Tui.Binding.make { keys: ["up", "ctrl+p"] },
    },
}

## Sets the input behavior of the text input field.
EchoMode : [
    ## Displays text as is. This is the default behavior.
    Default,
    ## Displays the mask instead of actual
    ## characters. This is commonly used for password fields.
    Redacted Str,
    ## Displays nothing as characters are entered. This is commonly
    ## seen for password fields on the command line.
    None,
]

StyleMap : {
    prompt : Style,
    text : Style,
    placeholder : Style,
    completion : Style,
}

defaultStyle : StyleMap
defaultStyle = {
    prompt: Default,
    text: Default,
    placeholder: Foreground (C256 240),
    completion: Foreground (C256 240),
}

defaultCursor = ""

# defaultModel : Model
init = {
    prompt: "> ",
    echoMode: Default,
    charLimit: 0,
    cursor: defaultCursor,
    style: defaultStyle,
    binding: defaultBinding,
    showSuggestions: Bool.false,
    suggestions: [],
    focus: Bool.false,
    position: 0,
}
