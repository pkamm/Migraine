//
//  PatientInfoService.swift
//  Migraine
//
//  Created by Peter Kamm on 4/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class PatientInfoService {
    
    let KEYS = ["FULLNAME", "EMAIL", "TERMSAGREED", "BIRTHCONTROL", "AGE", "GENDER", "NEXTPERIOD", "BIRTHCONTROL", "LMP", "CONDITIONS", "MEDICATION", "HEADACHECONDITIONS", "HEADACHEDURATION", "SYMPTOMS", "TRIGGERS", "HELPMIGRAINE", "NUMBERPROMPTS", "SLEEP", "STRESS", "HEADACHELOCATIONS"]
    
    var patientInfo = [String: AnyObject]()
    var patientMedications = [Medication]()
    var dateFormatter: DateFormatter
    
    static let sharedInstance = PatientInfoService()
    
    var dbRef: DatabaseReference!
    
    init() {
        self.dbRef = Database.database().reference()
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
    }
    
    // updates (added/removed) medication of the patient to firebase
    func save(medications:[Medication]!, completion: @escaping () -> Void) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let date = NSDate()
        let curDate = dateFormatter.string(from: date as Date)
        let newMedications = medications.map { (medication) -> [String:Any] in
            return medication.asDictionary()
        }
        // upload to firebase
        let userId = Auth.auth().currentUser!.uid
        let medicationRef = self.dbRef.child("patient-records").child("patient-medication")
        medicationRef.child(userId).child(curDate).setValue(newMedications)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        completion()
    }
    
    func getMedications(completion: @escaping ([Medication]?) -> Void ) {
        let usersRef = self.dbRef.child("patient-records").child("patient-medication")
        let userId = Auth.auth().currentUser?.uid
        
        usersRef.child(userId!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let thing = snapshot.value as? [String:AnyObject] {
                var latestMedications:[Medication]? = nil
                var latestDate = Date.distantPast
                for (dateIndex, medicationDictionaryArray) in thing {
                    if let date = self.dateFormatter.date(from: dateIndex),
                    date > latestDate {
                        var newMedications:[Medication] = []
                        if let newMedicationArray = medicationDictionaryArray as? [String]{
                            for medicationName in newMedicationArray {
                                let newMedication = Medication(medicationName, frequency: .Other, dosage: "Unknown")
                                newMedications.append(newMedication)
                            }
                        } else if let newMedicationArray = medicationDictionaryArray as? [[String:Any]] {
                            for medicationDictionary in newMedicationArray {
                                let newMedication = Medication(fromDictionary: medicationDictionary)
                                newMedications.append(newMedication)
                            }
                        }
                        self.patientMedications = newMedications
                        latestMedications = newMedications
                        latestDate = date
                    }
                }
                completion(latestMedications)
                print(thing)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func saveUser(infoDictionary: [String: AnyObject]) {
        let usersRef = self.dbRef.child("patient-records").child("patient-info")
        let userId = Auth.auth().currentUser?.uid
        let curDate = dateFormatter.string(from: Date())
        
        for (key, value) in infoDictionary {
            patientInfo[key] = value as AnyObject
        }
        usersRef.child(userId!).child(curDate).setValue(patientInfo)
    }
    
    func getMedicalConditions(completion: @escaping ([String:AnyObject?]?) -> Void ) {
        let usersRef = self.dbRef.child("patient-records").child("patient-info")
        let userId = Auth.auth().currentUser?.uid
        
        usersRef.child(userId!).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let thing = snapshot.value as? [String:AnyObject] {
                var latestHealthObject:[String : AnyObject]? = nil
                var latestDate = Date.distantPast
                for (dateIndex, healthObject) in thing {
                    if let date = self.dateFormatter.date(from: dateIndex){
                        if date > latestDate, let healthDict = healthObject as? [String:AnyObject]{
                            self.patientInfo = healthDict as [String : AnyObject]
                            latestHealthObject = healthDict
                            latestDate = date
                        }
                    }
                }
                completion(latestHealthObject)
                print(thing)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func sendLocationDataToFirebase(_ dict: [String: Any]) {
        var locationDictionary = dict
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let userId = Auth.auth().currentUser?.uid {
            locationDictionary["user"] = userId
            print("sending location data to firebase. My dict is", dict)
            let usersRef = self.dbRef.child("patient-records").child("patient-location")
            let curDate = dateFormatter.string(from: Date())
            usersRef.child(userId).child(curDate).setValue(locationDictionary)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func sendHealthKitDataToFirebase(dict: [String: AnyObject]) {
        print("sending healthkit data to firebase")
        // check if user is logged in
        if (UserDefaults.standard.value(forKey: "uid") == nil ){ //|| GL_CURRENT_QUERY.authData == nil) {
            return
        }
        print("user exists")
        
        //var dict = [String: AnyObject]()
        //var testdict = [String: AnyObject]()
        //testdict["test"] = "test case"
        
        //print("My dict is", dict)
        // upload to firebase
        let usersRef = self.dbRef.child("patient-records").child("patient-healthkit")
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        let curDate = dateFormatter.string(from: date)
        
        usersRef.child(UserDefaults.standard.value(forKey: "uid") as! String).child(curDate).setValue(dict)
        print("done uploading user healthkit")
    }
    
    func sendNotesToFirebase(notes: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let userId = Auth.auth().currentUser?.uid {
            let usersRef = self.dbRef.child("patient-records").child("patient-notes")
            let curDate = dateFormatter.string(from: Date())
            usersRef.child(userId).child(curDate).setValue(notes)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }

}
