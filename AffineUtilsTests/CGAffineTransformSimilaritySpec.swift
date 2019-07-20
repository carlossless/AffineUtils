import XCTest
import simd
import Quick
import Nimble
@testable import AffineUtils

extension CGPoint {
    var rounded: CGPoint {
        return CGPoint(x: x.rounded(), y: y.rounded())
    }
}

class CGAffineTransformSimilaritySpec: QuickSpec {
    override func spec() {
        describe("findSimilarity(from:, to:)") {
            let minPoints = [
                CGPoint(x: 0, y: 1),
                CGPoint(x: 0, y: 3)
            ]
            
            describe("scaling") {
                it("finds the correct scaling transformation") {
                    let maxPoints = [
                        CGPoint(x: 0, y: 1),
                        CGPoint(x: 0, y: 9)
                    ]
                    
                    let trans = CGAffineTransform.findSimilarity(from: minPoints, to: maxPoints)
                    let points = minPoints.map { $0.applying(trans).rounded }
                    
                    expect(points).to(equal(maxPoints))
                }
            }
            
            describe("rotation") {
                it("finds the correct positive 90° transformation") {
                    let maxPoints = [
                        CGPoint(x: 1, y: 0),
                        CGPoint(x: 3, y: 0)
                    ]
                    
                    let trans = CGAffineTransform.findSimilarity(from: minPoints, to: maxPoints)
                    let points = minPoints.map { $0.applying(trans).rounded }
                    
                    expect(points).to(equal(maxPoints))
                }
                
                it("finds the correct negative 90° transformation") {
                    let maxPoints = [
                        CGPoint(x: -1, y: 0),
                        CGPoint(x: -3, y: 0)
                    ]
                    
                    let trans = CGAffineTransform.findSimilarity(from: minPoints, to: maxPoints)
                    let points = minPoints.map { $0.applying(trans).rounded }
                    
                    expect(points).to(equal(maxPoints))
                }
            }
            
            describe("translation") {
                it("finds the correct translation transformation") {
                    let maxPoints = [
                        CGPoint(x: 1, y: 3),
                        CGPoint(x: 1, y: 5)
                    ]
                    
                    let trans = CGAffineTransform.findSimilarity(from: minPoints, to: maxPoints)
                    let points = minPoints.map { $0.applying(trans).rounded }
                    
                    expect(points).to(equal(maxPoints))
                }
            }
        }
    }
}

class CGAffineTransformSimilarityTests: XCTestCase {
    func testPerformanceExample() {
        let minPoints = [
            CGPoint(x: 0, y: 1),
            CGPoint(x: 0, y: 3)
        ]
        
        let maxPoints = [
            CGPoint(x: -1, y: 0),
            CGPoint(x: -3, y: 0)
        ]
        
        // This is an example of a performance test case.
        self.measure {
            let _ = CGAffineTransform.findSimilarity(from: minPoints, to: maxPoints)
        }
    }
}
