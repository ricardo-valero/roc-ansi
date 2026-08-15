module [
    StyleMap,
    Context,
    Api,
]

Style : Str
StyleMap : {
    root : Style,
    item : Style,
    ellipsis : Style,
    prevTrigger : Style,
    nextTrigger : Style,
}
# HOWTO: /* We add a data-disabled attribute to the prev/next items when on the first/last page  */
# [data-part="prev-trigger"][data-disabled] {
# [data-part="next-trigger"][data-disabled] {

Dir : [Ltr, Rtl]
PageChangeDetails : Str
PageSizeChangeDetails : Str

Context a : {
    # Total number of data items
    count : a,
    # Number of data items per page
    pageSize : a,
    # Number of pages to show beside active page
    siblingCount : a,
    # The active page
    page : a,
    # Called when the page number is changed
    onPageChange : PageChangeDetails -> [],
    # Called when the page size is changed
    onPageSizeChange : PageSizeChangeDetails -> [],
    # The document's text/writing direction.
    dir : Dir,
}

Pages : Str
PageRange : Str
Api a b : {
    # The current page.
    page : a,
    # The number of data items per page.
    pageSize : a,
    # The total number of pages.
    totalPages : a,
    # The page range. Represented as an array of page numbers (including ellipsis)
    pages : Pages,
    # The previous page.
    previousPage : a,
    # The next page.
    nextPage : a,
    # The page range. Represented as an object with `start` and `end` properties.
    pageRange : PageRange,
    # Function to slice an array of data based on the current page.
    slice : List b -> List b,
    # Function to set the total number of pages.
    setCount : a -> [],
    # Function to set the page size.
    setPageSize : a -> [],
    # Function to set the current page.
    setPage : a -> [],
    # Function to go to the next page.
    goToNextPage : a -> [],
    # Function to go to the previous page.
    goToPrevPage : a -> [],
    # Function to go to the first page.
    goToFirstPage : a -> [],
    # Function to go to the last page.
    goToLastPage : a -> [],
}
