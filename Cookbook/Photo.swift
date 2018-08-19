import UIKit

public class Photo {
    
    var id: Int
    var recipeId: Int
    var location: String
    var thumbnail: Data
    
    init(id: Int, recipeId: Int, location: String, thumbnail: Data) {
        self.id = id
        self.recipeId = recipeId
        self.location = location
        self.thumbnail = thumbnail
    }
    
    convenience init(json: [String:Any]) {
        let id = json["id"] as! Int
        let recipeId = json["recipe_id"] as! Int
        let location = json["location"] as! String
        let thumbnail = Data(base64Encoded: json["thumbnail"] as! String)!
        self.init(id: id, recipeId: recipeId, location: location, thumbnail: thumbnail)
    }
    
    public static func convertToBase64(_ image: UIImage) -> Data {
        return UIImagePNGRepresentation(image)!.base64EncodedData()
    }
    
}
