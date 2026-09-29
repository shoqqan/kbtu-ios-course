// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

for deck in Deck.allCases {
    print("\(deck.rawValue): evacuation priority \(deck.evacuationPriority)")
}
print(Deck(rawValue: "greenhouse") as Any)  // nil — not a real deck

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = max(0, mass / 500)
        return AlarmLevel(rawValue: min(step, AlarmLevel.red.rawValue)) ?? .red
    }
}

print(AlarmLevel.level(forTotalMass: 0))     // green
print(AlarmLevel.level(forTotalMass: 940))   // yellow
print(AlarmLevel.level(forTotalMass: 4000))  // red
print(AlarmLevel.orange.rawValue)            // 2 — assigned implicitly


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    switch parts[0] {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    case "container":
        if parts.count == 3, !parts[1].isEmpty, let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    case "livestock":
        if parts.count == 4, !parts[1].isEmpty, let count = Int(parts[2]), let massPerUnitKg = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
        }
    default:
        break
    }

    return .unknown(raw: line)
}

print(parseEntry("crate:101:120"))            // crate(id: 101, massKg: 120)
print(parseEntry("livestock:lab mice:12:2"))  // livestock(species: "lab mice", count: 12, massPerUnitKg: 2)
print(parseEntry("crate:104:abc"))            // unknown(raw: "crate:104:abc")

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    if case .unknown = entry {
        unknownCount += 1
    }
    totalMass += mass(of: entry)
}

print("Manifest: total mass \(totalMass) kg, \(unknownCount) unknown lines")

let A = totalMass


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        guard amount > 0 else { return }
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

extension CrewSnapshot: CustomStringConvertible {
    var description: String { "\(name) [\(deck.rawValue), O2 \(oxygen)%]" }
}

var rookie = CrewSnapshot.rookie(named: "Rookie")
print(rookie)                // Rookie [bridge, O2 100%]
rookie.breathe(130)
rookie.move(to: .cargo)
print(rookie)                // Rookie [cargo, O2 0%] — never below 0
rookie.reviveInMedbay()
print(rookie)                // Rookie [medbay, O2 100%]

// 3.2
func makeRoster(from records: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var roster: [CrewSnapshot] = []
    for record in records {
        guard let deck = Deck(rawValue: record.deck) else {
            print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
            continue
        }
        roster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return roster
}

let crewRoster: [CrewSnapshot] = makeRoster(from: crewData)
print(crewRoster)
print(makeRoster(from: [(name: "Ghost", deck: "greenhouse", oxygen: 50)]))  // warning, then []

func member(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for snapshot in roster where snapshot.name == name {
        return snapshot
    }
    return nil
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)

// 1. Copy
let original = CrewSnapshot.rookie(named: "Original")
var copy = original
print("[copy]   before: original \(original.oxygen), copy \(copy.oxygen)")
copy.breathe(30)
print("[copy]   after:  original \(original.oxygen), copy \(copy.oxygen)")  // 100 / 70

// 2. Plain parameter — the function receives its own copy
func drainCopy(_ snapshot: CrewSnapshot) {
    var local = snapshot  // parameters are constants, so we change a local copy
    local.breathe(50)
    print("[plain]  inside function: \(local.oxygen)")
}

let plainTest = CrewSnapshot.rookie(named: "Plain")
print("[plain]  before: \(plainTest.oxygen)")
drainCopy(plainTest)
print("[plain]  after:  \(plainTest.oxygen)")  // still 100

// 3. inout — the change is written back to the caller's variable
func drainInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(50)
    print("[inout]  inside function: \(snapshot.oxygen)")
}

var inoutTest = CrewSnapshot.rookie(named: "Inout")
print("[inout]  before: \(inoutTest.oxygen)")
drainInPlace(&inoutTest)
print("[inout]  after:  \(inoutTest.oxygen)")  // 50


// MARK: Level 4 · The Teleport Pod

// 4.1
// The struct got a memberwise initializer for free; a class never gets one,
// so all its stored properties without defaults (id, chargeLevel) must be set by an init we write.
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    // Bonus 1
    deinit {
        print("Pod \(id) deinitialized")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let crew = occupant, chargeLevel >= 20 else { return nil }
        chargeLevel -= 20
        occupant = nil
        return crew
    }
}

