//
//  Users+CoreDataProperties.swift
//  NalanMachineText
//
//  Created by NalaN on 2/3/21.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var email: String?
    @NSManaged public var userId: Int16

}

extension Users : Identifiable {

}
