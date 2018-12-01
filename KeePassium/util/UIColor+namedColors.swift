//
//  UIColor+namedColors.swift
//  KeePassium
//
//  Created by Andrei Popleteev on 2018-05-27.
//  Copyright © 2018 Andrei Popleteev. All rights reserved.
//

import UIKit

/// Adds named colors from the assets, as well as system colors as defined at
/// https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/
extension UIColor {
    
    static var actionTint: UIColor {
        return UIColor(named: "ActionTint") ?? UIColor.systemBlue
    }
    static var actionText: UIColor {
        return UIColor(named: "ActionText") ?? .white
    }
    static var destructiveTint: UIColor {
        return UIColor(named: "DestructiveTint") ?? UIColor.systemRed
    }
    static var destructiveText: UIColor {
        return UIColor(named: "DestructiveText") ?? .white
    }
    static var errorMessage: UIColor {
        return UIColor.systemRed
    }
    static var primaryText: UIColor {
        return UIColor(named: "PrimaryText") ?? .black
    }
    static var secondaryText: UIColor {
        return UIColor(named: "SecondaryText") ?? .darkGray
    }

//    static var navBarTint: UIColor {
//        return UIColor(named: "NavBarTint") ?? UIColor.systemBlue
//    }
    
    static let systemRed = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
    static let systemOrange = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    static let systemYellow = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
    static let systemGreen = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    static let systemTealBlue = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
    static let systemBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let systemPurple = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
    static let systemPink = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
}
