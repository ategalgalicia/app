//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Activity: Decodable, Identifiable, Hashable {
    public var id: String { "\(title)|\(schedule)" }
    public let title: String
    public let schedule: String
    public let level: [String]?
    public let description: String
    public let address: String
    public let phone: [String]
    public let email: String?
    
    public init(title: String, schedule: String, level: [String]?, description: String, address: String, phone: [String], email: String?) {
        self.title = title
        self.schedule = schedule
        self.level = level
        self.description = description
        self.address = address
        self.phone = phone
        self.email = email
    }
}
