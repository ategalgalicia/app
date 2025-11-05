//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Post: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    
    public init(id: String, title: String, subtitle: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}
