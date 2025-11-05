//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Center: Decodable, Identifiable, Hashable {
    public let id: String
    public let city: String
    public let address: String
    public let phone: [String]
    public let email: String?
    public let categories: [Category]
    
    public init(id: String, city: String, address: String, phone: [String], email: String?, categories: [Category]) {
        self.id = id
        self.city = city
        self.address = address
        self.phone = phone
        self.email = email
        self.categories = categories
    }
}
