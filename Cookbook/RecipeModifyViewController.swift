import UIKit

public class RecipeModifyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let INGREDIENT_CELL_IDENTIFIER = "ingredient_cell"
    fileprivate let STEP_CELL_IDENTIFIER = "step_cell"
    
    var uploadManager = UploadManager()
    
    var recipe: Recipe!
    var listIdx: Int?
    var completionHandler: ((Recipe, Int?) -> ())?
    var deleteHandler: ((Int?) -> ())?
    
    var txtRecipeName, txtNumServings, txtPrepTime, txtCookTime: UITextField!
    var scrollView: UIVerticalScrollView!
    var imgPhoto: UIImageView!
    var btnChooseImage, btnDeleteImage, btnAddIngredient, btnAddStep, btnSave, btnDelete, btnCancel: UIButton!
    var tblIngredients, tblSteps: UITableView!
    var pkrCategory: UIPickerView!
    var chkVisible: UISwitch!
    fileprivate var categoryPickerViewDelegate: CategoryPickerViewDelegate!
    
    var imagePickerController: UIImagePickerController!
    
    var ingredients = [Ingredient]()
    var steps = [String]()
    var edited = false
    var imagePlaceholderUsed = true
    var userImage: UIImage?
    var defaultImage: UIImage?
    
    public override func viewDidLoad() {
        
        view.backgroundColor = .white

        txtRecipeName = UITextField(frame: CGRect(x: 10, y: 20, width: view.frame.width - 10 * 2, height: 30))
        txtRecipeName.textAlignment = .center
        txtRecipeName.font = .boldSystemFont(ofSize: 20)
        txtRecipeName.placeholder = "Recipe name"
        view.addSubview(txtRecipeName)
        
        scrollView = UIVerticalScrollView(frame: CGRect(x: 0, y: 70, width: view.frame.width, height: view.frame.height - 170))
        scrollView.contentSize = CGSize(width: view.frame.width, height: 940)
        
        imgPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 300))
        imgPhoto.contentMode = .scaleAspectFit
        scrollView.addSubview(imgPhoto)
        
        btnChooseImage = UIButton(type: .system)
        btnChooseImage.frame = CGRect(x: 10, y: 300, width: scrollView.frame.width / 2 - 10, height: 30)
        btnChooseImage.setTitle("Choose Image", for: .normal)
        btnChooseImage.addTarget(self, action: #selector(btnChooseImageClicked(sender:)), for: .touchUpInside)
        scrollView.addSubview(btnChooseImage)
        
        btnDeleteImage = UIButton(type: .system)
        btnDeleteImage.frame = CGRect(x: scrollView.frame.width / 2, y: 300, width: scrollView.frame.width / 2 - 10, height: 30)
        btnDeleteImage.setTitle("Delete Image", for: .normal)
        btnDeleteImage.setTitleColor(.red, for: .normal)
        btnDeleteImage.setTitleColor(.lightGray, for: .disabled)
        btnDeleteImage.addTarget(self, action: #selector(btnDeleteImageClicked(sender:)), for: .touchUpInside)
        scrollView.addSubview(btnDeleteImage)
        
        let lblNumServings = UILabel(frame: CGRect(x: 10, y: 350, width: scrollView.frame.width / 2 - 10 * 2, height: 30))
        lblNumServings.text = "Number of Servings:"
        lblNumServings.textAlignment = .center
        scrollView.addSubview(lblNumServings)
        
        txtNumServings = UITextField(frame: CGRect(x: scrollView.frame.width / 2, y: 350, width: scrollView.frame.width / 2 - 10 * 2, height: 30))
        txtNumServings.textAlignment = .center
        txtNumServings.delegate = NumberTextFieldDelegate()
        txtNumServings.keyboardType = .numberPad
        scrollView.addSubview(txtNumServings)
        
        let lblPrepTime = UILabel(frame: CGRect(x: 10, y: 390, width: scrollView.frame.width / 2 - 10 * 2, height: 30))
        lblPrepTime.text = "Preparation Time:"
        lblPrepTime.textAlignment = .center
        scrollView.addSubview(lblPrepTime)
        
        txtPrepTime = UITextField(frame: CGRect(x: scrollView.frame.width / 2, y: 390, width: scrollView.frame.width / 2 - 10 * 2, height: 30))
        txtPrepTime.textAlignment = .center
        txtPrepTime.placeholder = "(In minutes)"
        txtPrepTime.delegate = NumberTextFieldDelegate()
        txtPrepTime.keyboardType = .numberPad
        scrollView.addSubview(txtPrepTime)
        
        let lblCookTime = UILabel(frame: CGRect(x: 10, y: 430, width: scrollView.frame.width / 2 - 10 * 2, height: 30))
        lblCookTime.text = "Cooking Time:"
        lblCookTime.textAlignment = .center
        scrollView.addSubview(lblCookTime)
        
        txtCookTime = UITextField(frame: CGRect(x: scrollView.frame.width / 2, y: 430, width: scrollView.frame.width / 2 - 10 * 2, height: 30))
        txtCookTime.textAlignment = .center
        txtCookTime.placeholder = "(In minutes)"
        txtCookTime.delegate = NumberTextFieldDelegate()
        txtCookTime.keyboardType = .numberPad
        scrollView.addSubview(txtCookTime)
        
        let lblCategoryTitle = UILabel(frame: CGRect(x: 10, y: 470, width: scrollView.frame.width - 10 * 2, height: 30))
        lblCategoryTitle.text = "Select Category"
        lblCategoryTitle.textAlignment = .center
        scrollView.addSubview(lblCategoryTitle)
        
        pkrCategory = UIPickerView(frame: CGRect(x: 10, y: 500, width: scrollView.frame.width - 10 * 2, height: 80))
        categoryPickerViewDelegate = CategoryPickerViewDelegate()
        pkrCategory.delegate = categoryPickerViewDelegate
        pkrCategory.dataSource = categoryPickerViewDelegate
        scrollView.addSubview(pkrCategory)
        
        let lblIngredientsTitle = UILabel(frame: CGRect(x: 10, y: 600, width: scrollView.frame.width / 2 - 10, height: 30))
        lblIngredientsTitle.text = "Ingredients"
        lblIngredientsTitle.textAlignment = .center
        scrollView.addSubview(lblIngredientsTitle)
        
        btnAddIngredient = UIButton(type: .system)
        btnAddIngredient.frame = CGRect(x: scrollView.frame.width / 2, y: 600, width: scrollView.frame.width / 2 - 10, height: 30)
        btnAddIngredient.setTitle("+", for: .normal)
        btnAddIngredient.addTarget(self, action: #selector(btnAddIngredientClicked(sender:)), for: .touchUpInside)
        scrollView.addSubview(btnAddIngredient)
        
        tblIngredients = UITableView(frame: CGRect(x: 10, y: 630, width: scrollView.frame.width - 10 * 2, height: 100))
        tblIngredients.delegate = self
        tblIngredients.dataSource = self
        tblIngredients.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: INGREDIENT_CELL_IDENTIFIER)
        scrollView.addSubview(tblIngredients)
        
        let lblStepsTitle = UILabel(frame: CGRect(x: 10, y: 750, width: scrollView.frame.width / 2 - 10, height: 30))
        lblStepsTitle.text = "Steps"
        lblStepsTitle.textAlignment = .center
        scrollView.addSubview(lblStepsTitle)
        
        btnAddStep = UIButton(type: .system)
        btnAddStep.frame = CGRect(x: scrollView.frame.width / 2, y: 750, width: scrollView.frame.width / 2 - 10, height: 30)
        btnAddStep.setTitle("+", for: .normal)
        btnAddStep.addTarget(self, action: #selector(btnAddStepClicked(sender:)), for: .touchUpInside)
        scrollView.addSubview(btnAddStep)
        
        tblSteps = UITableView(frame: CGRect(x: 10, y: 780, width: scrollView.frame.width - 10 * 2, height: 100))
        tblSteps.delegate = self
        tblSteps.dataSource = self
        tblSteps.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: STEP_CELL_IDENTIFIER)
        scrollView.addSubview(tblSteps)
        
        chkVisible = UISwitch(frame: CGRect(x: 10, y: 900, width: 30, height: 30))
        scrollView.addSubview(chkVisible)
        
        let lblVisible = UILabel(frame: CGRect(x: 80, y: 900, width: scrollView.frame.width - 90, height: 30))
        lblVisible.text = "Visible to everyone"
        scrollView.addSubview(lblVisible)
        
        view.addSubview(scrollView)
        
        btnSave = UIButton(type: .system)
        btnSave.frame = CGRect(x: 10, y: view.frame.height - 100, width: view.frame.width - 10 * 2, height: 30)
        btnSave.setTitle("Save", for: .normal)
        btnSave.addTarget(self, action: #selector(btnSaveClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnSave)
        
        btnDelete = UIButton(type: .system)
        btnDelete.frame = CGRect(x: 10, y: view.frame.height - 70, width: view.frame.width - 10 * 2, height: 30)
        btnDelete.setTitle("Delete Recipe", for: .normal)
        btnDelete.addTarget(self, action: #selector(btnDeleteClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnDelete)
        
        btnCancel = UIButton(type: .system)
        btnCancel.frame = CGRect(x: 10, y: view.frame.height - 40, width: view.frame.width - 10 * 2, height: 30)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.red, for: .normal)
        btnCancel.setTitleColor(.lightGray, for: .disabled)
        btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnCancel)
        
        // Set values of recipe to modify, if such exists
        if recipe != nil {
            
            txtRecipeName.text = recipe.name
            txtNumServings.text = "\(recipe.numServings ?? 0)"
            txtPrepTime.text = "\(recipe.prepTime ?? 0)"
            txtCookTime.text = "\(recipe.cookTime ?? 0)"
            
            if recipe.visible ?? false {
                chkVisible.isOn = true
                chkVisible.setOn(true, animated: false)
            }
            
            ingredients.append(contentsOf: recipe.ingredients)
            tblIngredients.reloadData()
            steps.append(contentsOf: recipe.steps)
            tblSteps.reloadData()
            
            btnDeleteImage.isEnabled = !recipe.photos.isEmpty
            edited = true
            
        } else {
            recipe = Recipe()
            btnDeleteImage.isEnabled = false
            btnDelete.isEnabled = false
            edited = false
        }
        
        if let theDefaultImage = defaultImage {
            imgPhoto.image = theDefaultImage
            imagePlaceholderUsed = false
            defaultImage = nil
        } else {
            // Load the image or a placeholder to the image view
            Utils.loadPhoto(forRecipe: recipe, handleThumbnail: { (thumbnail) in
                if let theThumbnail = thumbnail {
                    self.imgPhoto.image = theThumbnail
                    self.imagePlaceholderUsed = false
                }
            }, handleFullSizeImage: { (image, isPlaceholder) in
                // Only load the full size image if the user didn't pick one yet or deleted the thumbnail
                if let theImage = image, (isPlaceholder || self.userImage == nil || !self.imagePlaceholderUsed) {
                    self.imgPhoto.image = theImage
                    self.imagePlaceholderUsed = isPlaceholder
                }
            })
        }
        
        // Load all categories to the picker view
        Category.loadCategories { categories in
            if let theCategories = categories {
                self.categoryPickerViewDelegate.categories = theCategories
                self.pkrCategory.reloadComponent(0)
                
                if self.edited, let categoryId = self.recipe.categoryId {
                    // Find the category by id
                    self.pkrCategory.selectRow(categoryId - 1, inComponent: 0, animated: false)
                }
            }
        }
        
    }
    
    private func enableUI(_ enable: Bool) {
        txtRecipeName.isEnabled = enable
        txtNumServings.isEnabled = enable
        txtPrepTime.isEnabled = enable
        txtCookTime.isEnabled = enable
        btnChooseImage.isEnabled = enable
        btnDeleteImage.isEnabled = enable && !imagePlaceholderUsed
        btnAddIngredient.isEnabled = enable
        btnAddStep.isEnabled = enable
        btnSave.isEnabled = enable
        btnDelete.isEnabled = enable && edited
        btnCancel.isEnabled = enable
        chkVisible.isEnabled = enable
        pkrCategory.isUserInteractionEnabled = enable
    }
    
    @objc private func btnAddIngredientClicked(sender: UIButton) {
        IngredientModifyViewController.display(self, completionHandler: { (ingredient, index) in
            self.ingredients.append(ingredient)
            self.tblIngredients.reloadData()
            self.tblIngredients.scrollToRow(at: IndexPath(row: self.ingredients.count - 1, section: 0), at: .bottom, animated: true)
        })
    }
    
    @objc private func btnAddStepClicked(sender: UIButton) {
        StepModifyViewController.display(self, completionHandler: { (step, index) in
            self.steps.append(step)
            self.tblSteps.reloadData()
            self.tblSteps.scrollToRow(at: IndexPath(row: self.steps.count - 1, section: 0), at: .bottom, animated: true)
        })
    }
    
    @objc private func btnChooseImageClicked(sender: UIButton) {
        
        let source = UIImagePickerControllerSourceType.photoLibrary
        
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            AlertViewController.alert(title: "Error", message: "The photo library is not available on your device.", presenting: self, handler: nil)
            return
        }
        
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = source
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @objc private func btnDeleteImageClicked(sender: UIButton) {
        
        // The image is in the modified recipe data, send a request to delete it
        DialogViewController.dialog(self, message: "Are you sure you want to delete the image?") {
            self.imgPhoto.image = UIImage(named: "placeholder")
            self.userImage = nil
            self.imagePlaceholderUsed = true
        }
    
    }
    
    @objc private func btnSaveClicked(sender: UIButton) {
        if chkVisible.isOn {
            DialogViewController.dialog(self, message: "Are you sure you want to upload a public recipe?") {
                self.uploadRecipe(visible: true)
            }
        } else {
            uploadRecipe(visible: false)
        }
    }
    
    private func uploadRecipe(visible: Bool) {
        
        guard let user = User.load() else {
            AlertViewController.alert(title: "Unauthorized", message: "You must be logged in to upload a recipe.", presenting: self)
            return
        }
        
        // Check input validity
        guard !categoryPickerViewDelegate.categories.isEmpty else {
            Toast.makeText(self, message: "Categories list appears to be empty, reloading...", length: .long)
            Category.loadCategories() { categories in
                if let theCategories = categories {
                    self.categoryPickerViewDelegate.categories = theCategories
                    self.pkrCategory.reloadComponent(0)
                    
                    if self.edited, let categoryId = self.recipe.categoryId {
                        // Find the category by id
                        self.pkrCategory.selectRow(categoryId - 1, inComponent: 0, animated: false)
                    }
                }
            }
            return
        }
        
        let recipeName = txtRecipeName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !recipeName.isEmpty else {
            AlertViewController.alert(title: "Invalid Input", message: "The recipe must have a name.", presenting: self)
            return
        }
        
        guard let numServings = Int(txtNumServings.text!) else {
            AlertViewController.alert(title: "Invalid Input", message: "You must specify the number of servings.", presenting: self)
            return
        }
        
        let prepTime = Int(txtPrepTime.text!) ?? 0
        let cookTime = Int(txtCookTime.text!) ?? 0
        
        guard !ingredients.isEmpty && !steps.isEmpty else {
            AlertViewController.alert(title: "Invalid Input", message: "The recipe must have both ingredients and steps.", presenting: self)
            return
        }
        
        // Create recipe object
        recipe.name = recipeName
        recipe.categoryId = categoryPickerViewDelegate.categories[pkrCategory.selectedRow(inComponent: 0)].id
        recipe.numServings = numServings
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.visible = visible
        recipe.ingredients = ingredients
        recipe.steps = steps
        
        // Upload the recipe
        let session = URLSession(configuration: .default, delegate: uploadManager, delegateQueue: nil)
        let url = URL(string: "\(Utils.BASE_URL)/recipes")
        var request = URLRequest(url: url!)
        request.httpMethod = edited ? "PUT" : "POST"
        request.setValue(user.auth, forHTTPHeaderField: "Authorization")
        
        // Convert to JSON
        let dataToSend: Data!
        do {
            let recipeJson = recipe.toDictionary()
            print("Data to send: \(recipeJson)")
            
            dataToSend = try JSONSerialization.data(withJSONObject: recipe.toDictionary(), options: .prettyPrinted)
        } catch {
            AlertViewController.alert(title: "Error", message: "Please try again.", presenting: self)
            return
        }
        
        enableUI(false)
        
        DispatchQueue.global().async {
            
            session.uploadTask(with: request, from: dataToSend) { (data, response, error) in
                
                let responseCode = (response as! HTTPURLResponse).statusCode
                print("Response Code: \(responseCode)")
                guard let theData = data, error == nil && responseCode < 400,
                    let json = try? JSONSerialization.jsonObject(with: theData, options: .allowFragments) as! [String:Any] else {
                    DispatchQueue.main.async {
                        session.finishTasksAndInvalidate()
                        AlertViewController.alert(data: data, presenting: self, defaultMessage: "Failed to upload recipe.")
                        self.enableUI(true)
                    }
                    return
                }
                
                print("Uploaded recipe response: \(json)")
                
                let responseRecipe = Recipe(json: json)
                
                // There's a stored image, but the image was either replaced by a new one or deleted (placeholder shown)
                // Delete the stored image
                if self.recipe.photos.count > 0 && (self.imagePlaceholderUsed || self.userImage != nil) {
                    print("Deleting existing photo...")
                    
                    let url = URL(string: "\(Utils.BASE_URL)/photos/\(self.recipe.photos[0].location)")
                    var request = URLRequest(url: url!)
                    request.httpMethod = "DELETE"
                    request.setValue(user.auth, forHTTPHeaderField: "Authorization")
                    session.dataTask(with: request) { (data, response, error) in
                        guard let _ = data, error == nil, (response as! HTTPURLResponse).statusCode < 400 else {
                            print("Failed to delete photo.")
                            return
                        }
                        print("Photo deleted successfully.")
                        }.resume()
                }
                
                // If there's a selected photo and it doesn't exist in the recipe data, upload it
                if let responseId = responseRecipe.id, let photo = self.userImage {
                    
                    DispatchQueue.main.async {
                        Toast.makeText(self, message: "Uploading photo...", length: .long)
                    }
                    
                    print("Uploading new photo...")
                    
                    // Upload photo and add it to the recipe
                    let encodedPhoto = Photo.convertToBase64(photo)
                    let photoUrl = URL(string: "\(Utils.BASE_URL)/photos/recipe/\(responseId)")
                    var photoRequest = URLRequest(url: photoUrl!)
                    photoRequest.httpMethod = "POST"
                    photoRequest.setValue(user.auth, forHTTPHeaderField: "Authorization")
                    
                    session.uploadTask(with: photoRequest, from: encodedPhoto) { (data, response, error) in
                        
                        let responseCode = (response as! HTTPURLResponse).statusCode
                        print("Photo upload response code: \(responseCode)")
                        guard let data = data, error == nil && responseCode < 400,
                            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any] else {
                            DispatchQueue.main.async {
                                session.finishTasksAndInvalidate()
                                AlertViewController.alert(title: "Error", message: "Failed to upload photo.", presenting: self)
                                self.enableUI(true)
                            }
                            return
                        }
                        
                        print("Photo response: \(json)")
                        
                        let photoData = Photo(json: json["photo"] as! [String:Any])
                        
                        // Add the photo data to the recipe
                        responseRecipe.photos.append(photoData)
                        
                        // Show the recipe
                        DispatchQueue.main.async {
                            session.finishTasksAndInvalidate()
                            self.dismiss(animated: true, completion: nil)
                            self.completionHandler?(responseRecipe, self.listIdx)
                        }
                        
                    }.resume()
                    
                } else {
                    // No need to upload a photo, show recipe
                    
                    print("Not uploading photo")
                    
                    DispatchQueue.main.async {
                        session.finishTasksAndInvalidate()
                        self.dismiss(animated: true, completion: nil)
                        self.completionHandler?(responseRecipe, self.listIdx)
                    }
                }
                
            }.resume()
            
        }
        
    }
    
    @objc private func btnDeleteClicked(sender: UIButton) {
        
        guard edited, let recipeId = recipe.id else { return }
        
        guard let user = User.load() else {
            AlertViewController.alert(title: "Unauthorized", message: "You can't delete this recipe.", presenting: self)
            return
        }
        
        DialogViewController.dialog(self, message: "Are you sure you want to delete the recipe?") {
            
            self.enableUI(false)
            
            let session = URLSession(configuration: .default)
            let url = URL(string: "\(Utils.BASE_URL)/recipes/id/\(recipeId)")
            print("Delete request goes to: \(url!.absoluteString)")
            var request = URLRequest(url: url!)
            request.httpMethod = "DELETE"
            request.setValue(user.auth, forHTTPHeaderField: "Authorization")
            
            DispatchQueue.global().async {
                session.dataTask(with: request) { (data, response, error) in
                    let responseCode = (response as! HTTPURLResponse).statusCode
                    print("Delete recipe response code: \(responseCode)")
                    guard error == nil, responseCode < 400 else {
                        DispatchQueue.main.async {
                            session.finishTasksAndInvalidate()
                            AlertViewController.alert(data: data, presenting: self, defaultMessage: "Failed to delete the recipe.")
                            self.enableUI(true)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        session.finishTasksAndInvalidate()
                        self.dismiss(animated: true) {
                            self.deleteHandler?(self.listIdx)
                        }
                    }
                    
                }.resume()
            }
        }
        
    }
    
    @objc private func btnCancelClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Static Display Method
    
    public static func display(_ presenting: UIViewController, recipe: Recipe? = nil, row: Int? = nil,
                               completionHandler: ((Recipe, Int?) -> ())? = nil, deleteHandler: ((Int?) -> ())? = nil, image: UIImage? = nil) {
        let recipeModifyViewController = RecipeModifyViewController()
        recipeModifyViewController.recipe = recipe
        recipeModifyViewController.listIdx = row
        recipeModifyViewController.completionHandler = completionHandler
        recipeModifyViewController.deleteHandler = deleteHandler
        recipeModifyViewController.defaultImage = image
        presenting.present(recipeModifyViewController, animated: true, completion: nil)
    }
    
    // ImagePickerControllerDelegate Methods
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image: UIImage!
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        } else {
            image = originalImage
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        // An image has been picked by the user, remove the old image
        imgPhoto.image = image
        userImage = image
        imagePlaceholderUsed = false
        btnDeleteImage.isEnabled = true
        
    }
    
    // TableView Methods
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === tblIngredients ? ingredients.count : steps.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier: String!
        var cellTitle: String!
        if tableView === tblIngredients {
            identifier = INGREDIENT_CELL_IDENTIFIER
            let ingredient = ingredients[indexPath.row]
            cellTitle = "\(ingredient.quantity) \(ingredient.unit.description()) of \(ingredient.name!)"
        } else {
            identifier = STEP_CELL_IDENTIFIER
            cellTitle = "\(indexPath.row + 1). \(steps[indexPath.row])"
        }
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        cell!.textLabel?.text = cellTitle
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === tblIngredients {
            IngredientModifyViewController.display(self, ingredient: ingredients[indexPath.row], row: indexPath.row, completionHandler: { (ingredient, index) in
                if let theIndex = index {
                    self.ingredients[theIndex] = ingredient
                    self.tblIngredients.reloadData()
                }
            }, deleteHandler: { index in
                self.ingredients.remove(at: index)
                self.tblIngredients.reloadData()
            })
        } else {
            StepModifyViewController.display(self, step: steps[indexPath.row], row: indexPath.row, completionHandler: { (step, index) in
                if let theIndex = index {
                    self.steps[theIndex] = step
                    self.tblSteps.reloadData()
                }
            }, deleteHandler: { index in
                self.steps.remove(at: index)
                self.tblSteps.reloadData()
            })
        }
    }
    
    // Category Picker View Delegate
    
    fileprivate class CategoryPickerViewDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        
        fileprivate var categories: [Category]
        
        override init() {
            categories = [Category]()
        }
        
        public func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return categories.count
        }
        
        public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return categories[row].name
        }
        
    }
    
    
}
