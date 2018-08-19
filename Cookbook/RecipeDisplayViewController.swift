import UIKit

public class RecipeDisplayViewController: UIViewController {
    
    private var recipe: Recipe!
    
    var scrollView: UIScrollView!
    var imgPhoto: UIImageView!
    var btnClose, btnEdit: UIButton!
    
    var imageIdx = 0
    var previousImageIdx = 0
    var previousImageData: Data?
    
    var listIdx: Int?
    var editedHandler: ((Int?) -> ())?
    var deleteHandler: ((Int?) -> ())?
    
    var edited = false
    
    var lblTitle, lblCreated, lblText: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        lblTitle = UILabel(frame: CGRect(x: 10, y: 20, width: view.frame.width - 10 * 2, height: 30))
        lblTitle.textAlignment = .center
        lblTitle.font = .boldSystemFont(ofSize: 20)
        view.addSubview(lblTitle)
        
        scrollView = UIVerticalScrollView(frame: CGRect(x: 0, y: 70, width: view.frame.width, height: view.frame.height - 110))
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        imgPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 300))
        imgPhoto.contentMode = .scaleAspectFit
        scrollView.addSubview(imgPhoto)
        
        lblCreated = UILabel(frame: CGRect(x: 10, y: 320, width: scrollView.frame.width - 10 * 2, height: 30))
        lblCreated.font = UIFont.italicSystemFont(ofSize: 16)
        lblCreated.textAlignment = .center
        scrollView.addSubview(lblCreated)
        
        lblText = UILabel(frame: CGRect(x: 10, y: 360, width: scrollView.frame.width - 10 * 2, height: 30))
        lblText.numberOfLines = 0
        lblText.lineBreakMode = .byWordWrapping
        scrollView.addSubview(lblText)
        
        view.addSubview(scrollView)
        
        btnEdit = UIButton(type: .system)
        btnEdit.frame = CGRect(x: 10, y: view.frame.height - 40, width: view.frame.width / 2 - 10, height: 30)
        btnEdit.setTitle("Edit Recipe", for: .normal)
        btnEdit.addTarget(self, action: #selector(btnEditClicked(sedner:)), for: .touchUpInside)
        view.addSubview(btnEdit)
        
        btnClose = UIButton(type: .system)
        btnClose.setTitle("Close", for: .normal)
        btnClose.setTitleColor(.red, for: .normal)
        btnClose.setTitleColor(.lightGray, for: .disabled)
        btnClose.addTarget(self, action: #selector(btnCloseClicked(sender:)), for: .touchUpInside)
        
        if let user = User.load(), let recipeUserId = recipe.userId, recipeUserId == user.id {
            btnClose.frame = CGRect(x: view.frame.width / 2, y: view.frame.height - 40, width: view.frame.width / 2 - 10, height: 30)
        } else {
            btnEdit.isEnabled = false
            btnEdit.isHidden = true
            btnClose.frame = CGRect(x: 10, y: view.frame.height - 40, width: view.frame.width - 10 * 2, height: 30)
        }
        
        view.addSubview(btnClose)
        
        // Set values
        loadRecipeValues()
        
    }
    
    private func loadRecipeValues() {
        
        lblTitle.text = recipe.name
        
        if let username = recipe.username, let uploadTime = recipe.uploadTime {
            lblCreated.text = "Created by \(username) on \(Date(milliseconds: uploadTime).format())"
        }
        
        let text: NSMutableString = ""
        
        if let category = recipe.categoryName {
            text.append("Category: \(category)\n")
        }
        
        if let numServings = recipe.numServings {
            text.append("Number of Servings: \(numServings)\n")
        }
        
        if let prepTime = recipe.prepTime {
            text.append("Preparation Time: \(prepTime)\n")
        }
        
        if let cookTime = recipe.cookTime {
            text.append("Cooking Time: \(cookTime)\n")
        }
        
        if !recipe.ingredients.isEmpty {
            text.append("\nIngredients:\n")
            for ingredient in recipe.ingredients {
                if let name = ingredient.name {
                    text.append("\(ingredient.quantity) \(ingredient.unit.description()) - \(name)\n")
                }
            }
        }
        
        if !recipe.steps.isEmpty {
            text.append("\nSteps\n")
            for i in 0..<recipe.steps.count {
                text.append("\(i + 1). \(recipe.steps[i])\n")
            }
        }
        
        lblText.text = text as String
        
        // Load the photo
        Utils.loadPhoto(forRecipe: recipe, handleThumbnail: { (thumbnail) in
            if let theThumbnail = thumbnail {
                self.imgPhoto.image = theThumbnail
            }
        }, handleFullSizeImage: { (image, isPlaceholder) in
            if let theImage = image {
                self.imgPhoto.image = theImage
            }
        })
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fitScrollViewContentSize()
    }
    
    private func fitScrollViewContentSize() {
        let maxSize = CGSize(width: scrollView.frame.width - 10 * 2, height: CGFloat.greatestFiniteMagnitude)
        let textSize = lblText.attributedText!.boundingRect(with: maxSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
        lblText.frame = CGRect(x: 10, y: 360, width: scrollView.frame.width - 10 * 2, height: textSize.height)
        scrollView.contentSize = CGSize(width: view.frame.width, height: 370 + lblText.frame.height)
    }
    
    @objc private func btnEditClicked(sedner: UIButton) {
        
        RecipeModifyViewController.display(self, recipe: recipe, row: listIdx, completionHandler: { recipe, index in
            //Load the edited recipe
            self.edited = true
            self.recipe = recipe
            self.loadRecipeValues()
            self.fitScrollViewContentSize()
        }, deleteHandler: { index in
            self.dismiss(animated: true, completion: nil)
            self.deleteHandler?(index)
        })
        
    }
    
    @objc private func btnCloseClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if edited {
            editedHandler?(listIdx)
        }
    }
    
    public static func display(_ presenting: UIViewController, recipe: Recipe, row: Int? = nil, edited: Bool = false,
                               editedHandler: ((Int?) -> ())? = nil, deleteHandler: ((Int?) -> ())? = nil) {
        let recipeDisplayViewController = RecipeDisplayViewController()
        recipeDisplayViewController.recipe = recipe
        recipeDisplayViewController.listIdx = row
        recipeDisplayViewController.edited = edited
        recipeDisplayViewController.editedHandler = editedHandler
        recipeDisplayViewController.deleteHandler = deleteHandler
        presenting.present(recipeDisplayViewController, animated: true, completion: nil)
    }
    
}
