//
//  UIColor-HexColors.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 24/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import UIKit

extension UIColor {
    /// Creates a `UIColor` from an HTML hex color
    /// Thanks to Paul Hudson for the original code: [https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor]
    /// (Free example code you can take and re-use in your own projects.)
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        guard hex.hasPrefix("#"), hex.count == 7 else { return nil }
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...]) + "ff"
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil  }
        
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
