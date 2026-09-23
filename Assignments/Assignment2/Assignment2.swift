//
//  Assignment2.swift
//  Assignments
//
//  Created by Shokan Tatayev on 11.09.2026.
//

func runAssignment2() {
    // MARK: - Easy Tasks

    // 1.
    let fruits = ["Apple", "Banana", "Cherry", "Mango", "Orange"]
    print(fruits[2])

    // 2.
    var favoriteNumbers: Set<Int> = [1, 7, 21]
    favoriteNumbers.insert(13)
    print(favoriteNumbers)

    // 3.
    let releaseYears = ["Swift": 2014, "Python": 1991, "Java": 1995]
    print(releaseYears["Swift"]!)

    // 4.
    var colors = ["Red", "Green", "Blue", "Yellow"]
    colors[1] = "Purple"
    print(colors)

    // MARK: Medium Tasks

    // 1.
    let firstSet: Set<Int> = [1, 2, 3, 4]
    let secondSet: Set<Int> = [3, 4, 5, 6]
    print(firstSet.intersection(secondSet))

    // 2.
    var studentScores = ["Aidar": 85, "Dana": 90, "Miras": 78]
    studentScores.updateValue(95, forKey: "Dana")
    print(studentScores)

    // 3.
    let firstFruits = ["apple", "banana"]
    let secondFruits = ["cherry", "date"]
    let mergedFruits = firstFruits + secondFruits
    print(mergedFruits)

    // MARK: Hard Tasks

    // 1
    var populations = ["Kazakhstan": 20_000_000, "USA": 335_000_000, "Japan": 125_000_000]
    populations["Germany"] = 84_000_000
    print(populations)

    // 2
    let firstAnimals: Set<String> = ["cat", "dog"]
    let secondAnimals: Set<String> = ["dog", "mouse"]
    let unionResult = firstAnimals.union(secondAnimals)
    let finalSet = unionResult.subtracting(secondAnimals)
    print(finalSet)

    // 3
    let studentGrades = [
        "Shokan": [95, 88, 92],
        "Aigerim": [80, 85, 90]
    ]
    print(studentGrades["Shokan"]![1])
}


