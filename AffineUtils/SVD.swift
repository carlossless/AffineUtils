import Foundation
import simd
import Accelerate

enum SVDMode {
    case fast
    case compact
}

/**
 Singlular value decomposition using LAPACK and SIMD functions.
 */
func svd(_ a: simd_double2x2, mode: SVDMode = .fast) -> (u: simd_double2x2, s: simd_double2x2, v: simd_double2x2) {
    let job = UnsafeMutablePointer<Int8>(mutating: ("A" as NSString).utf8String!)
    let jobvt = UnsafeMutablePointer<Int8>(mutating: ("S" as NSString).utf8String!)
    
    var _m = __CLPK_integer(a.columnCount)
    var _n = __CLPK_integer(a.rowCount)
    
    var lda = _m
    var ldu = _m
    var ldvt = _n
    
    var s = [Double](repeating: 0, count: Int(_n))
    var u = [Double](repeating: 0, count: Int(ldu * _m))
    var vt = [Double](repeating: 0, count: Int(ldvt * _n))
    
    var wkopt : __CLPK_doublereal = 0
    var lwork : __CLPK_integer = -1
    var info : __CLPK_integer = 0

    var grid = a.grid
    
    switch (mode) {
    case .fast:
        var iwork : [__CLPK_integer] = [__CLPK_integer](repeating: 0, count: Int(8 * min(_n, _m)))
        dgesdd_(job, &_m, &_n, &grid, &lda, &s, &u, &ldu, &vt, &ldvt, &wkopt, &lwork, &iwork, &info)
        
        // get the optimal lwork workspace
        lwork = __CLPK_integer(wkopt)
        var work = [Double](repeating: 0.0, count: Int(lwork))
        
        dgesdd_(job, &_m, &_n, &grid, &lda, &s, &u, &ldu, &vt, &ldvt, &work, &lwork, &iwork, &info)
    case .compact:
        dgesvd_(job, jobvt, &_m, &_n, &grid, &lda, &s, &u, &ldu, &vt, &ldvt, &wkopt, &lwork, &info)
        
        // get the optimal lwork workspace
        lwork = __CLPK_integer(wkopt)
        var work = [Double](repeating: 0.0, count: Int(lwork))
        
        dgesvd_(job, jobvt, &_m, &_n, &grid, &lda, &s, &u, &ldu, &vt, &ldvt, &work, &lwork, &info)
    }
    
    /* Check for convergence */
    assert(!(info > 0), "SVD failed to converge.")
    assert(!(info < 0), "wrong parameters provided.")
    
    // swaped U and V places
    return (
        u: simd_double2x2(s: vt),
        s: simd_double2x2(diagonal: SIMD2<Double>(s)),
        v: simd_double2x2(s: u).transpose
    )
}
