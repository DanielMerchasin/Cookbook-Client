import UIKit

/*
 * Main View Controller
 * Displays top bar, main container view and a bottom navigation bar
 */
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private enum RecipeListSource {
        case latest
        case search
        case user
    }
    
    var categories = [Category]()
    var recipes = [Recipe]()
    var tblRecipes: UITableView!
    var refreshControl: UIRefreshControl!
    
    // Buttons for bottom bar - change with images
    var btnLatest, btnSearch, btnAdd, btnProfile, btnLogIn: UIButton!
    
    let recipesPerPage = 30
    let maxCellsForTableView = 100
    
    private var recipeListSource: RecipeListSource = .latest
    var page = 0
    var resource = "recipes/latest"
    var params = ""
    var maxUploadTime: Int64 = 0
    var fetching = false
    var recipesFetchedInLastRequest: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tblRecipes = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 65))
        tblRecipes.dataSource = self
        tblRecipes.delegate = self
        tblRecipes.rowHeight = 120
        
        view.addSubview(tblRecipes)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshActivated(sender:)), for: .valueChanged)
        tblRecipes.addSubview(refreshControl)
        
        // Button bar
        btnLatest = UIButton(type: .system)
        btnLatest.frame = CGRect(x: 15, y: view.frame.height - 55, width: 45, height: 45)
