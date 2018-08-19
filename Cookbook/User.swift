import Foundation

public class User {
    
    private static var user: User?
    
    private static let dataFile = "user_data.txt"
    
    public static func load() -> User? {
        if user == nil {
            let file = NSTemporaryDirectory() + dataFile
            let dict = NSDictionary(contentsOfFile: file)
            if let theDict = dict {
                user = User(dict: theDict)
            }
        }
        return user
    }
    
    public static func save(data: Data) throws -> User {
        var json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
        return save(id: json["id"] as! Int, username: json["username"] as! String, password: json["password"] as! String)
    }
    
    public static func save(id: Int, username: String, password: String) -> User {
        user = User(id: id, username: username, password: password)
        let file = NSTemporaryDirectory() + dataFile
        user!.toNSDictionary().write(toFile: file, atomically: true)
        return user!
    }
    
    public static func logout() {
        user = nil
        let file = NSTemporaryDirectory() + dataFile
        let fileManager = FileManager()
        do {
            if fileManager.fileExists(atPath: file) {
                try fileManager.removeItem(atPath: file)
            }
        } catch let error as NSError {
            print("Error deleting data file: \(error)")
        }
    }
    
    var id: Int
    var username, password: String
    
    private init(id: Int, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
    
    convenience init(dict: NSDictionary) {
        self.init(id: dict["id"] as! Int, username: dict["username"] as! String, password: dict["password"] as! String)
    }
    
    private func toNSDictionary() -> NSDictionary {
        return [
            "id" : id,
            "username" : username,
            "password" : password
        ]
    }
    
    var auth: String {
        get {
            return User.createAuthHeaderForUser(username, password: password)
        }
    }
    
    public static func createAuthHeaderForUser(_ username: String, password: String) -> String {
        let combined = "\(username):\(password)"
        let encoded = combined.data(using: .utf8)!.base64EncodedString()
        return "Basic \(encoded)"
    }
    
}
