//
//  CDVideoRecord+CoreDataProperties.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 29/06/25.
//
//

import Foundation
import CoreData


extension CDVideoRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDVideoRecord> {
        return NSFetchRequest<CDVideoRecord>(entityName: "CDVideoRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var videoDate: Date?
    @NSManaged public var videoDescription: String?
    @NSManaged public var videoPath: String?
    @NSManaged public var videoTitle: String?

}

extension CDVideoRecord : Identifiable {

}
