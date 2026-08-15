module [Join]
# Pure Type-Driven SQL Builder
# Everything is an expression of types - no primitives

# Generic property selector for any record type
Prop a : a -> *

# Core expression type - everything is an expression
Expr : [
    # Column references through property selectors
    Column (Prop *),

    # Literals
    Literal Literal,

    # Functions as types
    Year Expr,
    Month Expr,
    Day Expr,
    Upper Expr,
    Lower Expr,
    Substring Expr Expr Expr, # SUBSTRING(expr, start, length)

    # Aggregates as expressions
    Count Expr,
    Sum Expr,
    Avg Expr,
    Min Expr,
    Max Expr,
    CountAll,

    # Arithmetic
    Add Expr Expr,
    Subtract Expr Expr,
    Multiply Expr Expr,
    Divide Expr Expr,

    # Boolean expressions (conditions are just boolean expressions)
    Eq Expr Expr,
    Gt Expr Expr,
    Lt Expr Expr,
    Gte Expr Expr,
    Lte Expr Expr,
    Like Expr Expr,
    In Expr (List Expr),
    And (List Expr),
    Or (List Expr),
    Not Expr,

    # Subqueries
    Subquery Query,

    # CASE expressions
    Case (List (Expr, Expr)) Expr, # CASE WHEN cond THEN value ... ELSE default END
]

# Literals
Literal : [
    Number I64,
    Decimal F64,
    String Str,
    Bool Bool,
    Null,
]

# Simplified SelectItem - everything is an expression
SelectItem : [
    Expression Expr,
    Alias Expr Str,
]

# Table references
Table : [
    Named Str,
    Aliased Str Str,
    Subquery Query Str, # Subquery with alias
]

# Join types
JoinType : [Inner, Left, Right, Full, Cross]

# Join specification
Join : {
    joinType : JoinType,
    table : Table,
    on : [Some Expr, None], # None for CROSS JOIN
}

# Order specification
OrderBy : (Expr, [Asc, Desc])

# Now let's explore enforcing SQL logical order through types
# Each stage can only be constructed from the previous stage

# Stage 1: FROM - must start here
FromStage : {
    table : Table,
}

# Stage 2: JOIN - can only be built from FromStage
JoinStage : {
    from : FromStage,
    joins : List Join,
}

# Stage 3: WHERE - can be built from FromStage or JoinStage
WhereStage a : {
    previous : a, # Can be FromStage or JoinStage
    condition : [Some Expr, None],
}

# Stage 4: GROUP BY - can be built from previous stages
GroupByStage a : {
    previous : a,
    columns : List Expr,
}

# Stage 5: HAVING - can only be built from GroupByStage
HavingStage a : {
    previous : GroupByStage a,
    condition : [Some Expr, None],
}

# Stage 6: SELECT - can be built from any previous stage
SelectStage a : {
    previous : a,
    items : List SelectItem,
}

# Stage 7: ORDER BY - can only be built from SelectStage
OrderByStage a : {
    previous : SelectStage a,
    orders : List OrderBy,
}

# Stage 8: OFFSET - can be built from SelectStage or OrderByStage
OffsetStage a : {
    previous : a,
    offset : U64,
}

# Stage 9: LIMIT - can be built from SelectStage, OrderByStage, or OffsetStage
LimitStage a : {
    previous : a,
    limit : U64,
}

# Final Query type - any of the terminal stages
Query : [
    FromQuery FromStage,
    JoinQuery JoinStage,
    WhereQuery (WhereStage *),
    GroupByQuery (GroupByStage *),
    HavingQuery (HavingStage *),
    SelectQuery (SelectStage *),
    OrderByQuery (OrderByStage *),
    OffsetQuery (OffsetStage *),
    LimitQuery (LimitStage *),
]

# Constructor functions that enforce order

# Stage 1: Must start with FROM
from : Str -> FromStage
from = |tableName| { table: Named tableName }

fromAs : Str, Str -> FromStage
fromAs = |tableName, a| { table: Aliased tableName a }

fromSubquery : Query, Str -> FromStage
fromSubquery = |query, a| { table: Subquery query a }

# Stage 2: JOIN (can only be built from FROM)
join : FromStage, JoinType, Table, Expr -> JoinStage
join = |fromStage, joinType, table, condition| {
    from: fromStage,
    joins: [{ joinType, table, on: Some condition }],
}

addJoin : JoinStage, JoinType, Table, Expr -> JoinStage
addJoin = |joinStage, joinType, table, condition| {
    from: joinStage.from,
    joins: List.append joinStage.joins { joinType, table, on: Some condition },
}

# Stage 3: WHERE (can be built from FROM or JOIN)
where : a, Expr -> WhereStage a
where = |previous, condition| { previous, condition: Some condition }

