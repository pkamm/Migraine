//
//  DiaryEntry.swift
//  Migraine
//
//  Created by Kamm, Peter on 10/25/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import Foundation

enum DiaryError: Error{
    case runtimeError(String)
}

class DiaryEntry{
    
    var questionInfos: [QuestionInfo] = []
    var date: Date

    init(){
        date = Date()
    }
    
    init(_ object:(key: String, value: AnyObject?)){
        questionInfos = []
        if let theDate = DiaryService.sharedInstance.dateFormatter.date(from:object.key) {
            date = theDate
        } else {
            if let dato = DiaryService.sharedInstance.oldDateFormatter.date(from:object.key) {
                date = dato
            } else {
                date = Date()
            }
        }
        if let keyValPair = object.value as? NSDictionary {
            for key in keyValPair.allKeys {
                let questionInfo = QuestionInfo(value: keyValPair[key],
                                                infoKey: InfoKey(rawValue: key as! String)!)
                questionInfos.append(questionInfo)
            }
        }
    }

    func wasMigraine() throws -> Bool {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .HADMIGRAINE,
                let stringValue = questionInfo.value as? String {
                return (stringValue.lowercased() == "yes")
            }
            if questionInfo.infoKey == .HADMIGRAINE,
                let stringValue = questionInfo.value as? Bool {
                return stringValue
            }
        }
        throw DiaryError.runtimeError("Missing info as to whether there was a migraine")
    }
    
    func migraineEndDateString() -> String? {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .MIGRAINEEND, let stringValue = questionInfo.value as? String {
                return stringValue
            }
        }
        return nil
    }
    
    func migraineStartDateString() -> String? {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .MIGRAINESTART, let stringValue = questionInfo.value as? String {
                return stringValue
            }
        }
        return nil
    }

    func migraineStartDate() -> Date? {
        if let dateString = migraineStartDateString(){
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.date(from: dateString)
        }
        return nil
    }
    
    func migraineEndDate() -> Date? {
        if let dateString = migraineEndDateString(){
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.date(from: dateString)
        }
        return nil
    }
    
    func hasSleepData() -> Bool {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .SLEEPQUALITY,
                let stringValue = questionInfo.value {
                return true
            }
        }
        return false
    }
    
    func sleepDuration() -> TimeInterval {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .SLEEPDURATIONMINUTES,
                let durationString = questionInfo.value as? String {
                return timeIntervalFromString(string: durationString)
            }
        }
        return 0
    }
    
    func timeIntervalFromString(string: String) -> TimeInterval {
        let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var numbers: [Int] = []
        for item in stringArray {
            if let number = Int(item) {
                numbers.append(number)
            }
        }
        return TimeInterval(numbers[0]*3600 + numbers[1]*60)
    }
    
    func migraineSeverityText() -> String {
        do{
            if try wasMigraine() {
                do{
                    switch try migraineSeverity(){
                    case 0:
                        return "Mild Migraine"
                    case 1:
                        return "Moderate Migraine"
                    case 2:
                        return "Severe Migraine"
                    default:
                        return "Migraine"
                    }
                }catch{
                    return "Migraine"
                }
            } else {
                return "No Migraine"
            }
        } catch {
            return "Migraine Info Unknown"
        }
    }
    
    func migraineSeverity() throws -> Int {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .MIGRAINESEVERITY, let severityValue = questionInfo.value as? Int {
                return severityValue
            }
        }
        throw DiaryError.runtimeError("Missing info as to whether there was a migraine")
    }
    
    func stressLevel() throws -> Int {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .STRESSLEVEL, let severityValue = questionInfo.value as? Int {
                return severityValue
            }
        }
        throw DiaryError.runtimeError("Missing info as to whether there was a migraine")
    }
    
    func sleepQuality() throws -> Int {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .SLEEPQUALITY, let qualityLevel = questionInfo.value as? Int {
                return qualityLevel
            }
        }
        throw DiaryError.runtimeError("Missing info as to whether there was a migraine")
    }
    
    
    
}
