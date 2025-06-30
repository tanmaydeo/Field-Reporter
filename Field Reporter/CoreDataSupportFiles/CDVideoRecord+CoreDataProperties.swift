//
//  CDVideoRecord+CoreDataProperties.swift
//  Field Reporter
//
//  Created by Tanmay Deo on 30/06/25.
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
    @NSManaged public var videoTimeInterval: Int32
    @NSManaged public var videoThumbnail: Data?

}

extension CDVideoRecord : Identifiable {

}
