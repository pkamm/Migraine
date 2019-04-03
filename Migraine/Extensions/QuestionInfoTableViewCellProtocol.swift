//
//  QuestionInfoTableViewCellProtocol.swift
//  Migraine
//
//  Created by Peter Kamm on 4/3/19.
//  Copyright © 2019 MIT. All rights reserved.
//

import Foundation

protocol QuestionInfoTableViewCell {
    func setQuestionInfo(_ questionInfo:QuestionInfo!)
    func setEditDelegate(_ editDelegate:EditDelegate)
}

