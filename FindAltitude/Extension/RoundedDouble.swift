//
//  RoundedDouble.swift
//  FindAltitude
//
//  Created by Massimiliano on 31/10/2019.
//  Copyright © 2019 Massimiliano Bonafede. All rights reserved.
//

import Foundation

extension Double{
    func rounded(toDecimalPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

