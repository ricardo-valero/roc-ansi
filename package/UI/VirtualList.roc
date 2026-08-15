module [Virtualizer]

ScrollDirection : [Forward, Backward]
ScrollAlignment : [Start, Center, End, Auto]
ScrollBehavior : [Auto, Smooth]

ScrollToOptions : {
    align ? ScrollAlignment,
    behavior ? ScrollBehavior,
}

ScrollToOffsetOptions : ScrollToOptions
ScrollToIndexOptions : ScrollToOptions

Range a : {
    startIndex : Int a,
    endIndex : Int a,
    overscan : Int a,
    count : Int a,
}

Key : Str

VirtualItem : {
    key : Key,
    index : Int a,
    start : Float,
    end : Float,
    size : Float,
    lane : Int,
    measureElement : Maybe (Html msg),
}

Rect a : { width : a, height : a }

# defaultKeyExtractor : Int -> Key
defaultKeyExtractor = \index -> Num.toStr index

# defaultRangeExtractor : Range -> List Int
defaultRangeExtractor = \range ->
    start = Num.max (range.startIndex - range.overscan) 0
    end = Num.min (range.endIndex + range.overscan) (range.count - 1)
    List.range { start: At start, end: At end }

# observeElementRect : (Rect -> msg) -> Html msg -> Html msg
# observeElementRect = \cb, element ->
# handler = \rect -> \roundedRect -> { rect & width : round rect.width, height : round rect.height } cb roundedRect element

# observeWindowRect : (Rect -> msg) -> Browser.Dom.Window -> Task Never (Cmd msg)
# observeWindowRect cb window =
#        handler () =
#            cb { width = window.innerWidth, height = window.innerHeight }
#    Task.perform identity (Task.succeed handler)

# supportsScrollend : Bool
# supportsScrollend =
#    True

# observeElementOffset : (Float -> Bool -> msg) -> Html msg -> Html msg
# observeElementOffset cb element =
#    let
#        offset =
#            0

#        handler isScrolling =
#            let
#                offsetValue =
#                    offset # Horizontal scroll handling should be done here
#            in
#            cb offsetValue isScrolling
#    in
#    element

# observeWindowOffset : (Float -> Bool -> msg) -> Browser.Dom.Window -> Task Never (Cmd msg)
# observeWindowOffset cb window =
#    let
#        offset =
#            0

#        handler isScrolling =
#            cb offset isScrolling
#    in
#    Task.perform identity (Task.succeed handler)

# measureElement : Html msg -> Float
# measureElement element =
#    # Handle measuring of the element and return the size.
#    0

# windowScroll : Float -> { adjustments : Float, behavior : Maybe ScrollBehavior } -> Browser.Dom.Window -> Task Never (Cmd msg)
# windowScroll offset { adjustments, behavior } window =
#    let
#        toOffset =
#            offset + adjustments
#    in
#    Task.perform identity (Task.succeed ())

# elementScroll : Float -> { adjustments : Float, behavior : Maybe ScrollBehavior } -> Html msg -> Html msg
# elementScroll offset { adjustments, behavior } element =
#    # Handle scrolling of the element
#    element

VirtualizerOptions =
    { count : Int
    , getScrollElement : () -> Maybe (Html msg)
    , estimateSize : Int -> Float
    , scrollToFn : Float -> { adjustments : Float, behavior : Maybe ScrollBehavior } -> VirtualizerOptions -> Html msg
    , observeElementRect : (Rect -> msg) -> Html msg -> Html msg
    , observeElementOffset : (Float -> Bool -> msg) -> Html msg -> Html msg
    , debug : Bool
    , initialRect : Rect
    , onChange : VirtualizerOptions -> Bool -> msg
    , measureElement : Html msg -> Float
    , overscan : Int
    , horizontal : Bool
    , paddingStart : Float
    , paddingEnd : Float
    , scrollPaddingStart : Float
    , scrollPaddingEnd : Float
    , initialOffset : Float
    , getItemKey : Int -> Key
    , rangeExtractor : Range -> List Int
    , scrollMargin : Float
    , gap : Float
    , indexAttribute : String
    , initialMeasurementsCache : List VirtualItem
    , lanes : Int
    , isScrollingResetDelay : Int
    , enabled : Bool
    , isRtl : Bool
    }

# Virtualizer =
#    { options : VirtualizerOptions
#    , scrollElement : Maybe (Html msg)
#    , isScrolling : Bool
#    , measurementsCache : List VirtualItem
#    , itemSizeCache : Dict Key Float
#    , scrollRect : Maybe Rect
#    , scrollOffset : Maybe Float
#    , scrollDirection : Maybe ScrollDirection
#    }

# initVirtualizer : VirtualizerOptions -> Virtualizer
# initVirtualizer opts =
#    { options = opts
#    , scrollElement = Nothing
#    , isScrolling = False
#    , measurementsCache = []
#    , itemSizeCache = Dict.empty
#    , scrollRect = Nothing
#    , scrollOffset = Nothing
#    , scrollDirection = Nothing
#    }

# Example implementation of an update function handling a "scroll" event.
# update : msg -> Virtualizer -> (Virtualizer, Cmd msg)
# update msg model =
#    # Handle update logic for scrolling
#    ( model, Cmd.none )

# view : Virtualizer -> Html msg
# view model =
#    # Render the virtualized list or elements
#    Html.div [] []