//        btnLatest.setTitle("Latest", for: .normal)
        btnLatest.setImage(UIImage(named: "img_btn_latest"), for: .normal)
        btnLatest.addTarget(self, action: #selector(btnLatestClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnLatest)
        
        btnSearch = UIButton(type: .system)
        btnSearch.frame = CGRect(x: 90, y: view.frame.height - 55, width: 45, height: 45)
//        btnSearch.setTitle("Search", for: .normal)
        btnSearch.setImage(UIImage(named: "img_btn_search"), for: .normal)
        btnSearch.addTarget(self, action: #selector(btnSearchClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnSearch)
        
        btnAdd = UIButton(type: .system)
        btnAdd.frame = CGRect(x: 165, y: view.frame.height - 55, width: 45, height: 45)
//        btnAdd.setTitle("Add", for: .normal)
        btnAdd.setImage(UIImage(named: "img_btn_add"), for: .normal)
        btnAdd.addTarget(self, action: #selector(btnAddClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnAdd)
        
        btnProfile = UIButton(type: .system)
        btnProfile.frame = CGRect(x: 240, y: view.frame.height - 55, width: 45, height: 45)
//        btnProfile.setTitle("Profile", for: .normal)
        btnProfile.setImage(UIImage(named: "img_btn_user"), for: .normal)
        btnProfile.addTarget(self, action: #selector(btnProfileClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnProfile)
        
        btnLogIn = UIButton(type: .system)
        btnLogIn.frame = CGRect(x: 305, y: view.frame.height - 55, width: 45, height: 45)
//        btnLogIn.setTitle("Log In", for: .normal)
        btnLogIn.setImage(UIImage(named: "img_btn_log_in"), for: .normal)
        btnLogIn.addTarget(self, action: #selector(btnLogInClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnLogIn)
        
        fetchRecipes(refresh: true)
        
        // Check if a user is logged in
        if let user = User.load() {
            Toast.makeText(self, message: "Welcome, \(user.username)!", length: .long)
//            btnLogIn.setTitle("Log Out", for: .normal)
            btnLogIn.setImage(UIImage(named: "img_btn_log_out"), for: .normal)
        }
        
        // Load the categories to memory and do nothing with them yet
        Category.loadCategories()
        
        // Mark the "latest" button, because that's the first set of recipes to display
        btnLatest.setImage(UIImage(named: "img_btn_latest_clicked"), for: .normal)
        
    }
    
    private func switchRecipeListSource(to source: RecipeListSource) {
        
        guard recipeListSource != source else { return }
        
        print("Switching source from \(recipeListSource) to \(source)")
        
        // Disable current source
        switch recipeListSource {
            case .latest: btnLatest.setImage(UIImage(named: "img_btn_latest"), for: .normal)
            case .search: btnSearch.setImage(UIImage(named: "img_btn_search"), for: .normal)
            case .user: btnProfile.setImage(UIImage(named: "img_btn_user"), for: .normal)
        }
        
        // Enable new source
        switch source {
            case .latest: btnLatest.setImage(UIImage(named: "img_btn_latest_clicked"), for: .normal)
            case .search: btnSearch.setImage(UIImage(named: "img_btn_search_clicked"), for: .normal)
            case .user: btnProfile.setImage(UIImage(named: "img_btn_user_clicked"), for: .normal)
        }
        
        recipeListSource = source
    }
    
    @objc private func btnLatestClicked(sender: UIButton) {
        
        guard recipeListSource != .latest else { return }
        
        resource = "recipes/latest"
        params = ""
        fetchRecipes(refresh: true, recipeListSource: .latest)
    }
    
    @objc private func btnSearchClicked(sender: UIButton) {
        
        SearchViewController.display(self) { s in
            self.resource = "recipes/search"
            self.params = s
            self.fetchRecipes(refresh: true, recipeListSource: .search)
        }
    }
    
    @objc private func btnAddClicked(sender: UIButton) {
        if User.load() != nil {
            // Launch recipe addition window
            RecipeModifyViewController.display(self, completionHandler: { (recipe, index) in
                RecipeDisplayViewController.display(self, recipe: recipe, edited: true)
            })
        } else {
            // Launch login window
            LoginViewController.display(self) { (username) in
                // Successful login
                Toast.makeText(self, message: "Welcome, \(username)!", length: .long)
                self.btnAddClicked(sender: sender)
            }
        }
    }
    
    @objc private func btnProfileClicked(sender: UIButton) {
        if User.load() != nil {
            // Load user recipes
            resource = "recipes/user"
            params = ""
            fetchRecipes(refresh: true, recipeListSource: .user)
        } else {
            // Launch login window
            LoginViewController.display(self) { (username) in
                // Successful login
                Toast.makeText(self, message: "Welcome, \(username)!", length: .long)
                self.btnProfileClicked(sender: sender)
            }
        }
    }
    
    @objc private func btnLogInClicked(sender: UIButton) {
        if User.load() != nil {
            DialogViewController.dialog(self, message: "Are you sure you want to log out?") {
                User.logout()
//                self.btnLogIn.setTitle("Log In", for: .normal)
                self.btnLogIn.setImage(UIImage(named: "img_btn_log_in"), for: .normal)
            }
        } else {
            // Launch login window
            LoginViewController.display(self) { (username) in
                // Successful login
                Toast.makeText(self, message: "Welcome, \(username)!", length: .long)
//                self.btnLogIn.setTitle("Log Out", for: .normal)
                self.btnLogIn.setImage(UIImage(named: "img_btn_log_out"), for: .normal)
            }
        }
    }
    
    private func enableUI(_ enable: Bool) {
        btnLatest.isEnabled = enable
        btnSearch.isEnabled = enable
        btnAdd.isEnabled = enable
        btnProfile.isEnabled = enable
        btnLogIn.isEnabled = enable
    }
    
    @objc func refreshActivated(sender: UIRefreshControl) {
        fetchRecipes(refresh: true)
    }
    
    private func fetchRecipes(refresh: Bool, recipeListSource: RecipeListSource? = nil) {
        
        guard !fetching else { return }
        
        fetching = true
        enableUI(false)
        
        let session = URLSession(configuration: .default)
        
        if refresh {
            page = 0
            maxUploadTime = Int64(NSDate().timeIntervalSince1970 * 1000)
            recipesFetchedInLastRequest = nil
        } else {
            page += 1
        }
        
        let url = URL(string: "\(Utils.BASE_URL)/\(resource)?page_num=\(page)&recipes_per_page=\(recipesPerPage)&max_upload_time=\(maxUploadTime)\(params)")
        
        print("URL: \(url!.absoluteString)")
        
        var request = URLRequest(url: url!)
        
        if let user = User.load() {
            request.setValue(user.auth, forHTTPHeaderField: "Authorization")
        }
        
        DispatchQueue.global().async {
            
            session.dataTask(with: request) { (data, response, error) in
                let responseCode = (response as! HTTPURLResponse).statusCode
                guard let theData = data, error == nil, responseCode < 400,
                    let json: [String:Any] = try? JSONSerialization.jsonObject(with: theData, options: .allowFragments) as! [String:Any] else {
                    session.finishTasksAndInvalidate()
                    AlertViewController.alert(data: data, presenting: self, defaultMessage: "Failed to fetch recipes. Please try again.")
                    self.refreshControl.endRefreshing()
                    self.fetching = false
                    self.enableUI(true)
                    return
                }
                
                print("Response body: \(json)")
                
                if refresh {
                    self.recipes.removeAll()
                }
                
                let recipes:[[String:Any]] = json["recipes"] as! [[String:Any]]
                
                for recipe in recipes {
                    self.recipes.append(Recipe(json: recipe))
                }
                
                self.recipesFetchedInLastRequest = recipes.count
                
                DispatchQueue.main.async {
                    session.finishTasksAndInvalidate()
                    self.tblRecipes.reloadData()
                    self.refreshControl.endRefreshing()
                    self.fetching = false
                    self.enableUI(true)
                    if let theRecipeListSource = recipeListSource {
                        self.switchRecipeListSource(to: theRecipeListSource)
                    }
                }
                
            }.resume()
            
        }
        
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: RecipeCell? = tableView.dequeueReusableCell(withIdentifier: "identifier") as? RecipeCell
        
        if cell == nil {
            cell = RecipeCell(style: .subtitle, reuseIdentifier: "identifier")
        }
        
        let recipe = recipes[indexPath.row]
        cell!.lblName.text = recipe.name
        
        if let theCatName = recipe.categoryName {
            cell!.lblCatName.text = theCatName
        }
        
        if let theUser = recipe.username {
            cell!.lblUsername.text = "Created by \(theUser)"
        }
        
        if let theUploadTime = recipe.uploadTime {
            cell!.lblUploadTime.text = "on \(Date(milliseconds: theUploadTime).format())"
        }
        
        if recipe.photos.count > 0 {
            cell!.imgThumbnail.image = UIImage(data: recipe.photos[0].thumbnail)
        } else {
            cell!.imgThumbnail.image = UIImage(named: "placeholder")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        RecipeDisplayViewController.display(self, recipe: recipes[indexPath.row], row: indexPath.row, editedHandler: { index in
            self.fetchRecipes(refresh: true)
        }, deleteHandler: { index in
            self.fetchRecipes(refresh: true)
        })
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let fetched = recipesFetchedInLastRequest, fetched < recipesPerPage {
            return
        }
        
        if recipes.count >= maxCellsForTableView {
            return
        }
        
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
        if distanceFromBottom < height {
            fetchRecipes(refresh: false)
        }
    }

}