# Stage 4: GROUP BY
groupBy : a, List Expr -> GroupByStage a
groupBy = |previous, columns| { previous, columns }

# Stage 5: HAVING (can only be built from GROUP BY)
having : GroupByStage a, Expr -> HavingStage a
having = |groupByStage, condition| { previous: groupByStage, condition: Some condition }

# Stage 6: SELECT (can be built from any previous stage)
select : a, List SelectItem -> SelectStage a
select = |previous, items| { previous, items }

# Stage 7: ORDER BY (can only be built from SELECT)
orderBy : SelectStage a, List OrderBy -> OrderByStage a
orderBy = |selectStage, orders| { previous: selectStage, orders }

# Stage 8: OFFSET
# offset : a, U64 -> OffsetStage a | [InvalidStage]
offset = |previous, offsetValue|
    # Type system would enforce this can only be called on valid stages
    { previous, offset: offsetValue }

# Stage 9: LIMIT
# limit : a, U64 -> LimitStage a | [InvalidStage]
limit = |previous, limitValue|
    # Type system would enforce this can only be called on valid stages
    { previous, limit: limitValue }

# Expression constructors

# Property selector constructor (this would be generated or macro-based)
prop : (a -> b) -> Prop a
prop = |selector| selector # Simplified - in real Roc this would be more sophisticated

# Column reference from property
col : Prop a -> Expr
col = |property| Column property

# Literals
num : I64 -> Expr
num = |n| Literal (Number n)

decimal : F64 -> Expr
decimal = |d| Literal (Decimal d)

str : Str -> Expr
str = |s| Literal (String s)

bool : Bool -> Expr
bool = |b| Literal (Bool b)

null : Expr
null = Literal Null

# Functions as expressions
year : Expr -> Expr
year = |expr| Year expr

month : Expr -> Expr
month = |expr| Month expr

day : Expr -> Expr
day = |expr| Day expr

upper : Expr -> Expr
upper = |expr| Upper expr

lower : Expr -> Expr
lower = |expr| Lower expr

substring : Expr, Expr, Expr -> Expr
substring = |expr, start, length| Substring expr start length

# Aggregates
count : Expr -> Expr
count = |expr| Count expr

countAll : Expr
countAll = CountAll

sum : Expr -> Expr
sum = |expr| Sum expr

avg : Expr -> Expr
avg = |expr| Avg expr

minAgg : Expr -> Expr
minAgg = |expr| Min expr

maxAgg : Expr -> Expr
maxAgg = |expr| Max expr

# Arithmetic
add : Expr, Expr -> Expr
add = |left, right| Add left right

subtract : Expr, Expr -> Expr
subtract = |left, right| Subtract left right

multiply : Expr, Expr -> Expr
multiply = |left, right| Multiply left right

divide : Expr, Expr -> Expr
divide = |left, right| Divide left right

# Boolean expressions (conditions)
eq : Expr, Expr -> Expr
eq = |left, right| Eq left right

gt : Expr, Expr -> Expr
gt = |left, right| Gt left right

lt : Expr, Expr -> Expr
lt = |left, right| Lt left right

gte : Expr, Expr -> Expr
gte = |left, right| Gte left right

lte : Expr, Expr -> Expr
lte = |left, right| Lte left right

like : Expr, Expr -> Expr
like = |expr, pattern| Like expr pattern

inList : Expr, List Expr -> Expr
inList = |expr, values| In expr values

and_ : List Expr -> Expr
and_ = |conditions| And conditions

or_ : List Expr -> Expr
or_ = |conditions| Or conditions

not : Expr -> Expr
not = |expr| Not expr

# CASE expression
case : List (Expr, Expr), Expr -> Expr
case = |whenClauses, elseClause| Case whenClauses elseClause

# SelectItem constructors
selectExpr : Expr -> SelectItem
selectExpr = |expr| Expression expr

alias_ : Expr, Str -> SelectItem
alias_ = |expr, aliasName| Alias expr aliasName

# OrderBy constructors
asc : Expr -> OrderBy
asc = |expr| { expr, direction: Asc }

desc : Expr -> OrderBy
desc = |expr| { expr, direction: Desc }

# Table constructors
table_ : Str -> Table
table_ = |name| Named name

tableAs : Str, Str -> Table
tableAs = |name, a| Aliased name a

subqueryTable : Query, Str -> Table
subqueryTable = |query, alias| Subquery query alias

# Example with typed record properties
Book : { id : Str, title : Str, genre : Str, author_id : Str }
Sale : { id : Str, book_id : Str, quantity : U64, sale_date : Str }
Author : { id : Str, name : Str }

# Property selectors (in real usage, these might be generated)
bookId : Prop Book
bookId = .id

bookGenre : Prop Book
bookGenre = .genre

