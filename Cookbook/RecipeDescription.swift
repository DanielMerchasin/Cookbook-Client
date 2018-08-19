import UIKit

class RecipeDescription {
    
    var id: Int
    var name: String
    var rating: Float?
    var category: String?
    var thumbnail: Data?
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init(json: [String:Any]) throws {
        self.init(id: json["id"] as! Int, name: json["name"] as! String)
        self.rating = json["rating"] as! Float!
        self.category = json["cat_name"] as! String!
        
        // Get first thumbnail image
        let photos: [[String:Any]]? = json["photos"] as? [[String:Any]]
        if let thePhotos = photos {
            if thePhotos.count > 0 {
                let photo = thePhotos[0]
                let encodedThumbnail = photo["thumbnail"] as? String
                
                let id = photo["id"] as! Int
                let location = photo["location"] as! String
                let recipeId = photo["recipe_id"] as! Int
                
                print("Photo ID = \(id), Recipe ID = \(recipeId), Location = \(location)")
                
                // Decode Base64
                if let theEncodedThumbnail = encodedThumbnail {
                    print("Thumbnail exists!")
                    self.thumbnail = Data(base64Encoded: theEncodedThumbnail)
                }
                
            }
        }
        
    }
    
}

class RecipeDescriptionCell: UITableViewCell {
    
    var imgThumbnail: UIImageView!
    var lblCatName, lblName, lblRating: UILabel!
    
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
        
        lblRating = UILabel(frame: CGRect(x: imgThumbnail.frame.width + 20,
                                          y: 80,
                                          width: contentView.frame.width - imgThumbnail.frame.width - 20,
                                          height: 30))
        
        contentView.addSubview(imgThumbnail)
        contentView.addSubview(lblCatName)
        contentView.addSubview(lblName)
        contentView.addSubview(lblRating)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
