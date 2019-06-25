//
//  Color+CoreDataClass.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 24/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//
//

import CoreData
import UIKit

@objc(Color)
public class Color: NSManagedObject {
    var uiColor: UIColor? {
        UIColor(hex: hexColor)
    }
}