saleBookId : Prop Sale
saleBookId = .book_id

saleQuantity : Prop Sale
saleQuantity = .quantity

saleSaleDate : Prop Sale
saleSaleDate = .sale_date

# Example query using the staged approach
exampleQueryStaged : Query
exampleQueryStaged =
    from "books"
    |> fromAs "books" "b" # This would need adjustment for the type system
    |> join Inner (tableAs "sales" "s") (eq (col bookId) (col saleBookId))
    |> where (eq (year (col saleSaleDate)) (num 2024))
    |> groupBy [col bookGenre]
    |> having (gt (count (col saleQuantity)) (num 50))
    |> select [
        selectExpr (col bookGenre),
        alias_ (count (col saleQuantity)) "total_sold",
    ]
    |> orderBy [desc (col bookGenre)] # Would reference the aliased column
    |> offset 0
    |> limit 5
    |> SelectQuery # Convert to final Query type

# THE MAIN FUNCTION - Converts any Query stage to SQL
# toCode : Query -> Str
# toCode = |query|
#    when query is
#        FromQuery stage -> fromStageToSql stage
#        JoinQuery stage -> joinStageToSql stage
#        WhereQuery stage -> whereStageToSql stage
#        GroupByQuery stage -> groupByStageToSql stage
#        HavingQuery stage -> havingStageToSql stage
#        SelectQuery stage -> selectStageToSql stage
#        OrderByQuery stage -> orderByStageToSql stage
#        OffsetQuery stage -> offsetStageToSql stage
#        LimitQuery stage -> limitStageToSql stage

# SQL generation functions for each stage
fromStageToSql : FromStage -> Str
fromStageToSql = |stage|
    "FROM ${tableToSql stage.table}"

joinStageToSql : JoinStage -> Str
joinStageToSql = |stage|
    fromSql = fromStageToSql stage.from
    joinsSql = stage.joins |> List.map joinToSql |> Str.join_with "\n"
    "${fromSql}\n${joinsSql}"

# ... (other stage conversion functions would follow similar pattern)

# Helper functions
tableToSql : Table -> Str
tableToSql = |table|
    when table is
        Named name -> name
        Aliased name alias -> "${name} ${alias}"
        Subquery query alias -> "(${toCode query}) ${alias}"

joinToSql : Join -> Str
joinToSql = |j|
    joinTypeStr =
        when j.joinType is
            Inner -> "INNER JOIN"
            Left -> "LEFT JOIN"
            Right -> "RIGHT JOIN"
            Full -> "FULL OUTER JOIN"
            Cross -> "CROSS JOIN"

    tableStr = tableToSql join.table

    when join.on is
        Some condition -> "${joinTypeStr} ${tableStr} ON ${exprToSql condition}"
        None -> "${joinTypeStr} ${tableStr}"

exprToSql : Expr -> Str
exprToSql = |expr|
    when expr is
        Column p -> propToSql p # Would need implementation
        Literal lit -> literalToSql lit
        Year e -> "YEAR(${exprToSql e})"
        Month e -> "MONTH(${exprToSql e})"
        Count e -> "COUNT(${exprToSql e})"
        CountAll -> "COUNT(*)"
        Sum e -> "SUM(${exprToSql e})"
        Eq left right -> "${exprToSql left} = ${exprToSql right}"
        Gt left right -> "${exprToSql left} > ${exprToSql right}"
        And conditions ->
            condStrs = List.map conditions exprToSql
            "(${Str.join_with condStrs " AND "})"
# ... other expression types

literalToSql : Literal -> Str
literalToSql = |lit|
    when lit is
        Number n -> Num.to_str n
        Decimal d -> Num.to_str d
        String s -> "'${s}'"
        Bool True -> "TRUE"
        Bool False -> "FALSE"
        Null -> "NULL"

propToSql : Prop a -> Str
propToSql = |p|
    # This would need special handling - perhaps through reflection or codegen
    # For now, simplified
    "column_name"

# Alternative: Simpler Query type without rigid ordering but with validation
SimpleQuery : {
    select : List SelectItem,
    from : Table,
    joins : List Join,
    where : [Some Expr, None],
    groupBy : List Expr,
    having : [Some Expr, None],
    orderBy : List OrderBy,
    offset : [Some U64, None],
    limit : [Some U64, None],
}

# Validation function to check SQL logical correctness
validateQuery : SimpleQuery -> Result SimpleQuery [InvalidQuery Str]
validateQuery = |query|
    # Check if HAVING is used without GROUP BY
    if query.having != None and List.is_empty query.groupBy then
        Err (InvalidQuery "HAVING clause requires GROUP BY")
        # Check if aggregate functions in SELECT match GROUP BY usage
        # ... other validations
    else
        Ok query
