import UIKit

public class LatestRecipesView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var recipeDescriptions: [RecipeDescription]!
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        recipeDescriptions = [RecipeDescription]()
        
        tableView = UITableView(frame: self.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 120
        
        self.addSubview(tableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshActivated(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        fetchLatestRecipes()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func refreshActivated(sender: UIRefreshControl) {
        fetchLatestRecipes()
    }
    
    private func fetchLatestRecipes() {
        
        // TODO: Disable UI
        
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let url = URL(string: "\(RequestManager.BASE_URL)/recipes/latest")
        
        DispatchQueue.global().async {
            
            session.dataTask(with: url!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                if (error == nil) {
                    if let theData = data {
                        do {
                            let json:[String:Any] = try JSONSerialization.jsonObject(with: theData, options: .allowFragments) as! [String:Any]
                            
                            self.recipeDescriptions.removeAll()
                            
                            print("Response body: \(json)")
                        
                            let recipes:[[String:Any]] = json["recipes"] as! [[String:Any]]
                            
                            for recipe in recipes {
                                self.recipeDescriptions.append(try RecipeDescription(json: recipe))
                            }
                        } catch {
                            // TODO: Change with alert controller message
                            print("Error: Failed to execute request")
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            
                            self.refreshControl.endRefreshing()
                            session.finishTasksAndInvalidate()
                            
                             // TODO: Enable UI
                        }
                    }
                }
            }).resume()
            
        }
        
        
    }
    
    public func cleanUp() {
        recipeDescriptions.removeAll()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDescriptions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: RecipeDescriptionCell? = tableView.dequeueReusableCell(withIdentifier: "identifier") as? RecipeDescriptionCell
        
        if cell == nil {
            cell = RecipeDescriptionCell(style: .subtitle, reuseIdentifier: "identifier")
        }
        
        let recipeDescription = recipeDescriptions[indexPath.row]
        cell!.lblName.text = recipeDescription.name
        
        if let theCatName = recipeDescription.category {
            cell!.lblCatName.text = theCatName
        }
        
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
