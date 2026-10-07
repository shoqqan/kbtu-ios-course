// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> A drone and everyone who inspects it must see one
// physical battery whose charge drains in place, so the cell needs identity and shared state, not copies.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = charge.clamped(to: 0...100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        charge = charge.charged(by: amount)
    }
}

let testCell = PowerCell(charge: 150)
print("Cell clamped to: \(testCell.level())")                // 100
print("Spend 30: \(testCell.spend(30)), left \(testCell.level())")   // true, 70
print("Spend 0: \(testCell.spend(0)), left \(testCell.level())")     // false, 70
print("Spend 500: \(testCell.spend(500)), left \(testCell.level())") // false, 70
testCell.recharge(by: -10)
print("Recharge -10: \(testCell.level())")                   // 70
testCell.recharge(by: 90)
print("Recharge 90: \(testCell.level())")                    // 100
print("Negative start: \(PowerCell(charge: -20).level())")   // 0

// Encapsulation proof (leave this commented, with the compiler error):
// testCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> No subclass can replace the shift ritual,
// so every drone, present or future, always pays its powerCost before doing any work.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    var canRunTask: Bool {
        cell.level() >= powerCost
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a hull seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

let demoWelder = WelderDrone(id: "W-demo", cell: PowerCell(charge: 30))
print(demoWelder.weldSeam())
print("Welder runOnce: \(demoWelder.runOnce()), \(demoWelder.statusLine)")  // 40, 5%
print("Welder runOnce: \(demoWelder.runOnce()), \(demoWelder.statusLine)")  // 0 — not enough charge
print(ScannerDrone(id: "S-demo", cell: PowerCell(charge: 42)).statusLine)   // S-demo: 42% ####...... [scanner]
print(CargoDrone(id: "C-demo", cell: PowerCell(charge: 100)).statusLine)

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var builtFleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("Warning: unknown drone kind '\(record.kind)' for \(record.id), skipped")
        continue
    }
    builtFleet.append(drone)
}
let fleet: [Drone] = builtFleet
print("Fleet built: \(fleet.count) drones")


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    guard rounds > 0 else { return 0 }
    var totalWork = 0
    for _ in 1...rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let shiftWork = runShift(fleet, rounds: 3)

var remainingCharge = 0
var readyDrones = 0
for drone in fleet {
    print(drone.statusLine)
    remainingCharge += drone.cell.level()
    if drone.canRunTask {
        readyDrones += 1
    }
}
print("Shift work: \(shiftWork), remaining charge: \(remainingCharge), ready for one more task: \(readyDrones)")

