//
//  SuccessAlert.swift
//  Migraine
//
//  Created by Peter Kamm on 5/1/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

public extension UIAlertController {

    func addCheckMark() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 8, width: 270, height: 60))
        imageView.contentMode = .center
        imageView.image = UIImage(named: "checkRed")
        self.view.addSubview(imageView)
    }
    

}
