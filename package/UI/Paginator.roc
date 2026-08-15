module [Model, update, defaultBinding]

## Paginator
# A paginator is just a specific case of a VirtualList
Model a : {
    # behavior
    page : Int a,
    perPage : Int a,
    totalPages : Int a,
    style : StyleMap,
}

init : Model a
init = {
    page: 1,
    perPage: 1,
    totalPages: 1,
    style: defaultStyle,
}

## PaginatorType specifies the way we render pagination.
PaginatorType : [Arabic, Dots]

# instead of this
# defaultBinding = {
#    prev: ["pgup", "left", "h"],
#    next: ["pgdown", "right", "l"],
# }

defaultBinding = \input ->
    when input is
        Arrow Left | Pg Up | Lower H -> Prev
        Arrow Right | Pg Down | Lower L -> Next
        Number n -> To n

StyleMap : {
    activeDot : Str,
    inactiveDot : Str,
    paginatorType : PaginatorType,
    arabicFormat : Str,
}

defaultStyle : StyleMap
defaultStyle = {
    activeDot: "•",
    inactiveDot: "○",
    arabicFormat: "%d/%d",
    paginatorType: Arabic,
}

## Calculate the total number of pages from a given number of items.
setTotalPages : Int a, Model a -> Model a
setTotalPages = \items, model ->
    total =
        if items < 1 then
            model.totalPages
        else
            n = items // model.perPage
            if items % model.perPage > 0 then
                n + 1
            else
                n
    { model & totalPages: total }

## Returns the number of items on the current page given the total number of items passed as an argument.
itemsOnPage : Int a, Model a -> Int a
itemsOnPage = \totalItems, model ->
    if totalItems < 1 then
        0
    else
        (start, end) = getSliceBounds totalItems model
        end - start

## For paginating slices.
getSliceBounds : Int a, Model a -> (Int a, Int a)
getSliceBounds = \length, model ->
    start = model.page * model.perPage
    end = Num.min (model.page * model.perPage + model.perPage) length
    (start, end)

# Returns whether or not we're on the last page.
isLast : Model a -> Bool
isLast = \model -> Num.intCast model.page == Num.intCast model.totalPages - 1

## Returns whether or not we're on the first page.
isFirst : Model a -> Bool
isFirst = \model -> Num.intCast model.page == 1

Message a : [Next, Prev, To (Int a), First, Last]

## Binds keystrokes to pagination.
# Didnt know I was kind of making the same API as https://github.com/jschomay/elm-paginate/blob/3.1.2/src/Paginate/Custom.elm
update : Message a, Model a -> Model a
update = \msg, model ->
    when msg is
        To page -> { model & page }
        First -> update (To 0) model
        Last -> update (To (model.totalPages - 1)) model
        Prev ->
            if !(isFirst model) then
                update (To (model.page - 1)) model
            else
                model

        Next ->
            if !(isLast model) then
                update (To (model.page + 1)) model
            else
                model

# defaultCommands : [Arrow [Left, Right], Number (Int a)] -> Message a

## Renders the pagination to a string.
view : Model a -> Str
view = \model ->
    when model.style.paginatorType is
        Dots -> dotsView model
        Arabic -> arabicView model

dotsView : Model a -> Str
dotsView = \model ->
    List.range { start: At 0, end: Before model.totalPages }
    |> List.map (\i -> if Num.intCast i == Num.intCast model.page then model.style.activeDot else model.style.inactiveDot)
    |> Str.joinWith ""

arabicView : Model a -> Str
arabicView = \model ->
    [model.page + 1, model.totalPages] |> List.map Num.toStr |> Str.joinWith " / "
