// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================



// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let number = Int(parts.1),
          number >= 0 || parts.0 == "TEMP"
    else { return nil }

    return (sensor: parts.0, value: number)
}

print(parseReading("O2:87") as Any)     // (sensor: "O2", value: 87)
print(parseReading("TEMP:-12") as Any)  // (sensor: "TEMP", value: -12)
print(parseReading("RAD:-1") as Any)    // nil
print(parseReading(":55") as Any)       // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0

    for line in lines {
        guard let reading = parseReading(line) else {
            invalidCount += 1
            continue
        }
        valid.append(reading)
    }

    return (valid, invalidCount)
}

print(parseLog(["O2:50", "bad", "TEMP:-5"]))  // 2 valid, 1 invalid
print(parseLog(rawLog).invalidCount)         // 6

let A = parseLog(rawLog).invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var selected: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            selected.append(reading)
        }
    }
    return selected
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let validReadings = parseLog(rawLog).valid
let o2Readings = select(validReadings) { $0.sensor == "O2" }
let tempReadings = select(validReadings) { $0.sensor == "TEMP" }

print(values(of: o2Readings))    // [87, 64, 71, 90]
print(values(of: tempReadings))  // [-12, 31, 4]

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }

    var minValue = first
    var maxValue = first
    var sum = 0

    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }

    return (minValue, maxValue, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)  // (min: 1, max: 8, average: 4.0)
print(stats() as Any)         // nil

let B = Int(stats(of: values(of: o2Readings))?.average ?? 0)

// 2.3 · The Closure Ladder
// 1. Full closure syntax with types and return
let sorted1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
// 2. Types inferred from context
let sorted2 = validReadings.sorted(by: { a, b in
    return a.value > b.value
})
// 3. Implicit return
let sorted3 = validReadings.sorted(by: { a, b in a.value > b.value })
// 4. Shorthand argument names
let sorted4 = validReadings.sorted(by: { $0.value > $1.value })
// 5. Trailing closure
let sorted5 = validReadings.sorted { $0.value > $1.value }

func sameOrder(_ lhs: [Reading], _ rhs: [Reading]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for i in 0..<lhs.count {
        if lhs[i] != rhs[i] { return false }
    }
    return true
}

let allSortsMatch = sameOrder(sorted1, sorted2)
    && sameOrder(sorted1, sorted3)
    && sameOrder(sorted1, sorted4)
    && sameOrder(sorted1, sorted5)
print("All five sorts match: \(allSortsMatch)")  // true
print(values(of: sorted1))                       // [101, 98, 90, 87, 71, 64, 31, 4, 3, -12]


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    switch temp {
    case ..<18: return heatUp
    case 25...: return coolDown
    default:    return hold
    }
}

print(chooseProtocol(for: 10)(10))  // 15 (heatUp)
print(chooseProtocol(for: 30)(30))  // 27 (coolDown)
print(chooseProtocol(for: 20)(20))  // 20 (hold)

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    let safeRange = 18...24
    var temp = start
    var steps = 0

    while !safeRange.contains(temp) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }

    return (temp, steps, safeRange.contains(temp))
}

print(runUntilStable(from: 31))                 // (finalTemp: 22, steps: 3, isStable: true)
print(runUntilStable(from: -100, maxSteps: 5))  // (finalTemp: -75, steps: 5, isStable: false)

let lowestTemp = stats(of: values(of: tempReadings))?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

for member in crew {
    print(member.name, oxygenLevel(of: member) as Any)
}

// 4.2
func status(of member: CrewMember) -> String {
    let place = member.module?.name ?? "open space"

    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(place))"
    }

    let state = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    let capacity = 100
    guard amount > 0 else { return 0 }

    let transferred = min(amount, source, capacity - target)
    source -= transferred
    target += transferred
    return transferred
}

var testSource = 90
var testTarget = 95
print(transferOxygen(from: &testSource, to: &testTarget, amount: 30))  // 5 (target is almost full)
print(transferOxygen(from: &testSource, to: &testTarget, amount: -10)) // 0 (negative amount)

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
}