let testPod = TeleportPod(id: "T-1", chargeLevel: 30)
print(testPod.load(CrewSnapshot.rookie(named: "First")))   // true
print(testPod.load(CrewSnapshot.rookie(named: "Second")))  // false — pod is occupied
print(testPod.fire() as Any)                               // First [bridge, O2 100%]
print(testPod.load(CrewSnapshot.rookie(named: "Third")))   // false — charge 10 < 20

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
print("Ledger start: charge \(ledgerPod.chargeLevel)")

for (index, name) in ["Timur", "Dana", "Nurlan"].enumerated() {
    guard let crew = member(named: name, in: crewRoster) else {
        print("Step \(index + 1): \(name) not found in roster")
        continue
    }
    let loaded = ledgerPod.load(crew)
    let arrived = ledgerPod.fire()
    print("Step \(index + 1): load \(name) -> \(loaded), fire -> \(arrived?.name ?? "nil"), charge \(ledgerPod.chargeLevel)")
}

let emptyFire = ledgerPod.fire()
print("Step 4: fire empty pod -> \(emptyFire?.name ?? "nil"), charge \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel

// 4.3 · Reference-semantics demonstration
let podOne = TeleportPod(id: "R-1", chargeLevel: 100)
let podTwo = podOne
podTwo.chargeLevel = 35
print("[class]  podOne \(podOne.chargeLevel), podTwo \(podTwo.chargeLevel)")  // 35 / 35

let snapOne = CrewSnapshot.rookie(named: "Value")
var snapTwo = snapOne
snapTwo.oxygen = 35
print("[struct] snapOne \(snapOne.oxygen), snapTwo \(snapTwo.oxygen)")     // 100 / 35

// Rule: assigning a class copies the reference (both names see one object),
// assigning a struct copies the value (each name has its own independent data).


// MARK: Level 5 · Station Systems

// 5.1
// A class, not a struct: the station is one shared live object — every system that holds it
// must see the same hull and oxygen state, not its own private copy.
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet {
            print("Hull integrity: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "\(self.callSign) | hull \(self.hullIntegrity)%"
        for deck in Deck.allCases {
            if let oxygen = self.oxygenByDeck[deck] {
                report += " | \(deck.rawValue) \(oxygen)%"
            }
        }
        return report
    }()

    var totalOxygen: Int {
        var total = 0
        for (_, oxygen) in oxygenByDeck {
            total += oxygen
        }
        return total
    }

    var averageOxygen: Int {
        get {
            oxygenByDeck.isEmpty ? 0 : totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        var byDeck: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Station: unknown deck '\(reading.deck)', reading skipped")
                continue
            }
            byDeck[deck] = reading.oxygen
        }
        self.oxygenByDeck = byDeck
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 100, readings: deckReadings)

let B = station.averageOxygen

print("Total oxygen: \(station.totalOxygen)")      // 285
print("Average oxygen: \(station.averageOxygen)")  // 57

// Lazy: no "Running full scan..." line appears until the first access
print("Diagnostics not touched yet")
print(station.fullDiagnostics)  // "Running full scan..." printed here, once
print(station.fullDiagnostics)  // no scan line — the stored value is reused

let idleStation = Station(callSign: "IDLE-1", hullIntegrity: 80, readings: [])
print("\(idleStation.callSign) never touches fullDiagnostics — no scan line for it")

// Setter: every deck gets the new value
let backupStation = Station(callSign: "BACKUP", hullIntegrity: 100, readings: deckReadings)
backupStation.averageOxygen = 70
print("Backup after set: average \(backupStation.averageOxygen), total \(backupStation.totalOxygen)")  // 70 / 350

// 5.2 · The clamp trap: 130, then -40, then 55
station.hullIntegrity = 130
print("Hull: \(station.hullIntegrity)")  // 100
station.hullIntegrity = -40
print("Hull: \(station.hullIntegrity)")  // 0
station.hullIntegrity = 55
print("Hull: \(station.hullIntegrity)")  // 55

// Why no infinite loop: assigning a property inside its OWN didSet writes the storage
// directly — Swift does not call willSet/didSet again for that assignment.
// (That's also why willSet printed only one transition per line above, not two.)

// Lazy changes behaviour, not just performance: the report was built when it was first
// read, so it still shows hull 100% even though the hull is now 55%.
print(station.fullDiagnostics)


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1 — compiles, wrong.
//   Expected: every crew member loses 10 oxygen.
//   Actual:   roster is unchanged (Timur still 62).
//   Rule:     the loop variable is a COPY of each struct element; `for var` only makes
//             that copy mutable, the array itself is never written to.
//   Fix:      write through the array by index.
var fixedRoster = crewRoster
for index in fixedRoster.indices {
    fixedRoster[index].breathe(10)
}
print("Report 1 fixed: \(crewRoster[0].oxygen) -> \(fixedRoster[0].oxygen)")  // 62 -> 52

// Report 2 — compiles, wrong.
//   Expected: podA keeps 100.
//   Actual:   prints 0.
//   Rule:     classes are reference types; `let podB = podA` copies the reference,
//             so both names point to the same pod.
//   Fix:      create a separate pod when you need an independent one.
let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "B", chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("Report 2 fixed: podA \(fixedPodA.chargeLevel), podB \(fixedPodB.chargeLevel)")  // 100 / 0

// Report 3 — does NOT compile.
//   Expected: add(_:) appends an entry.
//   Actual:   error: cannot use mutating member on immutable value: 'self' is immutable
//   Rule:     inside a struct's method `self` is a constant unless the method is `mutating`.
//   Fix:      mark the method mutating.
struct Logbook {
    var entries: [String] = []

    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()
logbook.add("Day 10: teleporter reported success")
logbook.add("Day 10: crew count mismatch")
print("Report 3 fixed: \(logbook.entries.count) entries")  // 2
print(logbook.entries)

// Report 4 — the struct line does NOT compile, the class line compiles.
//   snapshot.oxygen = 40 → error: cannot assign to property: 'snapshot' is a 'let' constant
//     `let` on a struct freezes the whole VALUE, including every property inside it.
//   pod.chargeLevel = 10 → compiles.
//     `let` on a class freezes only the REFERENCE (pod can't point to another pod);
//     the object it points to can still change its var properties.
//   Fix: declare the snapshot with var.
//
// Note: the PDF says only one report fails to compile, but Report 3 and the first
// half of Report 4 both fail — checked with swiftc.
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
let fixedPod = TeleportPod(id: "B", chargeLevel: 50)
fixedPod.chargeLevel = 10
print("Report 4 fixed: \(fixedSnapshot), pod charge \(fixedPod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }

// A class, not a struct: there is one physical recorder, and everyone who logs to it
// must write into that same recorder, not into a copy.
final class FlightRecorder {
    // private: blocks reading, replacing, clearing or appending to the list from outside the type.
    private var entries: [String] = []

    // private(set): blocks setting isSealed from outside (it can't be switched back to false); reading is still allowed.
    internal private(set) var isSealed = false

    // internal: blocks access only from other modules; anyone in this module can read the count.
    internal var entryCount: Int {
        entries.count
    }

    // internal: blocks access only from other modules; anyone in this module can read the transcript.
    internal var transcript: String {
        var result = ""
        for (index, entry) in entries.enumerated() {
            result += "\(index + 1). \(entry)\n"
        }
        return result + (isSealed ? "[SEALED]" : "[open]")
    }

    // internal: blocks access only from other modules; the only way in, and it refuses once sealed.
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        guard !isSealed else { return false }
        entries.append(entry)
        return true
    }

    // internal: blocks access only from other modules; sealing is one-way, there is no unseal.
    internal func seal() {
        isSealed = true
    }

    // fileprivate: blocks every file except this one; auditTranscript below needs the raw lines.
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

// A free function elsewhere in the file that uses your fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    var characters = 0
    var emptyEntries = 0
    for entry in recorder.rawEntries() {
        characters += entry.count
        if entry.isEmpty {
            emptyEntries += 1
        }
    }
    return "Audit: \(recorder.entryCount) entries, \(characters) characters, \(emptyEntries) empty, sealed: \(recorder.isSealed)"
}

let recorder = FlightRecorder()
recorder.add("09:00 teleporter online")
recorder.add("09:14 crew transfer started")
recorder.seal()
print(recorder.add("09:15 nothing happened"))  // false — sealed
print(recorder.entryCount)                      // 2
print(recorder.transcript)
print(auditTranscript(of: recorder))

// Trying to break the recorder from outside the type (each line fails to compile):
//
// recorder.entries = []
//   error: 'entries' is inaccessible due to 'private' protection level
//
// recorder.entries.append("fake entry")
//   error: 'entries' is inaccessible due to 'private' protection level
//
// recorder.isSealed = false
//   error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// 1. deinit is inside TeleportPod (Level 4).

// 2. Lifetime experiment
var outsideReference: TeleportPod?
print("Before do block")
do {
    let tempPod = TeleportPod(id: "TMP", chargeLevel: 10)
    outsideReference = tempPod
    print("Inside do block: tempPod and outsideReference point to the same pod")
}
print("After do block: pod still alive (\(outsideReference?.id ?? "none"))")
outsideReference = nil  // ← deinit fires on this line
print("After outsideReference = nil")

// Why: ARC counts strong references. Inside the block there are two (tempPod and
// outsideReference). Leaving the block removes tempPod → count 1, the pod lives on.
// Setting outsideReference to nil removes the last one → count 0 → deinit runs right there.

// 3. Same pod or just equal pods?
func compare(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "the same pod (one object, two references)"
    }
    if first.id == second.id
        && first.chargeLevel == second.chargeLevel
        && first.occupant?.name == second.occupant?.name {
        return "two different pods with equal contents"
    }
    return "two different pods"
}

let record1 = TeleportPod(id: "P-7", chargeLevel: 60)
let record2 = record1
let record3 = TeleportPod(id: "P-7", chargeLevel: 60)
print(compare(record1, record2))  // the same pod
print(compare(record1, record3))  // two different pods with equal contents

// === cannot be used on CrewSnapshot: it compares object identity (is this the same
// instance in memory?) and only works on class instances. A struct has no identity —
// every assignment makes an independent copy, so "the same snapshot" doesn't exist,
// only "equal snapshots".
// let check = rookie === copy
//   error: argument type 'CrewSnapshot' expected to be an instance of a class or class-constrained type


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Structs get an automatic memberwise init: CrewSnapshot(name:deck:oxygen:).
    Classes never get one. A class can be subclassed, and its init rules (designated /
    convenience, calling super.init) are more complex, so Swift makes you write it.
    The only free init a class gets is init() when EVERY stored property has a default
    value — TeleportPod's id and chargeLevel have none, so we must write init ourselves.

 2. What does `mutating` do to self, and why do classes never need it?
    It makes self an inout parameter of the method: the method may change properties
    or even replace self entirely (reviveInMedbay does `self = CrewSnapshot(...)`),
    and the new value is written back to the caller's variable. That's why a mutating
    method can't be called on a `let` struct.
    In a class, self is a reference. Methods change the object it points to, never the
    reference itself, so there is nothing to mark.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    Struct: the variable holds the value itself, so `let` freezes the whole value —
    no property can change, no mutating method can be called.
    Class: the variable holds a reference, so `let` freezes only the reference —
    `pod` can't be made to point to a different pod, but the pod's var properties
    (chargeLevel) can still change.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    Its value is set AFTER init, on first access. A `let` must have its value by the
    end of init and never change, so lazy can't be let.
    Behaviour change: the initial value is computed at first-access time with the state
    at that moment. fullDiagnostics was read while the hull was 100, so it still says
    100% after the hull dropped to 55. A side effect ("Running full scan...") also only
    happens if and when the property is read — idleStation never prints it.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    auditTranscript(of:) is a free function outside the class but in the same file,
    and needs the raw entries. If rawEntries() were private, only code inside
    FlightRecorder (and its extensions in this file) could call it, and
    auditTranscript wouldn't compile. fileprivate opens it to this file only, while
    other files still can't reach the raw list.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
    deinit fires on `outsideReference = nil` — that removes the last strong reference
    (tempPod's reference already disappeared at the end of the do block).
    === checks whether two references point to the same object. Structs aren't
    referenced, they're copied, so they have no identity to compare.
*/
