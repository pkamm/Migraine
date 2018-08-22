//
//  HealthManager.swift
//  Migraine
//
//  Created by Peter Kamm on 8/17/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics
import HealthKit
import Firebase

class HealthManager {
    static let sharedInstance = HealthManager()
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    typealias observerUpdateCompletionHandler = (HKObserverQuery, HKObserverQueryCompletionHandler, NSError?) -> ()
    typealias quantitySamplesToParse = ([HKQuantitySample]) -> [String: AnyObject] //change this to firebase
    
    let stepCountIdentifier = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
    let heartRateIdentifier = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
    let basalEnergyIdentifier = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)
    let activeEnergyIdentifier = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
    let sleepAnalysisIdentifier = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)
    let workoutTypeIdentifier = HKObjectType.workoutType()
    
    let stepType = "step"
    let hrType = "hr"
    let activeEnergyType = "activeEnergy"
    let basalEnergyType = "basalEnergy"
    let sleepType = "sleepAnalysis"
    let workoutType = "workout"
    
    var typeToString: [HKSampleType : String] = [:]
    var typeIsUpdating: [HKSampleType: Bool] = [:]
    var quantityTypeToSampleFunction: [HKSampleType: quantitySamplesToParse] = [:]
    
    
    func authorizeHealthKit(completion: @escaping (_ success:Bool, _ error:NSError?) -> Void?)
    {
        let healthKitTypesToRead: Set = [basalEnergyIdentifier!, activeEnergyIdentifier!, heartRateIdentifier!, stepCountIdentifier!, sleepAnalysisIdentifier!, workoutTypeIdentifier]
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "me.heejokeum.migraineapp", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(false, error)
            }
        } else {
            healthStore!.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) -> Void in
                if( completion != nil ) {
                    completion(success, error as! NSError)
                }
            }
        }
    }
    
    func observeAllChanges() {
        
        typeToString = [
            stepCountIdentifier! : stepType,
            heartRateIdentifier! : hrType,
            basalEnergyIdentifier! : basalEnergyType,
            activeEnergyIdentifier! : activeEnergyType,
            sleepAnalysisIdentifier! : sleepType,
            workoutTypeIdentifier : workoutType
        ]
        
        typeIsUpdating = [
            stepCountIdentifier! : false,
            heartRateIdentifier! : false,
            basalEnergyIdentifier! : false,
            activeEnergyIdentifier! : false,
            sleepAnalysisIdentifier! : false,
            workoutTypeIdentifier : false
        ]
        
        quantityTypeToSampleFunction = [
            stepCountIdentifier! : self.createStepObjects,
            heartRateIdentifier! : self.createHRObjects,
            basalEnergyIdentifier! : self.createBasalEnergyObjects,
            activeEnergyIdentifier! : self.createActiveEnergyObjects,
        ]
        
        for entry in quantityTypeToSampleFunction {
            observeChange(type: entry.0, completionHandler: self.quantityChangeHandler)
        }
        observeChange(type: sleepAnalysisIdentifier!, completionHandler: self.categoryChangedHandler)
        observeChange(type: workoutTypeIdentifier, completionHandler: self.workoutChangedHandler)
    }
    
    func observeChange(type : HKSampleType, completionHandler: @escaping observerUpdateCompletionHandler) {
        if let healthStore = self.healthStore {
//            let query: HKObserverQuery = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: completionHandler)
//            
//            healthStore.execute(query)
//            
//            healthStore.enableBackgroundDelivery(for: type, frequency: HKUpdateFrequency.immediate, withCompletion: {(succeeded: Bool, error: NSError?) in
//                
//                if succeeded{
//                    print("Enabled background delivery of changes of \(type)")
//                } else {
//                    if let theError = error{
//                        print("Failed to enable background delivery of changes of \(type)")
//                        print("Error = \(theError)")
//                    }
//                }
//                } as! (Bool, Error?) -> Void)
        }
    }
    
    func setNewAnchor(newAnchor: Int, key: String) {
        UserDefaults.standard.set(newAnchor, forKey: key)
        print("new \(key): \(newAnchor)")
        CLSLogv("new %@ value: %d", getVaList([key, newAnchor]))
    }
    
    func saveObjectsToFirebase(objectArray: [String: AnyObject], newAnchor: Int, type: String, identifier: HKSampleType) {
        
        // TODO:  this!
        //sendHealthKitDataToFirebase(objectArray) // how do we know if this actually completed
        print("successfully saved")
        self.setNewAnchor(newAnchor: newAnchor, key: "\(type)Anchor")
        self.typeIsUpdating[identifier] = false
    }
    
    func quantityChangeHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError? ) {
        let sampleType = query.sampleType
        let typeString = self.typeToString[sampleType!]!
        
        let parseObjectType = "\(typeString)Object"
        let anchorType = "\(typeString)Anchor"
        let isUpdating = self.typeIsUpdating[sampleType!]!
        
        print("in \(typeString) count change handler")
        
        if let identifier = query.sampleType, let healthStore = healthStore {
            if !isUpdating {
                self.typeIsUpdating[identifier] = true
                let anchor = UserDefaults.standard.integer(forKey: anchorType)
                print("current \(anchorType) value: \(anchor)")
                let query = HKAnchoredObjectQuery(type: identifier, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, newSamples, newAnchor, error) -> Void in
                    
                    guard let samples = newSamples as? [HKQuantitySample] else {
                        print("*** Unable to query for \(typeString) counts: \(error?.localizedDescription) ***")
                        if let error = error {
                            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["type" : parseObjectType])
                        } else {
                            Crashlytics.sharedInstance().recordError(NSError(domain: "com.aezhou.migraineaid.unableToQueryFor\(typeString)", code: 401, userInfo: ["time": NSDate()]))
                        }
                        self.typeIsUpdating[identifier] = false
                        abort()
                    }
                    if samples.count > 0  {
                        print("samples count", samples.count)
                        //print(samples)
                        if anchor == 0 {
                            self.setNewAnchor(newAnchor: newAnchor, key: anchorType)
                            self.typeIsUpdating[identifier] = false
                            print("making \(parseObjectType) parse objects: ", samples.count)
                            print("quantityTypeToSampleFunction", self.quantityTypeToSampleFunction[identifier]!)
                            let parseObjects = self.quantityTypeToSampleFunction[identifier]!(samples)
                            print("coming to anchor equals to 0")
                            self.saveObjectsToFirebase(objectArray: parseObjects, newAnchor: newAnchor, type: typeString, identifier: identifier)
                            print("saving \(typeString) object")
                        } else {
                            print("making \(parseObjectType) parse objects: ", samples.count)
                            let parseObjects = self.quantityTypeToSampleFunction[identifier]!(samples)
                            self.saveObjectsToFirebase(objectArray: parseObjects, newAnchor: newAnchor, type: typeString, identifier: identifier)
                            print("saving \(typeString) object")
                        }
                    } else {
                        print("no \(typeString) samples")
                        self.typeIsUpdating[identifier] = false
                    }
                    print("Done!")
                }
                healthStore.execute(query)
            }
        }
        completionHandler()
    }
    
    func createStepObjects(samples: [HKQuantitySample]) -> [String: AnyObject] {
        var stepObjects = [String: [AnyObject]]()
        for sample in samples {
            var stepObject = [String: AnyObject]()
            stepObject["user"] = UserDefaults.standard.value(forKey: "uid") as! String as AnyObject
            // the start date that will be used as a key of the object
            let startDate = sample.startDate
            let startDateFormatter = DateFormatter()
            startDateFormatter.dateStyle = .medium
            let keyStartDate = startDateFormatter.string(from: startDate)
            
            // more exact date to organize samples
            let exactDateFormatter = DateFormatter()
            exactDateFormatter.dateStyle = .long
            exactDateFormatter.timeStyle = .long
            
            let exactDate = exactDateFormatter.string(from: startDate)
            
            stepObject["timestmp"] = exactDate as AnyObject
            stepObject["quantity"] = sample.quantity.doubleValue(for: HKUnit.count()) as AnyObject
            //stepObject["extractionTime"] = NSDate() // extraction time can be seen on Firebase
            if stepObjects[keyStartDate] == nil {
                stepObjects[keyStartDate] = [stepObject] as [AnyObject]
            } else {
                stepObjects[keyStartDate]!.append(stepObject as AnyObject)
            }
        }
        var finalStepObjects = [String: AnyObject]()
        finalStepObjects["stepObjects"] = stepObjects as AnyObject
        return finalStepObjects
    }
    
    func createHRObjects(samples: [HKQuantitySample]) -> [String: AnyObject] {
        var hrObjects = [String: [AnyObject]]()
        for sample in samples {
            var hrObject = [String: AnyObject]()
            hrObject["user"] = UserDefaults.standard.value(forKey: "uid") as! String as AnyObject
            // the start date that will be used as a key of the object
            let startDate = sample.startDate
            let startDateFormatter = DateFormatter()
            startDateFormatter.dateStyle = .medium
            let keyStartDate = startDateFormatter.string(from: startDate)
            
            // more exact date to organize samples
            let exactDateFormatter = DateFormatter()
            exactDateFormatter.dateStyle = .long
            exactDateFormatter.timeStyle = .long
            let exactDate = exactDateFormatter.string(from: startDate)
            
            hrObject["timestmp"] = exactDate as AnyObject
            hrObject["quantity"] = sample.quantity.doubleValue(for: HKUnit(from: "count/min")) as AnyObject
            //hrObject["extractionTime"] = NSDate() // extraction time can be seen on Firebase
            if hrObjects[keyStartDate] == nil {
                hrObjects[keyStartDate] = [hrObject] as [AnyObject]
            } else {
                hrObjects[keyStartDate]!.append(hrObject as AnyObject)
            }
        }
        var finalHrObjects = [String: AnyObject]()
        finalHrObjects["hrObjects"] = hrObjects as AnyObject
        return finalHrObjects
    }
    
    func createActiveEnergyObjects(samples: [HKQuantitySample]) -> [String: AnyObject] {
        var activeEnergyObjects = [String: [AnyObject]]()
        for sample in samples {
            var activeEnergyObject = [String: AnyObject]()
            activeEnergyObject["user"] = UserDefaults.standard.value(forKey: "uid") as! String as AnyObject
            // the start date that will be used as a key of the object
            let startDate = sample.startDate
            let startDateFormatter = DateFormatter()
            startDateFormatter.dateStyle = .medium
            let keyStartDate = startDateFormatter.string(from: startDate)
            
            // more exact date to organize samples
            let exactDateFormatter = DateFormatter()
            exactDateFormatter.dateStyle = .long
            exactDateFormatter.timeStyle = .long
            let exactDate = exactDateFormatter.string(from: startDate)
            
            activeEnergyObject["timestmp"] = exactDate as AnyObject
            activeEnergyObject["quantity"] = sample.quantity.doubleValue(for: HKUnit(from: "kcal")) as AnyObject
            //activeEnergyObject["extractionTime"] = NSDate() // extraction time can be seen on Firebase
            if activeEnergyObjects[keyStartDate] == nil {
                activeEnergyObjects[keyStartDate] = [activeEnergyObject] as [AnyObject]
            } else {
                activeEnergyObjects[keyStartDate]!.append(activeEnergyObject as AnyObject)
            }
        }
        var finalActiveEnergyObjects = [String: AnyObject]()
        finalActiveEnergyObjects["activeEnergyObjects"] = activeEnergyObjects as AnyObject
        return finalActiveEnergyObjects
    }
    
    func createBasalEnergyObjects(samples: [HKQuantitySample]) -> [String: AnyObject] {
        var basalEnergyObjects = [String: [AnyObject]]()
        for sample in samples {
            var basalEnergyObject = [String: AnyObject]()
            basalEnergyObject["user"] = UserDefaults.standard.value(forKey: "uid") as! String as AnyObject
            // the start date that will be used as a key of the object
            let startDate = sample.startDate
            let startDateFormatter = DateFormatter()
            startDateFormatter.dateStyle = .medium
            let keyStartDate = startDateFormatter.string(from: startDate)
            
            // more exact date to organize samples
            let exactDateFormatter = DateFormatter()
            exactDateFormatter.dateStyle = .long
            exactDateFormatter.timeStyle = .long
            let exactDate = exactDateFormatter.string(from: startDate)
            
            basalEnergyObject["timestmp"] = exactDate as AnyObject
            basalEnergyObject["quantity"] = sample.quantity.doubleValue(for: HKUnit(from: "kcal")) as AnyObject
            //activeEnergyObject["extractionTime"] = NSDate() // extraction time can be seen on Firebase
            if basalEnergyObjects[keyStartDate] == nil {
                basalEnergyObjects[keyStartDate] = [basalEnergyObject] as [AnyObject]
            } else {
                basalEnergyObjects[keyStartDate]!.append(basalEnergyObject as AnyObject)
            }
        }
        var finalBasalEnergyObjects = [String: AnyObject]()
        finalBasalEnergyObjects["basalEnergyObjects"] = basalEnergyObjects as AnyObject
        return finalBasalEnergyObjects
    }
    
    func categoryChangedHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError?) {
        let sampleType = query.sampleType
        let typeString = self.typeToString[sampleType!]!
        let parseObjectType = "\(typeString)Object"
        let anchorType = "\(typeString)Anchor"
        let isUpdating = self.typeIsUpdating[sampleType!]!
        print("in \(typeString) category change handler")
        CLSLogv("inside %@ category change handler", getVaList([typeString]))
        
        if let identifier = query.sampleType, let healthStore = healthStore {
            if !isUpdating {
                self.typeIsUpdating[identifier] = true
                let anchor = UserDefaults.standard.integer(forKey: anchorType)
                print("current \(anchorType) value: \(anchor)")
                CLSLogv("%@ anchor: %d", getVaList(["\(typeString) count", anchor]))
                let query = HKAnchoredObjectQuery(type: identifier, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, newSamples, newAnchor, error) -> Void in
                    
                    guard let samples = newSamples as? [HKCategorySample] else {
                        print("*** Unable to query for \(typeString) category: \(String(describing: error?.localizedDescription)) ***")
                        if let error = error {
                            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["type" : parseObjectType])
                        } else {
                            Crashlytics.sharedInstance().recordError(NSError(domain: "com.aezhou.migraineaid.unableToQueryFor\(typeString)", code: 401, userInfo: ["time": NSDate()]))
                        }
                        self.typeIsUpdating[identifier] = false
                        abort()
                    }
                    if samples.count > 0  {
                        if anchor == 0 {
                            self.setNewAnchor(newAnchor: newAnchor, key: anchorType)
                            self.typeIsUpdating[identifier] = false
                            print("making \(parseObjectType) parse objects: ", samples.count)
                            let parseObjects = self.createSleepAnalysisObjects(samples: samples) //TODO: make this a dictionary like quantities if we are tracking more than one category
                            self.saveObjectsToFirebase(objectArray: parseObjects, newAnchor: newAnchor, type: typeString, identifier: identifier)
                            print("saving \(typeString) object")
                        } else {
                            print("making \(parseObjectType) parse objects: ", samples.count)
                            let parseObjects = self.createSleepAnalysisObjects(samples: samples) //TODO: make this a dictionary like quantities if we are tracking more than one category
                            self.saveObjectsToFirebase(objectArray: parseObjects, newAnchor: newAnchor, type: typeString, identifier: identifier)
                            print("saving \(typeString) object")
                        }
                    } else {
                        print("no \(typeString) samples")
                        self.typeIsUpdating[identifier] = false
                    }
                    print("Done!")
                }
                healthStore.execute(query)
            }
        }
        completionHandler()
    }
    
    func createSleepAnalysisObjects(samples: [HKCategorySample]) -> [String: AnyObject] {
        var sleepAnalysisObjects = [String: [AnyObject]]()
        for sample in samples {
            var sleepAnalysisObject = [String: AnyObject]()
            sleepAnalysisObject["user"] = UserDefaults.standard.value(forKey: "uid") as! String as AnyObject
            // the start date that will be used as a key of the object
            let startDate = sample.startDate
            let endDate = sample.endDate
            
            let startDateFormatter = DateFormatter()
            startDateFormatter.dateStyle = .medium
            let keyStartDate = startDateFormatter.string(from: startDate)
            
            // more exact date to organize samples
            let exactDateFormatter = DateFormatter()
            exactDateFormatter.dateStyle = .long
            exactDateFormatter.timeStyle = .long
            let exactStartDate = exactDateFormatter.string(from: startDate)
            let exactEndDate = exactDateFormatter.string(from: endDate)
            sleepAnalysisObject["startDate"] = exactStartDate as AnyObject
            sleepAnalysisObject["endDate"] = exactEndDate as AnyObject
            sleepAnalysisObject["type"] = sample.value as AnyObject // 1 = asleep, 0 = in bed
            //stepObject["extractionTime"] = NSDate() // the samples are organized by extraction time
            //extraction time can be seen on Firebase
            if sleepAnalysisObjects[keyStartDate] == nil {
                sleepAnalysisObjects[keyStartDate] = [sleepAnalysisObject] as [AnyObject]
            } else {
                sleepAnalysisObjects[keyStartDate]!.append(sleepAnalysisObject as AnyObject)
            }
        }
        var finalSleepAnalysisObjects = [String: AnyObject]()
        finalSleepAnalysisObjects["sleepAnalysisObjects"] = sleepAnalysisObjects as AnyObject
        return finalSleepAnalysisObjects
    }
    
    func workoutChangedHandler(query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: NSError? ) {
        let sampleType = query.sampleType
        let typeString = self.typeToString[sampleType!]!
        let parseObjectType = "\(typeString)Object"
        let anchorType = "\(typeString)Anchor"
        let isUpdating = self.typeIsUpdating[sampleType!]!
        print("in \(typeString) category change handler")
        CLSLogv("inside %@ category change handler", getVaList([typeString]))
        
        if let healthStore = healthStore {
            if !isUpdating {
                self.typeIsUpdating[workoutTypeIdentifier] = true
                let anchor = UserDefaults.standard.integer(forKey: anchorType)
                print("current \(anchorType) value: \(anchor)")
                CLSLogv("%@ anchor: %d", getVaList(["\(typeString) count", anchor]))
                let query = HKAnchoredObjectQuery(type: workoutTypeIdentifier, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, newSamples, newAnchor, error) -> Void in
                    
                    guard let samples = newSamples as? [HKWorkout] else {
                        print("*** Unable to query for \(typeString): \(String(describing: error?.localizedDescription)) ***")
                        if let error = error {
                            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["type" : "parseObjectType"])
                        } else {
                            Crashlytics.sharedInstance().recordError(NSError(domain: "com.aezhou.migraineaid.unableToQueryForWorkouts", code: 401, userInfo: ["time": NSDate()]))
                        }
                        self.typeIsUpdating[self.workoutTypeIdentifier] = false
                        abort()
                    }
                    
                    if samples.count > 0 {
                        if anchor == 0 {
                            self.setNewAnchor(newAnchor: newAnchor, key: "workoutAnchor")
                            self.typeIsUpdating[self.workoutTypeIdentifier] = false
                            print("making \(parseObjectType) parse objects: ", samples.count)
                            let parseObjects = self.createWorkoutObjects(samples: samples)
                            self.saveObjectsToFirebase(objectArray: parseObjects, newAnchor: newAnchor, type: typeString, identifier: self.workoutTypeIdentifier)
                            print("saving \(typeString) object")
                            
                        } else {
                            print("making \(parseObjectType) parse objects: ", samples.count)
                            let parseObjects = self.createWorkoutObjects(samples: samples)
                            self.saveObjectsToFirebase(objectArray: parseObjects, newAnchor: newAnchor, type: typeString, identifier: self.workoutTypeIdentifier)
                            print("saving \(typeString) object")
                        }
                    } else {
                        print("no \(typeString) samples")
                        self.typeIsUpdating[self.workoutTypeIdentifier] = false
                    }
                    print("Done!")
                }
                healthStore.execute(query)
                
            }
        }
        completionHandler()
    }
    func createWorkoutObjects(samples: [HKWorkout]) -> [String: AnyObject] {
        var workoutObjects = [String: [AnyObject]]()
        for sample in samples {
            var workoutObject = [String: AnyObject]()
            workoutObject["user"] = UserDefaults.standard.value(forKey: "uid") as! String as AnyObject
            // the start date that will be used as a key of the object
            let startDate = sample.startDate
            
            let startDateFormatter = DateFormatter()
            startDateFormatter.dateStyle = .medium
            let keyStartDate = startDateFormatter.string(from: startDate)
            
            // more exact date to organize samples
            let exactDateFormatter = DateFormatter()
            exactDateFormatter.dateStyle = .long
            exactDateFormatter.timeStyle = .long
            let exactStartDate = exactDateFormatter.string(from: startDate)
            workoutObject["startDate"] = exactStartDate as AnyObject
            workoutObject["duration"] = sample.duration/60.0 as AnyObject
            workoutObject["type"] = sample.workoutActivityType.rawValue as AnyObject // 52 = walking, 37 = running, 13 = cycling
            
            if let totalEnergy = sample.totalEnergyBurned {
                workoutObject["totalEnergyBurned"] = totalEnergy.doubleValue(for: HKUnit(from: "kcal")) as AnyObject
            }
            if workoutObjects[keyStartDate] == nil {
                workoutObjects[keyStartDate] = [workoutObject] as [AnyObject]
            } else {
                workoutObjects[keyStartDate]!.append(workoutObject as AnyObject)
            }
        }
        var finalWorkoutObjects = [String: AnyObject]()
        finalWorkoutObjects["workoutObjects"] = workoutObjects as AnyObject
        return finalWorkoutObjects
    }
    
}
