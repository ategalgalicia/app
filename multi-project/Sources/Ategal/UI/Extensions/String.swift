//
//  Created by Michele Restuccia on 2/12/25.
//

public extension String {
    
    var capitalizedFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
}
