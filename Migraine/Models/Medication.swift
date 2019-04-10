//
//  Medication.swift
//  Migraine
//
//  Created by Peter Kamm on 4/10/19.
//  Copyright © 2019 MIT. All rights reserved.
//


enum MedicationFrequency: Int, CaseIterable {
    case FourHours
    case SixHours
    case EightHours
    case TwelveHours
    case OnceADay
    case EveryOtherDay
    case EveryThirdDay
    case OnceAWeek
    case OnceAMonth
    case EveryOtherMonth
    case EveryThreeMonths
    case EveryFourMonths
    case EverySixMonths
    case OnceAYear
    case Other
    static var asArray: [MedicationFrequency] {return self.allCases}
}

extension MedicationFrequency: CustomStringConvertible {
    var description: String {
        switch self {
        case .FourHours:
            return "Every 4 hours (6 times a day)"
        case .SixHours:
            return "Every 6 hours (4 times a day)"
        case .EightHours:
            return "Every 8 hours (3 times a day)"
        case .TwelveHours:
            return "Every 12 hours (twice a day)"
        case .OnceADay:
            return "Once a day"
        case .EveryOtherDay:
            return "Once every other day"
        case .EveryThirdDay:
            return "Once every 3rd day"
        case .OnceAWeek:
            return "Once a week"
        case .OnceAMonth:
            return "Once a month"
        case .EveryOtherMonth:
            return "Once every other month"
        case .EveryThreeMonths:
            return "Once every 3 months"
        case .EveryFourMonths:
            return "Once every 4 months"
        case .EverySixMonths:
            return "Once every 6 months"
        case .OnceAYear:
            return "Once a year"
        case .Other:
            return "Other"
        }
    }
}

class Medication{

    var name:String
    var frequency:MedicationFrequency
    var dosage:String

    init(_ name:String, frequency:MedicationFrequency, dosage:String){
        self.name = name
        self.frequency = frequency
        self.dosage = dosage
    }
    
    init(fromDictionary: [String:Any]){
        self.name = fromDictionary["MEDICATION"] as! String
        self.frequency = MedicationFrequency(rawValue: fromDictionary["FREQUENCY"] as! Int)!
        self.dosage = fromDictionary["DOSAGE"] as! String
    }

    func asDictionary() -> [String: Any] {
        return ["MEDICATION": self.name,
                "FREQUENCY": self.frequency.rawValue,
                "DOSAGE": self.dosage]
    }
    
}
