//
//  UIColor-BasedOnBackground.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 25/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import UIKit

/// Calculates an appropriate text color based on the luminosity of the background
/// Taken from: [https://github.com/mattjgalloway/MJGFoundation/blob/master/Source/Categories/UIColor/UIColor-MJGAdditions.m#L68]
///
/// Copyright (c) 2011 Matt Galloway. All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without
/// modification, are permitted provided that the following conditions are met:
///
/// 1. Redistributions of source code must retain the above copyright notice, this
/// list of conditions and the following disclaimer.
///
/// 2. Redistributions in binary form must reproduce the above copyright notice,
/// this list of conditions and the following disclaimer in the documentation
/// and/or other materials provided with the distribution.
///
/// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
/// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
/// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
/// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
/// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
/// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
/// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
/// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
/// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
/// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

extension UIColor {
    var luminosity: CGFloat {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        var white: CGFloat = 0.0
        
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return 0.2126 * pow(red, 2.2) + 0.7152 * pow(green, 2.2) + 0.0722 * pow(blue, 2.2)
        } else if getWhite(&white, alpha: &alpha) {
            return pow(white, 2.2)
        }
        
        return -1
    }
    
    func luminosityDifference(_ otherColor: UIColor) -> CGFloat {
        let first = luminosity
        let second = otherColor.luminosity
        
        if first >= 0, second >= 0 {
            if first > second {
                return (first + 0.05) / (second + 0.05)
            } else {
                return (second + 0.05) / (first + 0.05)
            }
        }
        
        return 0.0
    }
    
    static func basedOnBackgroundColor(_ backgroundColor: UIColor) -> UIColor {
        let lightColor = UIColor.lightText
        let lightDifference = backgroundColor.luminosityDifference(lightColor)
        
        let darkColor = UIColor.darkText
        let darkDifference = backgroundColor.luminosityDifference(darkColor)
        
        return darkDifference > lightDifference ? darkColor : lightColor
    }
}
