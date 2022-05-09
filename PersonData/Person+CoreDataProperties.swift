//
//  Person+CoreDataProperties.swift
//  PersonData
//
//  Created by bmiit on 09/05/22.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?
    @NSManaged public var ssn: Int16

}

extension Person : Identifiable {

}
