//
//  BookingModels.swift
//  mobileTest
//
//  Created by walllceleung on 8/8/2025.
//

import Foundation
import RealmSwift
import SwiftyJSON

// MARK: - Location
class Location: Object {
    @Persisted(primaryKey: true) var code: String = ""
    @Persisted var displayName: String = ""
    @Persisted var url: String = ""
    
    override init() {
        super.init()
    }
    
    convenience init(json: JSON) {
        self.init()
        code = json["code"].stringValue
        displayName = json["displayName"].stringValue
        url = json["url"].stringValue
    }
}

// MARK: - OriginAndDestinationPair
class OriginAndDestinationPair: EmbeddedObject {
    @Persisted var origin: Location?
    @Persisted var destination: Location?
    @Persisted var originCity: String = ""
    @Persisted var destinationCity: String = ""
    
    override init() {
        super.init()
    }
    
    convenience init(json: JSON) {
        self.init()
        originCity = json["originCity"].stringValue
        destinationCity = json["destinationCity"].stringValue
        
        if json["origin"].exists() {
            origin = Location(json: json["origin"])
        }
        
        if json["destination"].exists() {
            destination = Location(json: json["destination"])
        }
    }
}

// MARK: - Segment
class Segment: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var originAndDestinationPair: OriginAndDestinationPair?
    
    override init() {
        super.init()
    }
    
    convenience init(json: JSON) {
        self.init()
        id = json["id"].intValue
        
        if json["originAndDestinationPair"].exists() {
            originAndDestinationPair = OriginAndDestinationPair(json: json["originAndDestinationPair"])
        }
    }
}

// MARK: - Booking
class Booking: Object, Identifiable {
    @Persisted(primaryKey: true) var shipReference: String = ""
    @Persisted var shipToken: String = ""
    @Persisted var canIssueTicketChecking: Bool = false
    @Persisted var expiryTime: String = ""
    @Persisted var duration: Int = 0
    @Persisted var segments: List<Segment> = List<Segment>()
    @Persisted var fetchTimestamp: Date = Date()
    
    override init() {
        super.init()
    }
    
    convenience init(json: JSON) {
        self.init()
        shipReference = json["shipReference"].stringValue
        shipToken = json["shipToken"].stringValue
        canIssueTicketChecking = json["canIssueTicketChecking"].boolValue
        expiryTime = json["expiryTime"].stringValue
        duration = json["duration"].intValue
        fetchTimestamp = Date()
        
        // 解析segments数组
        if let segmentsArray = json["segments"].array {
            for segmentJSON in segmentsArray {
                let segment = Segment(json: segmentJSON)
                segments.append(segment)
            }
        }
    }
    
    var isValid: Bool {
        guard let expiryTimeInterval = TimeInterval(expiryTime) else {
            return false
        }
        let expiryDate = Date(timeIntervalSince1970: expiryTimeInterval)
        return Date() < expiryDate
    }
}