let A = shiftWork
let B = remainingCharge
let C = readyDrones


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> A class instance is reached
// through a reference: the method changes the object the reference points to, never the reference
// itself, so there's nothing for `mutating` to allow.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }

    var statusCode: Int {
        healthCode(forCharge: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }

    var statusCode: Int {
        healthCode(forCharge: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        chargeLevel = chargeLevel.charged(by: amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}
print(sensors[0].diagnose())  // hull-cam: code 2
print(sensors[1].diagnose())  // thermal: code 0

// Rechargeable works for both — on copies, so the mission data stays untouched
var sensorCopy = sensors[0]
sensorCopy.recharge(by: 50)
print("Sensor copy recharged: \(sensorCopy.chargeLevel), original still \(sensors[0].chargeLevel)")  // 62 / 12

var rechargeables: [Rechargeable] = [CargoDrone(id: "C-spare", cell: PowerCell(charge: 10)), SensorModule(id: "spare", chargeLevel: 10)]
for index in rechargeables.indices {
    rechargeables[index].recharge(by: 30)
}
for item in rechargeables {
    if let component = item as? Diagnosable {
        print("After recharge: \(component.diagnose())")  // both code 1
    }
}

// 4.3
// Why could [Drone] never have held the sensors?  -> A [Drone] only holds Drone objects and
// their subclasses, and SensorModule is a struct, which can't inherit from any class.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS: \(components.count) components ===\n"
    var broken = 0
    for component in components {
        report += component.diagnose() + "\n"
        if component.statusCode > 0 {
            broken += 1
        }
    }
    report += "Needs attention: \(broken)"
    return report
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    // The Health Rule — the only place in this file where the thresholds exist.
    func healthCode(forCharge charge: Int) -> Int {
        if charge < 20 { return 2 }  // critical
        if charge < 50 { return 1 }  // warning
        return 0                     // nominal
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }

    var statusCode: Int {
        healthCode(forCharge: signalStrength)
    }

    func diagnose() -> String {
        "!! LEGACY HARDWARE !! \(name) — signal \(signalStrength), code \(statusCode), schedule replacement"
    }
}

print(beacon.diagnose())
print(beacon.statusCode)  // 2

components.append(beacon)
print(diagnosticsReport(components))

var statusSum = 0
for component in components {
    statusSum += component.statusCode
}
let D = statusSum

// 5.3
extension Int {
    var powerBar: String {
        let filled = (self / 10).clamped(to: 0...10)
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }

    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    // The recharge rule, shared by PowerCell and SensorModule: ignore non-positive amounts, cap at 100.
    func charged(by amount: Int) -> Int {
        guard amount > 0 else { return self }
        return Swift.min(self + amount, 100)
    }
}

print(42.powerBar)    // ####......
print((-5).powerBar)  // ..........
print(250.powerBar)   // ##########


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// Report 1 — does NOT compile.
//   Expected: a drone that produces 30 work units.
//   Actual:   error: overriding declaration requires an 'override' keyword
//   Rule:     replacing a superclass method must be marked `override`, so an accidental
//             name clash can't silently change behaviour.
//   Fix:
class PatchDrone: Drone {
    override func performTask() -> Int {
        30
    }
}

let patch = PatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("Report 1 fixed: work \(patch.runOnce()), \(patch.statusLine)")  // 30, 40%

// Report 2 — does NOT compile (two errors).
//   Expected: a heavier welder whose shift produces 999.
//   Actual:   error: inheritance from a final class 'WelderDrone'
//             error: instance method overrides a 'final' instance method
//   Rule:     a final class can't be subclassed, a final method can't be overridden.
//             That's exactly what protects the ritual: no drone gets work without paying.
//   Fix:      subclass Drone and change only the cost and the work.
final class HeavyWelder: Drone {
    override var powerCost: Int { 40 }

    override func performTask() -> Int { 80 }
}

let heavy = HeavyWelder(id: "H-1", cell: PowerCell(charge: 50))
print("Report 2 fixed: \(heavy.runOnce()), then \(heavy.runOnce())")  // 80, then 0 — the ritual still applies

// Report 3 — does NOT compile.
//   Expected: print the welder's weldSeam().
//   Actual:   error: value of type 'Drone' has no member 'weldSeam'
//   Rule:     the compiler only knows the STATIC type of `first` — Drone — and Drone has
//             no weldSeam(), even though the object at runtime is a WelderDrone.
//   Fix:      ask at runtime with a conditional cast.
//   as? returns an optional because the cast can fail: the element might be a scanner or cargo drone.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100)), CargoDrone(id: "C-9", cell: PowerCell(charge: 100))]
for drone in reportFleet {
    if let welder = drone as? WelderDrone {
        print("Report 3 fixed: \(welder.weldSeam())")
    } else {
        print("Report 3 fixed: \(drone.id) is not a welder")
    }
}

// Report 4 — compiles and lies.
//   Expected: "thruster T-1".
//   Actual:   "generic component".
//   Rule:     label() is NOT a protocol requirement, it only exists in the extension.
//             Calls through the protocol type ([Labelled]) are resolved at compile time
//             (static dispatch) to the extension's version; the struct's own label()
//             only "shadows" it and is used when the static type is Thruster.
//             A requirement gets a dynamic dispatch table, so the real type's method wins.
//   Fix:      one line — declare label() as a requirement.
protocol BrokenLabelled {
    var componentID: String { get }
}

extension BrokenLabelled {
    func label() -> String { "generic component" }
}

struct BrokenThruster: BrokenLabelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let brokenParts: [BrokenLabelled] = [BrokenThruster(componentID: "T-1")]
print("Report 4 as written: \(brokenParts[0].label())")  // generic component

protocol Labelled {
    var componentID: String { get }
    func label() -> String  // ← the one line that changes the output
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 fixed: \(parts[0].label())")  // thruster T-1

// Note: the PDF says two reports don't compile and two compile and lie, but
// Reports 1, 2 and 3 all fail to compile and only Report 4 runs — checked with swiftc.


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1a. Runtime: the base class refuses to be created as itself.
//     Compiles fine, crashes only when someone actually does it.
class RuntimeAbstractDrone {
    let id: String

    init(id: String) {
        if type(of: self) == RuntimeAbstractDrone.self {
            fatalError("RuntimeAbstractDrone is abstract — create a subclass")
        }
        self.id = id
    }
}

final class RuntimeWelder: RuntimeAbstractDrone {}

print("Runtime check, subclass is fine: \(RuntimeWelder(id: "RW-1").id)")
// let bare = RuntimeAbstractDrone(id: "X")
//   Fatal error: RuntimeAbstractDrone is abstract — create a subclass  (crash at runtime)

// 1b. Compile time: make the base type a protocol — a protocol has no initializer at all.
//     (see DroneUnit below)
// let bareUnit = DroneUnit(id: "X", cell: PowerCell(charge: 50))
//   error: 'any DroneUnit' cannot be constructed because it has no accessible initializers

// 2. Protocol-based fleet: the base type is a protocol + extension, WelderUnit is a struct.
protocol DroneUnit {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension DroneUnit {
    // Not a requirement, so through `any DroneUnit` this version is always the one called —
    // the protocol's equivalent of a final method (see Report 4).
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }
}

struct WelderUnit: DroneUnit {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }

    func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a hull seam"
    }
}

struct ScannerUnit: DroneUnit {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 10 }

    func performTask() -> Int { 15 }
}

