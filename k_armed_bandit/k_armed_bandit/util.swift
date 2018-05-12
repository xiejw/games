import Foundation

func normalDistribution(mean: Double = 0.0, sigma: Double = 1.0) -> Double {
    let u1 = Double(arc4random()) / Double(UINT32_MAX)
    let u2 = Double(arc4random()) / Double(UINT32_MAX)
    let f1 = sqrt(-2 * log(u1));
    let f2 = 2 * Double.pi * u2;
    let g1 = f1 * cos(f2); // gaussian distribution
    // double g2 = f1 * sin(f2); // gaussian distribution
    return g1 * sigma + mean
}

func random(_ total: Int) -> Int {
    return Int(arc4random_uniform(UInt32(total)))
}
