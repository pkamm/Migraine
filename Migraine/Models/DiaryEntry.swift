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
    
    init(_ object:(key: String, value: AnyObject?)){
        questionInfos = []
        // date = DiaryService.sharedInstance.dateFormatter.date(from:object.key)!
        if let theDate = DiaryService.sharedInstance.dateFormatter.date(from:object.key) {
            date = theDate
        } else {
            date = Date()
        }
        if let keyValPair = object.value as? NSDictionary {
            for key in keyValPair.allKeys {
                let questionInfo = QuestionInfo(value: keyValPair[key],
                                                infoKey: InfoKey(rawValue: key as! String)!)
                questionInfos.append(questionInfo)
                
                
                //                if let theEntries = entry as? [String:String] {
                //                    for (key, value) in theEntries {
                //                        let questionInfo = QuestionInfo(text: value,
                //                                                        infoKey: InfoKey(rawValue: key)!)
                //                        questionInfos.append(questionInfo)
                //                    }
                //                }
            }
        }
    }
    
    func wasMigraine() throws -> Bool {
        for questionInfo in questionInfos {
            if questionInfo.infoKey == .HADMIGRAINE, let stringValue = questionInfo.value as? String {
                return (stringValue.lowercased() == "yes")
            }
        }
        throw DiaryError.runtimeError("Missing info as to whether there was a migraine")
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
    
    
    
}
