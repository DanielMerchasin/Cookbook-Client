import UIKit

extension Date {
    
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    public func format() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm"
        return formatter.string(from: self)
    }
    
}

public class Utils {
    
    public static let BASE_URL = "http://35.204.80.14/cookbook/api"
    
    public static func loadPhoto(forRecipe recipe: Recipe?, handleThumbnail thumbHandler: ((UIImage?) -> ())?, handleFullSizeImage handler: ((UIImage?, Bool) -> ())?) {
        
        guard let theRecipe = recipe, theRecipe.photos.count > 0 else {
            handler?(UIImage(named: "placeholder"), true)
            return
        }
        
        // Load the thumbnail before fetching image from the server
        thumbHandler?(UIImage(data: theRecipe.photos[0].thumbnail))
        
        let session = URLSession(configuration: .default)
        let url = URL(string: "\(Utils.BASE_URL)/photos/\(theRecipe.photos[0].location)")
        
        DispatchQueue.global().async {
            
            session.dataTask(with: url!) { (data, response, error) in
                
                guard let encodedData = data, error == nil, (response as! HTTPURLResponse).statusCode < 400 else {
                    DispatchQueue.main.async {
                        session.finishTasksAndInvalidate()
                        handler?(nil, false)
                    }
                    return
                }
                
                let decodedData = Data(base64Encoded: encodedData)
                
                DispatchQueue.main.async {
                    session.finishTasksAndInvalidate()
                    handler?(UIImage(data: decodedData!), false)
                }
                
            }.resume()
            
        }
        
    }
    
    
}
