//
//  DataService.swift
//  Migraine
//
//  Created by Peter Kamm on 11/14/17.
//  Copyright © 2017 MIT. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class DataService {
    
//    let firebase = Firebase(
//

    static let sharedInstance = DataService()
    var dbRef: DatabaseReference!
    
    init() {
        self.dbRef = Database.database().reference()
    }
    

    
    func getMedicalConditions(completion: @escaping ([String:String]) -> Void ) {
        let usersRef = self.dbRef.child("patient-records").child("patient-info")
        let userId = Auth.auth().currentUser?.uid
        
        // update to actually take latest result
        usersRef.child(userId!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let thing = snapshot.value as? [String:AnyObject] {
                for (index:healthObject) in thing.values {
                    print(index)
                    if let healthDict = healthObject as? [String:String]{
                        print(healthDict)
                        completion(healthDict)
                    }

                }
                print(thing)
            }
            
//            for child in snapshot.children {
//                if let healthinfo = child.value as? [String:Any] {
//                    print(healthinfo)
//                }
//            }
//
//            if let value = snapshot.children as? [Any] {
//                if let entryDict = value.last as? Dictionary<Date, Any> {
//
//                    print(entryDict)
//                   // completion(entryDict[)
//                }
//            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    func latestEntry(array: [Any]) -> Any? {
//        var latestEntry:Any
////        var sortedEntries = array.sorted(by: { (Date, Dictionary) -> Bool in
////
////            })
////
////        for entry in array {
////
////
////        }
//
//        return latestEntry
//    }

}





