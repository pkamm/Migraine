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
    
    static let sharedInstance = DiaryService()
    
    var dbRef: DatabaseReference!
    
    var pendingDiaryEntry: [QuestionInfo] = []
    
    init() {
        self.dbRef = Database.database().reference()
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
    }
    
    func addQuestionInfosToPendingDiaryEntry(questionInfos: [QuestionInfo]){
        for questionInfo:QuestionInfo in questionInfos {
            pendingDiaryEntry.append(questionInfo)
        }
    }
    
    func getDiaryEntries(completion: @escaping ([String:AnyObject?]?) -> Void ) {
        let usersRef = self.dbRef.child("patient-records").child("patient-diaries")
        let userId = Auth.auth().currentUser?.uid

        usersRef.child(userId!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)

            if let thing = snapshot.value as? [String:AnyObject] {
//                var latestHealthObject:[String : AnyObject]? = nil
//                var latestDate = Date.distantPast
//                for (dateIndex, healthObject) in thing {
//                    let date = self.dateFormatter.date(from: dateIndex)
//                    if date! > latestDate, let healthDict = healthObject as? [String:AnyObject]{
//                        self.patientInfo = healthDict as [String : AnyObject]
//                        latestHealthObject = healthDict
//                        latestDate = date!
//                    }
//                }
                completion(thing)
                print(thing)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}
