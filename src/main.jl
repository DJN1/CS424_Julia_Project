#=
    AUTHOR: David Niederewis
    DATE: 03/11/2022
    FILE: main.jl
    SYSTEM: Arch Linux
    ENVIRONMENT: Linux Command Line, Julia version 1.7.2
    DESCRIPTION: The purpose of this program is to open a given file of students and generate a grade report with average overall grade, average test and homework grade for each student, and average overall grade for each student with given weights for tests and quizzes. The grade report is printed twice, first sorted by lastname and the second time by overal average grade.
=#
using Statistics
#=
    Returns:
        filename -     String: name of file to open
        weight -       Float64: weight to apply to tests
        numTests -     Int64: number of tests to expect
        numHomeworks - Int64: number of homeworks to expect
=#
function promptInput()
    print("Welcome!\nThis program will open a file with student data and calculate statistics about the student list.\nLet's get started.\n\nPlease enter the file name to open: ")
    filename = readline()
    print("Please enter the weight to apply to the test grades: ")
    weight = parse(Float64, readline())
    println("Tests will be weighted $weight% and Homeworks will be weighted $(100 - weight)%")
    print("Please enter the number of tests: ")
    numTests = parse(Int, readline())
    print("Please enter the number of homeworks: ")
    numHomeworks = parse(Int, readline())
    return filename, weight, numTests, numHomeworks
end

#=
    @param lines -  String[]: list of lines from file
    @param weight - Int: weight to apply to tests
    Returns:
        mat - String[][][]: matrix where each row represents 1 student
=#
function parseLines(lines, weight)
    mat = []
    for i in 1:3:length(lines)
        name = [lines[i][2] * ", " * lines[i][1]]
        tests = map((grade) -> parse(Int, grade), lines[i + 1])
        homeworks = map((grade) -> parse(Int, grade), lines[i + 2])
        testAvg = mean(tests)
        homeworkAvg = mean(homeworks)
        overallAvg = round((testAvg * (weight / 100)) + (homeworkAvg * ((100 - weight) / 100)), sigdigits=3)
        push!(mat, [name, tests, homeworks, [testAvg, homeworkAvg, overallAvg]])
    end
    return mat
end

#=
    students -      String[][][]: matrix of students, 1 student per row
    maxNameLength - Int: length of longest name
    numTest -       Int: number of tests to expect
    numHomeworks -  Int: number of homeworks to expect
=#
function generateStudentReport(mat, maxNameLength, numTest, numHomework)
    println(rpad("STUDENT NAMES",  maxNameLength, " ") * "\tTESTS\t\tHOMEWORKS\tAVERAGE")
    println(repeat("-", 98))
    for line in mat
        print(rpad(line[1][1], maxNameLength, " ") * "\t")
        print(rpad("$(line[4][1])%", 6, " ") * " (" * "$(length(line[2]))" * ")\t")
        print(rpad("$(line[4][2])%", 6, " ") * " (" * "$(length(line[3]))" * ")\t")
        print(rpad("$(line[4][3])%", 5, " "))
        if length(line[2]) < numTest
            print("\t*** MISSING TEST")
            if length(line[3]) < numHomework
                print(" AND HOMEWORK ***\n")
            else
                print("***\n")
            end
        elseif length(line[3]) < numHomework
            print("\t*** MISSING HOMEWORK ***\n")
        else
            print("\n")
        end
    end
end

function main()
    filename, weight, numTests, numHomeworks = promptInput()
    # read data from file, separate by whitespace and parse values
    lines = readlines(filename)
    lines = map((line) -> split(line, " "), lines)
    mat = parseLines(lines, weight) #mat = [[[name], [testScores], [homeworkScores], [averages]],...]
    # print report summary with average grades and total class average
    println(repeat("*", 45) * " REPORT " * repeat("*", 45))
    println("FOUND $(length(mat)) STUDENTS IN FILE")
    println("Weight distribution is as followed:")
    println("Tests:\t\t\t$weight%")
    println("Homeworks:\t\t$(100 - weight)%")
    println("\nOVERALL CLASS AVERAGE:\t$(mean(map((line) -> line[4][3], mat)))%")
    # sort by name and print student scores table
    mat = sort(mat, lt=(x, y) -> isless(x[1][1], y[1][1]))
    println("\n\n" * repeat("#", 42) * " SORT BY NAME " * repeat("#", 42))
    maxNameLength = maximum(map((line) -> length(line[1][1]), mat))
    generateStudentReport(mat, maxNameLength, numTests, numHomeworks)
    # sort by score and print student scores table
    mat = sort(mat, lt=(x, y) -> !isless(x[4][3], y[4][3]))
    println("\n\n" * repeat("#", 42) * " SORT BY GRADE " * repeat("#", 41))
    maxNameLength = maximum(map((line) -> length(line[1][1]), mat))
    generateStudentReport(mat, maxNameLength, numTests, numHomeworks)
end

main()
