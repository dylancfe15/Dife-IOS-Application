//
//  Question+CoreDataProperties.swift
//  
//
//  Created by Difeng Chen on 3/18/18.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var category: String?
    @NSManaged public var choiceA: String?
    @NSManaged public var choiceB: String?
    @NSManaged public var choiceC: String?
    @NSManaged public var choiceD: String?
    @NSManaged public var correctAnswer: String?
    @NSManaged public var expand: String?
    @NSManaged public var level: Int16
    @NSManaged public var questionDate: NSDate?
    @NSManaged public var questionNum: Int16
    @NSManaged public var questionTitle: String?
    @NSManaged public var userAnswer: String?

}
