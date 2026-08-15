module [Model]

import Tui.Binding exposing [Binding]

BindingMap : {
    pageDown : Binding,
    pageUp : Binding,
    halfPageUp : Binding,
    halfPageDown : Binding,
    down : Binding,
    up : Binding,
}

defaultBinding : BindingMap
defaultBinding = {
    pageDown: Tui.Binding.make { keys: ["pgdown", " ", "f"], description: Some "page down" },
    pageUp: Tui.Binding.make { keys: ["pgup", "b"], description: Some "page up" },
    halfPageUp: Tui.Binding.make { keys: ["u", "ctrl+u"], description: Some "½ page up" },
    halfPageDown: Tui.Binding.make { keys: ["d", "ctrl+d"], description: Some "½ page down" },
    up: Tui.Binding.make { keys: ["up", "k"], description: Some "up" },
    down: Tui.Binding.make { keys: ["down", "j"], description: Some "down" },
}

Model a : {
    width : Int a,
    height : Int a,
    yOffset : Int a,
    lines : List Str,
    style : StyleMap,
}

StyleMap : {
    border : Str,
    padding : Str,
    margin : Str,
}

init : Int a, Int a -> Model a
init = \width, height -> {
    width: width,
    height: height,
    yOffset: 0,
    lines: [],
    style: { border: "1px solid black", padding: "10px", margin: "10px" },
}
