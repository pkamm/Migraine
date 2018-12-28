//
//  String+Additions.swift
//  Migraine
//
//  Created by Peter Kamm on 11/16/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import Foundation

public extension String{
    static func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        let ti = NSInteger(interval)
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        return NSString(format: "%.2d hours %.2d minutes", hours, minutes)
    }
    
    static func timeIntervalFromString(string: String) -> TimeInterval {
        let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var numbers: [Int] = []
        for item in stringArray {
            if let number = Int(item) {
                numbers.append(number)
            }
        }
        return TimeInterval(numbers[0]*3600 + numbers[1]*60)
    }
}
