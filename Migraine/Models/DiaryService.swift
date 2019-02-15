//
//  DiaryService.swift
//  Migraine
//
//  Created by Peter Kamm on 8/8/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DiaryService {
    
    var dateFormatter: DateFormatter
    var dateFormatterShort: DateFormatter

    static let sharedInstance = DiaryService()
    
    var dbRef: DatabaseReference!
    
    var pendingDiaryEntry: [String:Any] = [:]
    
    init() {
        self.dbRef = Database.database().reference()
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatterShort = DateFormatter()
        dateFormatterShort.dateStyle = .short
    }
    
    func addQuestionInfosToPendingDiaryEntry(questionInfos: [QuestionInfo]){
        for questionInfo:QuestionInfo in questionInfos {
            if let value = questionInfo.value {
                pendingDiaryEntry[questionInfo.infoKey.rawValue] = value
            }
        }
    }
    
    func submitPendingDiaryEntry(completion: @escaping () -> Void) {
        let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
        let userId = Auth.auth().currentUser?.uid
        let curDate = dateFormatter.string(from: Date())

        usersRef.child(userId!).child(curDate).setValue(pendingDiaryEntry)
        completion()
    }
    
    func submit(questionInfos: [QuestionInfo], date: Date, completion: @escaping () -> Void){
        var diary: [String:Any] = [:]
        for questionInfo:QuestionInfo in questionInfos {
            if let value = questionInfo.value {
                diary[questionInfo.infoKey.rawValue] = value
            }
        }
        let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
        let userId = Auth.auth().currentUser?.uid
        let dateString = dateFormatter.string(from: date)
        usersRef.child(userId!).child(dateString).setValue(diary)
        completion()
    }
    
    func getDiaryEntries(completion: @escaping ([String:AnyObject?]?) -> Void ) {
        let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
        if let userId = Auth.auth().currentUser?.uid{

            usersRef.child(userId).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot.value)

                if let thing = snapshot.value as? [String:AnyObject] {
//                    var latestHealthObject:[String : AnyObject]? = nil
//                    var latestDate = Date.distantPast
//                    for (dateIndex, healthObject) in thing {
//                        let date = self.dateFormatter.date(from: dateIndex)
//                        if date! > latestDate, let healthDict = healthObject as? [String:AnyObject]{
//                            self.patientInfo = healthDict as [String : AnyObject]
//                            latestHealthObject = healthDict
//                            latestDate = date!
//                        }
//                    }
                    completion(thing)
                    print(thing)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func addCurrentListToPendingDiaryEntry(infoKey:InfoKey, list:[String]) {
        //TODO: replace if there already
        pendingDiaryEntry[infoKey.rawValue] = list
    }

    func questionInfoFor(infoKey: InfoKey) -> QuestionInfo {
        var questionInfo:QuestionInfo
        switch infoKey {
        case .AGE:
            questionInfo = QuestionInfo(text: "How old are you?", infoKey: InfoKey.AGE)
            break
        case .BIRTHCONTROL:
             questionInfo = QuestionInfo(text: "Methods of birth control", infoKey: InfoKey.BIRTHCONTROL)
            break
//        case .EVENINGNOTIFICATION:
//             questionInfo =
//            break
        case .GENDER:
             questionInfo = QuestionInfo(text: "Gender", infoKey: InfoKey.GENDER)
            break
        case .GENDERBORNAS:
             questionInfo = QuestionInfo(text: "What gender were you born as?", infoKey: InfoKey.GENDERBORNAS)
            break
        case .HADMIGRAINE:
             questionInfo = QuestionInfo(text: "Did you have a migraine?", infoKey: InfoKey.HADMIGRAINE)
            break
        case .HEADACHELOCATIONS:
            questionInfo = QuestionInfo(text: "Locations of migraine?", infoKey: InfoKey.HEADACHELOCATIONS)
            break
        case .HELPMIGRAINETODAY:
            questionInfo = QuestionInfo(text: "What helped?", infoKey: InfoKey.HELPMIGRAINETODAY)
            break
        case .HORMONETHERAPY:
             questionInfo = QuestionInfo(text: "Any hormore therapy?", infoKey: InfoKey.HORMONETHERAPY)
            break
        case .LMP:
             questionInfo = QuestionInfo(text: "Date of LMP", infoKey: InfoKey.LMP)
            break
//        case .LURKINGMIGRAINE:
//            questionInfo =
//            break
        case .MIGRAINEEND:
             questionInfo = QuestionInfo(text: "When did your migraine end?", infoKey: InfoKey.MIGRAINEEND)
            break
        case .MIGRAINESEVERITY:
             questionInfo = QuestionInfo(text: "What was the severity of your migraine?", infoKey: InfoKey.MIGRAINESEVERITY, sliderLabels: ["Mild - able to carry on with all normal activities", "Moderate - had to take something, stopped activity", "Severe - thought about going to ER, went to bed early"])
            break
        case .MIGRAINESTART:
             questionInfo =  QuestionInfo(text: "When did your migraine start?", infoKey: InfoKey.MIGRAINESTART)
            break
//        case .MORNINGNOTIFICATION:
//             questionInfo =
//            break
//        case .NEXTPERIOD:
//             questionInfo =QuestionInfo(text: "Anticipated date of next period", infoKey: InfoKey.NEXTPERIOD)
//            break
//        case .SLEEPDURATIONHOURS:
//             questionInfo =
//            break
        case .SLEEPDURATIONMINUTES:
             questionInfo = QuestionInfo(text: "How long did you sleep last night?", infoKey: InfoKey.SLEEPDURATIONMINUTES)
            break
        case .SLEEPQUALITY:
             questionInfo = QuestionInfo(text: "Quality of your sleep?", infoKey: InfoKey.SLEEPQUALITY, sliderLabels: ["Sleep was awesome", "Felt rested in the morning", "Usual night's sleep", "Ok, could be better", "Felt like crap in the morning"])
            break
        case .STRESSLEVEL:
             questionInfo = QuestionInfo(text: "How stressed are you?", infoKey: InfoKey.STRESSLEVEL, sliderLabels:["Relaxing day", "Usual day", "Somewhat stressful", "Stressful", "Very Stressful"])
            break
        case .SYMPTOMSTODAY:
            questionInfo = QuestionInfo(text: "Symptoms", infoKey: InfoKey.SYMPTOMSTODAY)
            break
        case .TRIGGERSTODAY:
             questionInfo = QuestionInfo(text: "Triggers", infoKey: InfoKey.TRIGGERSTODAY)
            break

        default:
            questionInfo = QuestionInfo(text: "Error: Question Missing", infoKey: infoKey)
        }
        return questionInfo
    }
    
}
