//
//  UIColors+Additions.swift
//  Migraine
//
//  Created by Peter Kamm on 4/2/18.
//  Copyright © 2018 MIT. All rights reserved.
//

import UIKit

public extension UIColor {

    class func majorTextColor() -> UIColor! {
        return UIColor(red:0.79, green:0.79, blue:0.79, alpha:1)
    }
    
    class func minorTextColor() -> UIColor! {
        return UIColor(red:0.59, green:0.42, blue:0.38, alpha:1)
    }
    
    class func darkBackgroundColor() -> UIColor! {
        return UIColor(red:0.08, green:0.06, blue:0.05, alpha:1);
    }

}
