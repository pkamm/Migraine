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
    
    
    func saveUser(infoDictionary: Dictionary<String, Any>) {
        let usersRef = self.dbRef.child("patient-record").child("patient-info")
        let userId = Auth.auth().currentUser?.uid
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.long
        let curDate = dateFormatter.string(from: Date())
        usersRef.child(userId!).child(curDate).setValue(userId)
    }
    
}
