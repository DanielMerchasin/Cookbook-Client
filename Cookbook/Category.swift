import Foundation

public class Category {
    
    private static var values: [Category]?
    
    var id: Int
    var name: String
    var description: String?
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init(json: [String:Any]) throws {
        self.init(id: json["id"] as! Int, name: json["name"] as! String)
        description = json["description"] as! String?
    }
    
    public func toDictionary() -> [String:Any] {
        var result: [String:Any] = [
            "id": id,
            "name": name
        ]
        
        if let theDescription = description {
            result["description"] = theDescription
        }
        
        return result
    }
    
    public static func loadCategories(andThen handler: (([Category]?) -> ())? = nil) {
        if let theValues = values {
            handler?(theValues)
        } else {
            let session = URLSession(configuration: .default)
            let url = URL(string: "\(Utils.BASE_URL)/categories")
            
            DispatchQueue.global().async {
                session.dataTask(with: url!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    if (error == nil) {
                        if let theData = data {
                            do {
                                var result = [Category]()
                                let json:[String:Any] = try JSONSerialization.jsonObject(with: theData, options: .allowFragments) as! [String:Any]
//                                print("Categories response: \(json)")
                                
                                let cats:[[String:Any]] = json["categories"] as! [[String:Any]]
                                
                                for cat in cats {
                                    result.append(try Category(json: cat))
                                }
                                
                                DispatchQueue.main.async {
                                    session.finishTasksAndInvalidate()
                                    self.values = result
                                    handler?(self.values)
                                }
                                return
                            } catch {}
                        }
                    }
                    
                    DispatchQueue.main.async {
                        session.finishTasksAndInvalidate()
                        handler?(nil)
                    }
                    
                }).resume()
            }
            
        }
        
    }
    
}







