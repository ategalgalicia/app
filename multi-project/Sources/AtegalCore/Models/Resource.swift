//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Resource: Decodable, Identifiable, Hashable {
    public var id: String { title }
    public let title: String
    public let web: String?
    public let phone: [String]?
    public let address: String?
    public let contact: String?
    public let description: String?
    
    public init(title: String, web: String?, phone: [String]?, address: String?, contact: String?, description: String?) {
        self.title = title
        self.web = web
        self.phone = phone
        self.address = address
        self.contact = contact
        self.description = description
    }
}