let units: [any DroneUnit] = [
    WelderUnit(id: "WU-1", cell: PowerCell(charge: 80)),
    ScannerUnit(id: "SU-1", cell: PowerCell(charge: 45))
]
var unitWork = 0
for _ in 1...3 {
    for unit in units {
        unitWork += unit.runOnce()
    }
}
print("Protocol fleet work: \(unitWork)")  // 165, same rules as the class fleet for W-1 + S-1
for unit in units {
    print(unit.statusLine)
}

// 3. Comparison.
//    The class design gives one place for stored state (id, cell) and a truly final ritual,
//    while the protocol design needs every struct to repeat its stored properties but lets
//    any type — struct, enum, or a type we don't own — become a drone.
//    For this station I'd keep the class hierarchy: drones are physical machines with identity
//    whose battery state is shared and changes in place.
//    If drones had to share mutable state, the struct design would stop being a real value type:
//    WelderUnit already holds a PowerCell reference, so copies of it share one battery anyway.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    `mutating` means "this method may change self". For a struct, self IS the value,
    so changing a property changes self — the method needs permission, and the caller
    must hold the struct in a var. For a class, self is a reference; the method changes
    the object behind it, while the reference itself never changes. So a plain class
    method already fits the requirement, and Swift doesn't allow `mutating` in classes.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance: shares STORED state and implementation — Drone stores id and cell once,
    and every subclass gets them plus the final runOnce() without writing anything.
    A protocol can't hold stored properties; every conformer stores its own.
    Protocols: work across kinds of types — Drone (class), SensorModule (struct) and
    LegacyBeacon (a type we can't edit, via extension) all sit in one [Diagnosable].
    A struct can't inherit from a class, and you can't add a superclass to an existing type.

 3. What does `final` prevent, and what did it protect in runOnce()?
    On a method: no subclass may override it. On a class: no one may subclass it.
    runOnce() being final guarantees the order "pay powerCost first, then work" for
    every drone forever. Without it a subclass could override runOnce() and return
    work without spending charge — exactly what HeavyWelder in Report 2 tried (999 for free).

 4. In Report 4, why did the protocol extension's method win?
    label() was not declared in the protocol, only in its extension. For non-requirement
    methods Swift picks the implementation by the STATIC type at compile time. The array
    is [Labelled], so the compiler called Labelled's extension version. Requirements are
    dispatched dynamically through the protocol witness table — adding `func label() -> String`
    to the protocol makes the real type's (Thruster's) method win.
*/
