import Foundation
import simd

extension double2x2 {
    var columnCount: Int {
        return 2
    }
    
    var rowCount: Int {
        return 2
    }
    
    var grid: [Double] {
        return [self[0,0], self[1,0], self[0,1], self[1,1]]
    }
    
    init(s: [Double]) {
        assert(s.count == 4)
        self.init(rows: [SIMD2<Double>(s[0], s[1]), SIMD2<Double>(s[2], s[3])])
    }
    
    var diag: SIMD2<Double> {
        return SIMD2(self[0,0], self[1,1])
    }
    
    var trace: Double {
        return diag[0] + diag[1] //TODO: replace with sum
    }
}
