//
//  QuestionInfo.swift
//  Migraine
//
//  Created by Peter Kamm on 4/20/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import Foundation

enum InfoKey: String {
    typealias RawValue = String
    case AGE
    case GENDER
    case NEXTPERIOD
    case LMP
    case BIRTHCONTROL
    case GENDERBORNAS
    case HORMONETHERAPY
    case SLEEPDURATIONHOURS
    case SLEEPDURATIONMINUTES
    case SLEEPQUALITY
    case STRESSLEVEL
    case HADMIGRAINE
    case LURKINGMIGRAINE
    case SYMPTOMSTODAY
    case TRIGGERSTODAY
    case HELPMIGRAINETODAY
    case MIGRAINESTART
    case MIGRAINEEND
    case MIGRAINESEVERITY
    case MORNINGNOTIFICATION
    case EVENINGNOTIFICATION
    case HEADACHELOCATIONS
}



class QuestionInfo {
    init(text: String, infoKey: InfoKey, sliderLabels: [String]? = nil) {
        self.text = text
        self.infoKey = infoKey
        self.sliderLabels = sliderLabels
    }
    init(value: Any?, infoKey: InfoKey) {
        self.value = value
        self.infoKey = infoKey
        self.text = ""
    }
    public let text: String
    public let infoKey: InfoKey
    public var value: Any? = nil
    public var sliderLabels:[String]? = nil
}