let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }

    let sortedMembers = found.sorted { $0.priority < $1.priority }

    var result: [String] = []
    for member in sortedMembers {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))  // ["Aigerim", "Timur", "Dana"]
print(evacuationOrder("Nurlan", "Timur", roster: roster))                    // ["Nurlan", "Timur"]


// MARK: Level 5 · The Saboteur's Logbook

/*
func reportOxygen(for member: CrewMember) -> String {
    // Problem 1: member.module! crashes for Nurlan (module == nil, open space).
    // Problem 2: oxygenTank! crashes for Dana (Dock has no tank).
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

// Problem 3: return type String cannot express "nobody is critical".
func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        // Problem 4: oxygenLevel(of:)! crashes on the first member without data
        //            (with the starter crew it crashes on Dana).
        // Problem 5 (logic): there is no break/return, so the loop keeps going
        //            and the LAST critical member overwrites the first one.
        //            With the starter data only Aigerim is critical, so it's invisible.
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    // Problem 6: result! crashes when nobody is critical (or the crew is empty).
    return result!
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

for member in crew {
    print(reportOxygen(for: member))
}

// Test: two critical members — the FIRST one must be returned (the old code returned the last).
let testCrew = [
    CrewMember(name: "First",  role: "Test", priority: 1, module: Module(name: "T1", oxygenTank: Tank(level: 5))),
    CrewMember(name: "NoData", role: "Test", priority: 2, module: nil),
    CrewMember(name: "Second", role: "Test", priority: 3, module: Module(name: "T2", oxygenTank: Tank(level: 10)))
]
print("firstCritical returns first:", firstCritical(in: testCrew) == "First")  // true
print("firstCritical on empty crew:", firstCritical(in: []) == nil)           // true


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        guard level < threshold else { return false }
        count += 1
        print("Alarm #\(count)")
        return true
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))  // Alarm #1 → true
print(alarm(40))  // false
print(alarm(5))   // Alarm #2 → true


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    With guard let the unwrapped value stays available AFTER the guard, until the end
    of the scope, and the else branch MUST exit (return / continue / throw).
    So guard is an "early exit": bad cases are handled at the top, the main logic
    stays unindented. With if let the value exists only inside the braces, so every
    extra check adds another level of nesting:

        // if let — "pyramid"
        if let parts = splitOnce(raw, by: ":") {
            if !parts.0.isEmpty {
                if let number = Int(parts.1) {
                    ... return (parts.0, number)
                }
            }
        }
        return nil

        // guard let — flat
        guard let parts = splitOnce(raw, by: ":"), !parts.0.isEmpty,
              let number = Int(parts.1) else { return nil }
        return (parts.0, number)

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    Int... only describes how the function is CALLED: separate Ints, comma-separated.
    Inside the function Swift packs them into [Int], but the parameter type at the
    call site is still "a list of Ints", not an array, and Swift has no operator to
    "spread" an array into variadic arguments. That's why stats(of: [Int]) exists and
    the variadic version just forwards to it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Swift's exclusivity rule: a variable can't have two overlapping inout (write)
    accesses at the same time ("overlapping accesses to 'x'"). It prevents aliasing
    bugs: source and target would be the same tank, so "source -= n; target += n"
    would read and write the same memory and the result/return value would be wrong.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    ?? needs the default value to have the same type as the value inside the optional.
    oxygenLevel returns Int?, so the default must be Int, but "no data" is a String.
    Fix: oxygenLevel(of: dana) ?? 0, or convert to String first with if let / guard let.

 5. Full type of chooseProtocol and how to read it:
    (Int) -> (Int) -> Int
    The arrow groups from the right: (Int) -> ((Int) -> Int).
    "A function that takes an Int (the current temperature) and returns another function
    that takes an Int and returns an Int" — i.e. it returns heatUp / coolDown / hold.
    The label "for" is not part of the type.

 Bonus. Where does the alarm counter live after makeAlarm returns?
    count is captured by the returned closure. Because the closure outlives the call,
    Swift moves count from the stack into a heap-allocated box, and the closure keeps
    a reference to that box. The counter lives as long as the closure (alarm) lives.
    Every call to makeAlarm creates a new, independent counter.
*/
