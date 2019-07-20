import Foundation
import simd
import Accelerate

public extension CGAffineTransform {
    
    /**
     * Find an an affine similarity matrix from a given set of points using "Least-squares estimation of transformation parameters between two point patterns" by S. Umeyama
     * - Parameter from: original points
     * - Parameter to: equivalent points
     * - Returns: the main parts of the desired transformation matrix.
     */
    private static func findSimilarity(from: [SIMD2<Double>], to: [SIMD2<Double>]) -> (m: simd_double2x2, t: SIMD2<Double>) {
        assert(from.count >= 2, "must contain at least 2 points")
        assert(from.count == to.count, "from and to point collections differ in sizes")
        
        var meanFrom = SIMD2<Double>()
        var meanTo = SIMD2<Double>()
        
        var sigmaFrom: Double = 0
        var sigmaTo: Double = 0
        
        var cov = simd_double2x2(0)
        
        // compute means
        for i in 0..<from.count {
            meanFrom += from[i]
            meanTo += to[i]
        }
        meanFrom /= Double(from.count)
        meanTo /= Double(from.count)
        
        // compute covariance (Σxy) and from/to variances (σx, σy)
        for i in 0..<from.count {
            sigmaFrom += simd_length_squared(from[i] - meanFrom)
            sigmaTo += simd_length_squared(to[i] - meanTo)
            let covTo = simd_double2x2(to[i] - meanTo, SIMD2<Double>(repeating: 0))
            let covFrom = simd_double2x2(rows: [from[i] - meanFrom, SIMD2<Double>(repeating: 0)])
            cov += covTo * covFrom
        }
        sigmaFrom /= Double(from.count)
        sigmaTo /= Double(from.count)
        cov *= (1 / Double(from.count)) // simd lacking scalar division
        
        // single value decomposition
        let (u, d, v) = svd(cov)
        var s = matrix_identity_double2x2
        if cov.determinant < 0 || cov.determinant == 0 && (u.determinant * v.determinant < 0) {
            if d[1,1] < d[0,0] {
                s[1,1] = -1
            } else {
                s[0,0] = -1
            }
        }
        
        let r = u * s * v.transpose
        var c: Double = 1
        if (sigmaFrom != 0) {
            c = 1.0 / sigmaFrom * (d * s).trace
        }
        let t = meanTo - c * r * meanFrom
        
        let m = c * r
        return (m, t)
    }
    
    static func findSimilarity(from: [CGPoint], to: [CGPoint]) -> CGAffineTransform {
        let simdFrom = from.map { from in SIMD2<Double>(x: Double(from.x), y: Double(from.y)) }
        let simdTo = to.map { to in SIMD2<Double>(x: Double(to.x), y: Double(to.y)) }
        let (m, t) = findSimilarity(from: simdFrom, to: simdTo)
        
//        let p = SIMD2<Double>(0, 3)
//        let newP = m * p + t
//        print(newP)
        
        return CGAffineTransform(
            a: CGFloat(m[0,0]),
            b: CGFloat(m[0,1]),
            c: CGFloat(m[1,0]),
            d: CGFloat(m[1,1]),
            tx: CGFloat(t[0]),
            ty: CGFloat(t[1])
        )
    }
}
