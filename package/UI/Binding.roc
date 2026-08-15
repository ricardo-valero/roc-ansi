module [
    Binding,
    make,
]

Binding : {
    enabled : Bool,
    keys : List Str,
    description : [Some Str, None],
}

make : { enabled ? Bool, keys ? List Str, description ? [Some Str, None] } -> Binding
make = \{ enabled ? Bool.true, keys ? [], description ? None } -> { enabled, keys, description }
