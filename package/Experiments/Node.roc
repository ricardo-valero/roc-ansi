module [Node]

Attribute : [Attribute Str Str]
Node : [Element Str (List Attribute) (List Node), Text Str]

text : Str -> Node
text = Text

element : Str -> (List Attribute, List Node -> Node)
element = \tagName ->
    \attrs, children ->
        Element tagName attrs children

voidElement : Str -> (List Attribute -> Node)
voidElement = \tagName ->
    \attrs ->
        Element tagName attrs []

attribute : Str -> (Str -> Attribute)
attribute = \attrName ->
    \attrValue -> Attribute attrName attrValue

vstack = element "vstack"
hstack = element "hstack"
