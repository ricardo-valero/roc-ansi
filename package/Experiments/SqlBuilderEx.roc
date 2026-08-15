module []

# Define the GradeLevel enum
GradeLevel : [FirstYear, SecondYear, ThirdYear, FourthYear]

# Define the Student record
Student : {
    firstName : Str,
    lastName : Str,
    id : I64,
    year : GradeLevel,
    scores : List I64,
    departmentId : I64,
}

# Define the Teacher record
Teacher : {
    first : Str,
    last : Str,
    id : I64,
    city : Str,
}

# Define the Department record
Department : {
    name : Str,
    id : I64,
    teacherId : I64,
}

# Mock data for students
students : List Student
students = [
    {
        firstName: "Alice",
        lastName: "Smith",
        id: 1,
        year: FirstYear,
        scores: [85, 92, 78],
        departmentId: 101,
    },
    {
        firstName: "Bob",
        lastName: "Johnson",
        id: 2,
        year: SecondYear,
        scores: [88, 76, 91],
        departmentId: 102,
    },
    {
        firstName: "Carol",
        lastName: "Williams",
        id: 3,
        year: ThirdYear,
        scores: [90, 85, 87],
        departmentId: 101,
    },
    {
        firstName: "David",
        lastName: "Brown",
        id: 4,
        year: FourthYear,
        scores: [72, 84, 79],
        departmentId: 103,
    },
]

# Mock data for teachers
teachers : List Teacher
teachers = [
    {
        first: "John",
        last: "Doe",
        id: 201,
        city: "New York",
    },
    {
        first: "Jane",
        last: "Doe",
        id: 202,
        city: "Los Angeles",
    },
    {
        first: "Jim",
        last: "Beam",
        id: 203,
        city: "Chicago",
    },
]

# Mock data for departments
departments : List Department
departments = [
    {
        name: "Computer Science",
        id: 101,
        teacherId: 201,
    },
    {
        name: "Mathematics",
        id: 102,
        teacherId: 202,
    },
    {
        name: "Physics",
        id: 103,
        teacherId: 203,
    },
]

# var query = students.Join(departments,
# student => student.DepartmentID, department => department.ID,
# (student, department) => new { Name = $"{student.FirstName} {student.LastName}", DepartmentName = department.Name });

# query =
#    from student in students
#    join department in departments
#    on student.DepartmentID equals department.ID
#    select { studentName : $"{student.firstName} {student.lastName}", departmentName: department.name }

# from = \a -> List.first a |> Util.unwrap {}
from = \a -> a
join = \a, b -> (a, from b)

Filter : [Eq, Ne]

on : Filter, (a, b) -> Str
on = \f, x -> "ON" |> Str.concat
    when f is
        Eq -> "${x.0} = ${x.1}"
        Ne -> "${x.0} <> ${x.1}"

student = {
    firstName: "Alice",
    lastName: "Smith",
    id: 1,
    year: FirstYear,
    scores: [85, 92, 78],
    departmentId: 101,
}

department = {
    name: "Computer Science",
    id: 101,
    teacherId: 201,
}

# query =
#    from students
#    |> join departments
#    |> on student.DepartmentID Equals department.ID
#    |> select { studentName : $"{student.firstName} {student.lastName}", departmentName: department.name }

query =
    from student
    |> join department
    |> \(a, b) -> a.departmentId == b.id
    #|> \(a,b) -> {...a,...b}


expect query == Bool.true
