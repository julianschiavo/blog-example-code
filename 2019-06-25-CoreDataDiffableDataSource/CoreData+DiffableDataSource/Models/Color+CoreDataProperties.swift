//
//  Color+CoreDataProperties.swift
//  CoreData+DiffableDataSource
//
//  Created by Julian Schiavo on 24/6/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//
//

import Foundation
import CoreData


extension Color {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Color> {
        return NSFetchRequest<Color>(entityName: "Color")
    }

    @NSManaged public var name: String
    @NSManaged public var hexColor: String

}
