import UIKit

public class RecipeDescriptionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var data: [RecipeDescription]?
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let theData = data {
            return theData.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: RecipeDescriptionCell? = tableView.dequeueReusableCell(withIdentifier: "identifier") as? RecipeDescriptionCell
        
        if cell == nil {
            cell = RecipeDescriptionCell(style: .subtitle, reuseIdentifier: "identifier")
        }
        
        let recipeDescription = data![indexPath.row]
        cell!.lblName.text = recipeDescription.name
        
        if let theRating = recipeDescription.rating {
            cell!.lblRating.text = "Rating: \(theRating)%"
        } else {
            cell!.lblRating.text = "Rating: N/A"
        }
        
        if let theThumbnail = recipeDescription.thumbnail {
            cell!.imgThumbnail.image = UIImage(data: theThumbnail)
        } else {
            cell!.imgThumbnail.image = UIImage(named: "placeholder")
        }
        
        return cell!
    }
    
}
