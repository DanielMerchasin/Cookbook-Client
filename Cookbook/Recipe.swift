import UIKit

public class Recipe {
    
    var id: Int?
    var name: String?
    var categoryId: Int?
    var categoryName: String?
    var numServings: Int?
    var prepTime: Int?
    var cookTime: Int?
    var notes: String?
    var uploadTime: Int64?
    var editTime: Int64?
    var rating: Float?
    var visible: Bool?
    var userId: Int?
    var username: String?
    var ingredients = [Ingredient]()
    var steps = [String]()
    var photos = [Photo]()
    
    convenience init(json: [String:Any]) {
        self.init()
        id = json["id"] as! Int?
        name = json["name"] as! String?
        categoryId = json["category_id"] as! Int?	
        categoryName = json["cat_name"] as! String?
        numServings = json["num_servings"] as! Int?
        prepTime = json["prep_time"] as! Int?
        cookTime = json["cook_time"] as! Int?
        notes = json["notes"] as! String?
        uploadTime = json["upload_time"] as! Int64?
        editTime = json["edit_time"] as! Int64?
        rating = json["rating"] as! Float?
        visible = json["visible"] as! Bool?
        userId = json["user_id"] as! Int?
        username = json["username"] as! String?
        
        if let ingredientsData = json["ingredients"] as! [[String:Any]]? {
            for i in ingredientsData {
                ingredients.append(Ingredient(json: i))
            }
        }
        
        if let stepsData = json["steps"] as! [String]? {
            for s in stepsData {
                steps.append(s)
            }
        }
        
        if let photosData = json["photos"] as! [[String:Any]]? {
            for p in photosData {
                photos.append(Photo(json: p))
            }
        }
        
    }
    
    public func toDictionary() -> [String:Any] {
        
        // Convert ONLY values that should be used in a POST/PUT request
        var result = [String:Any]()
        
        if let theId = id {
            result["id"] = theId
        }
        
        if let theName = name {
            result["name"] = theName
        }
        
        if let theCategoryId = categoryId {
            result["category_id"] = theCategoryId
        }
        
        if let theNumServings = numServings {
            result["num_servings"] = theNumServings
        }
        
        if let thePrepTime = prepTime {
            result["prep_time"] = thePrepTime
        }
        
        if let theCookTime = cookTime {
            result["cook_time"] = theCookTime
        }
        
        if let theNotes = notes {
            result["notes"] = theNotes
        }
        
        if let theVisible = visible {
            result["visible"] = theVisible
        }
        
        var ingredientsArray = [[String:Any]]()
        for i in ingredients {
            ingredientsArray.append(i.toDictionary())
        }
        result["ingredients"] = ingredientsArray
        
        var stepsArray = [String]()
        for s in steps {
            stepsArray.append(s)
        }
        result["steps"] = stepsArray
        
        return result
    }
    
}

class RecipeCell: UITableViewCell {
    
    var imgThumbnail: UIImageView!
    var lblCatName, lblName, lblUsername, lblUploadTime: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgThumbnail = UIImageView(frame: CGRect(x: 10,
                                                 y: 10,
                                                 width: 100,
                                                 height: 100))
        
        lblCatName = UILabel(frame: CGRect(x: imgThumbnail.frame.width + 20,
                                           y: 10,
                                           width: contentView.frame.width - imgThumbnail.frame.width - 20,
                                           height: 16))
        lblCatName.font = UIFont.italicSystemFont(ofSize: 16)
        
        lblName = UILabel(frame: CGRect(x: imgThumbnail.frame.width + 20,
                                        y: 30,
                                        width: contentView.frame.width - imgThumbnail.frame.width - 20,
                                        height: 30))
        lblName.font = UIFont.boldSystemFont(ofSize: 18)
        lblName.numberOfLines = 0
        lblName.lineBreakMode = .byWordWrapping
        
        lblUsername = UILabel(frame: CGRect(x: imgThumbnail.frame.width + 20,
                                            y: 60,
                                            width: contentView.frame.width - imgThumbnail.frame.width - 20,
                                            height: 16))
        lblUsername.font = UIFont.systemFont(ofSize: 16)
        lblUsername.lineBreakMode = .byTruncatingTail
        
        lblUploadTime = UILabel(frame: CGRect(x: imgThumbnail.frame.width + 20,
                                          y: 80,
                                          width: contentView.frame.width - imgThumbnail.frame.width - 20,
                                          height: 16))
        lblUploadTime.font = UIFont.systemFont(ofSize: 16)
        lblUploadTime.lineBreakMode = .byTruncatingTail
        
        contentView.addSubview(imgThumbnail)
        contentView.addSubview(lblCatName)
        contentView.addSubview(lblName)
        contentView.addSubview(lblUsername)
        contentView.addSubview(lblUploadTime)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}








