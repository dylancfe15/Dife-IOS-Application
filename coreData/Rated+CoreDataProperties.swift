//
//  Rated+CoreDataProperties.swift
//  
//
//  Created by Difeng Chen on 3/18/18.
//
//

import Foundation
import CoreData


extension Rated {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rated> {
        return NSFetchRequest<Rated>(entityName: "Rated")
    }

    @NSManaged public var rated: Bool

}
