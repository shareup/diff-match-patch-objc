import XCTest
@testable import DiffMatchPatchObjC

final class DiffMatchPatchObjCTests: XCTestCase {
    func testDiffMatchPatch() throws {
        repeat {
            autoreleasepool {
                let old = """
            Buy:
            
            * Milk
            * Fresh bread
            * Eggs (6)
            """.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let new = """
            To buy:
            
            * Milk
            * Fresh bread (x2)
            * Eggs (6)
            """.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let base = """
            Buy:
            
            * Milk
            * Fresh bread
            * Eggs (10)
            """.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let expected = """
            To buy:
            
            * Milk
            * Fresh bread (x2)
            * Eggs (10)
            """.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let merged = threeWayMerge(old: old, new: new, base: base)
                XCTAssertEqual(merged, expected)
            }
        } while true
    }
}

private func threeWayMerge(
    old: String,
    new: String,
    base: String
) -> String {
    let dmp = DiffMatchPatch()
    let patch = dmp.patch_make(
        fromOldString: old,
        andNewString: new
    ) as! [Any]
    return dmp.patch_apply(
        patch,
        to: base
    ).first as! String
}
