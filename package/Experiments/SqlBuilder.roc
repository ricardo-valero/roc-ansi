module [
    From,
]

From a : [Identifier a]

On : []

Join : [
    Cross (From, From),
    Inner (From, From, On),
    Left (From, From, On),
    Right (From, From, On),
]

from : From a -> a
from = \f ->
    when f is
        Identifier a -> a

join : Join a b -> Str
join = \j ->
    when j is
        Cross (a, b) -> "CROSS"
        Inner (a, b) -> "JOIN "
        Left (a, b) -> "LEFT"
        Right (a, b) -> "RIGHT"

## SELECT * FROM employee JOIN department ON department.id = employee.department_id;

# Here is the logical sequence which is followed by a SQL database when processing a SELECT query:
# FROM
# JOIN
# WHERE
# GROUP BY
# Aggregate Functions (COUNT, SUM, AVG, etc)
# HAVING
# SELECT
# ORDER BY
# OFFSET
# LIMIT
