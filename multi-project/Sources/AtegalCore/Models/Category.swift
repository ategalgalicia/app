//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Category: Decodable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let activities: [Activity]
    public let resources: [Resource]?
    
    public init(id: String, title: String, activities: [Activity], resources: [Resource]?) {
        self.id = id
        self.title = title
        self.activities = activities
        self.resources = resources
    }
}
