//
//  Extensions.swift
//  CurrencyConverter
//
//  Created by Babajide  Mustapha on 09/09/2020.
//  Copyright © 2020 Babajide  Mustapha. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach(addSubview)
    }
}

protocol ScopeFuncs { }

extension ScopeFuncs {
    
    @inline(__always) func also(closure:(Self) -> ()) -> Void {
        closure(self)
    }
    
    @inline(__always) func apply(closure: (Self) -> ()) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: ScopeFuncs { }


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
