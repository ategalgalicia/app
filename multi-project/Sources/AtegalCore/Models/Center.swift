//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Center: Decodable, Identifiable, Hashable {
    public let id: String
    public let city: String
    public let address: String
    public let latitude: Double
    public let longitude: Double
    public let phone: [String]
    public let email: String?
    public let categories: [Category]
    
    public struct Category: Decodable, Identifiable, Hashable {
        public let id: String
        public let title: String
        public let activities: [Activity]
        public let resources: [Resource]?
        
        public struct Activity: Decodable, Identifiable, Hashable {
            public var id: String { "\(title)|\(schedule)" }
            public let title: String
            public let schedule: [String]
            public let weekday: [Int]
            public let description: String
            public let address: String
            public let phone: [String]
            public let email: String?
        }
        
        public struct Resource: Decodable, Identifiable, Hashable {
            public var id: String { title }
            public let title: String
            public let web: String?
            public let phone: [String]?
            public let address: String?
            public let contact: String?
            public let description: String?
        }
    }
}
