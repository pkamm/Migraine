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
    
    static let sharedInstance = DiaryService()

    var diaryEntries:[DiaryEntry] = []
    var dbRef: DatabaseReference!
    var pendingDiaryEntry: DiaryEntry?
    
    var dateFormatter: DateFormatter
    var dateFormatterShort: DateFormatter
    var oldDateFormatter: DateFormatter
    
    init() {
        self.dbRef = Database.database().reference()
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        print(Locale.current.identifier)

        dateFormatter.locale = Locale.current
        print(Locale.current.identifier)

        dateFormatterShort = DateFormatter()
        dateFormatterShort.dateStyle = .short
        
        oldDateFormatter = DateFormatter()
        oldDateFormatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm:ss zzz"
        
    }
    
    func addQuestionInfosToPendingDiaryEntry(questionInfos: [QuestionInfo]){
        for questionInfo:QuestionInfo in questionInfos {
            if questionInfo.value != nil {
                removeQuestionInfoFromPendingDiaryEntry(questionInfo)
                pendingDiaryEntry?.questionInfos.append(questionInfo)
            }
        }
    }
    
    func removeQuestionInfoFromPendingDiaryEntry(_ questionInfo: QuestionInfo){
        if var questionInfos = pendingDiaryEntry?.questionInfos {
            questionInfos = questionInfos.filter({ (existingQuestionInfo) -> Bool in
                return questionInfo.infoKey != existingQuestionInfo.infoKey
            })
            pendingDiaryEntry?.questionInfos = questionInfos
        }
    }
    
    func submitPendingDiaryEntry(completion: @escaping () -> Void) {
        if let diary = pendingDiaryEntry {
            deleteExistingDiaryOf(date: diary.date)
            let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
            let userId = Auth.auth().currentUser?.uid
            let curDate = dateFormatter.string(from: diary.date)
            var keyValues : [String:Any] = [:]
            for questionInfo in diary.questionInfos {
                keyValues[questionInfo.infoKey.rawValue] = questionInfo.value
            }
            usersRef.child(userId!).child(curDate).setValue(keyValues)
            pendingDiaryEntry = nil;
            completion()
        }
    }
    
    func deleteExistingDiaryOf(date:Date){
        for diaryEntry in self.diaryEntries {
            if diaryEntry.date == date {
                let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
                let userId = Auth.auth().currentUser?.uid
                let curDate = oldDateFormatter.string(from: date)
                usersRef.child(userId!).child(curDate).removeValue()
            }
        }
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
        pendingDiaryEntry = nil;
        completion()
    }
    
    func getUnfinishedMigraineDiaryEntry() -> DiaryEntry? {
        do{
            for diary in diaryEntries {
                if try diary.wasMigraine() && diary.migraineEndDateString() == nil {
                    if Calendar.current.dateComponents([.day], from: diary.date, to: Date()).day ?? 5 < 3 {
                        return diary
                    }
                }
            }
        } catch { return nil }
        return nil
    }
    
    func getDiaryEntries(completion: @escaping ([DiaryEntry]?) -> Void ) {
        let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
        if let userId = Auth.auth().currentUser?.uid{
            usersRef.child(userId).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                self.diaryEntries = []
                if let entries = snapshot.value as? [String:AnyObject?] {
                    for entry in entries {
                        self.diaryEntries.append(DiaryEntry(entry))
                    }
                    self.diaryEntries.sort(by: { $0.date > $1.date })
                    completion(self.diaryEntries)
                    print(self.diaryEntries)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func addCurrentListToPendingDiaryEntry(infoKey:InfoKey, list:[String]) {
        //TODO: replace if there already
        let questionInfo = QuestionInfo(value: list, infoKey: infoKey)
        pendingDiaryEntry?.questionInfos.append(questionInfo)
    }
    
    func hasEnteredSleepDataToday() -> Bool {
        let calendar = Calendar.current
        for diaryEntry in diaryEntries {
            if calendar.isDateInToday(diaryEntry.date) && diaryEntry.hasSleepData() {
                return true
            }
        }
        return false
    }

    func questionInfoFor(infoKey: InfoKey) -> QuestionInfo {
        var questionInfo:QuestionInfo
        switch infoKey {
        case .AGE:
            questionInfo = QuestionInfo(text: "How old are you?", infoKey: infoKey)
            break
        case .BIRTHCONTROL:
             questionInfo = QuestionInfo(text: "Methods of birth control", infoKey: infoKey)
            break
//        case .EVENINGNOTIFICATION:
//             questionInfo =
//            break
        case .GENDER:
             questionInfo = QuestionInfo(text: "Gender", infoKey:infoKey)
            break
        case .GENDERBORNAS:
             questionInfo = QuestionInfo(text: "What gender were you born as?", infoKey: infoKey)
            break
        case .HADMIGRAINE:
             questionInfo = QuestionInfo(text: "Did you have a migraine?", infoKey: infoKey)
            break
        case .HEADACHELOCATIONS:
            questionInfo = QuestionInfo(text: "Locations of migraine?", infoKey: infoKey)
            break
        case .HELPMIGRAINETODAY:
            questionInfo = QuestionInfo(text: "What helped?", infoKey: infoKey)
            break
        case .HORMONETHERAPY:
             questionInfo = QuestionInfo(text: "Any hormore therapy?", infoKey:infoKey)
            break
        case .LMP:
             questionInfo = QuestionInfo(text: "Date of LMP", infoKey: infoKey)
            break
//        case .LURKINGMIGRAINE:
//            questionInfo =
//            break
        case .MIGRAINEEND:
             questionInfo = QuestionInfo(text: "When did your migraine end?", infoKey: infoKey)
            break
        case .MIGRAINESEVERITY:
             questionInfo = QuestionInfo(text: "What was the severity of your migraine?", infoKey: infoKey, sliderLabels: ["Mild - able to carry on with all normal activities", "Moderate - had to take something, stopped activity", "Severe - thought about going to ER, went to bed early"])
            break
        case .MIGRAINESTART:
            questionInfo =  QuestionInfo(text: "When did your migraine start?", infoKey:infoKey)
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
             questionInfo = QuestionInfo(text: "How long did you sleep last night?", infoKey: infoKey)
            break
        case .SLEEPQUALITY:
             questionInfo = QuestionInfo(text: "Quality of your sleep?", infoKey: infoKey, sliderLabels: ["Sleep was awesome", "Felt rested in the morning", "Usual night's sleep", "Ok, could be better", "Felt like crap in the morning"])
            break
        case .STRESSLEVEL:
             questionInfo = QuestionInfo(text: "How stressed are you?", infoKey: infoKey, sliderLabels:["Relaxing day", "Usual day", "Somewhat stressful", "Stressful", "Very Stressful"])
            break
        case .SYMPTOMSTODAY:
            questionInfo = QuestionInfo(text: "Symptoms", infoKey: infoKey)
            break
        case .TRIGGERSTODAY:
             questionInfo = QuestionInfo(text: "Triggers", infoKey: infoKey)
            break
        case .HEADACHEDURATION:
            questionInfo = QuestionInfo(text: "How long does your typical headache last?", infoKey: infoKey)
            break
        case .HEADACHESIDE:
            questionInfo = QuestionInfo(text: "What side is your headache typically on?", infoKey: infoKey)
            break
        case .GETAURA:
            questionInfo = QuestionInfo(text: "Do you typically get aura?", infoKey: infoKey)
            break
        case .AURANOTES:
            questionInfo = QuestionInfo(text: "Describe your aura", infoKey: infoKey)
            break
        case .DIARYNOTES:
            questionInfo = QuestionInfo(text: "Additional Notes", infoKey: infoKey)
            break
        default:
            questionInfo = QuestionInfo(text: "Error: Question Missing", infoKey: infoKey)
        }
        return questionInfo
    }
    
}
