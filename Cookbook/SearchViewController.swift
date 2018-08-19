import UIKit

public class SearchViewController: UIViewController {
    
    var txtQuery, txtMaxTime: UITextField!
    var btnSearch, btnCancel: UIButton!
    var pkrCategory, pkrSort: UIPickerView!
    
    private var pkrCategoryDelegate: CategoryPickerViewDelegate!
    private var pkrSortDelegate: SortPickerViewDelegate!
    
    var searchHandler: ((String) -> ())?
    
    public override func viewDidLoad() {
        
        view.backgroundColor = UIColor.white
        
        let lblTitle = UILabel(frame: CGRect(x: 10, y: 20, width: view.frame.width - 10 * 2, height: 30))
        lblTitle.text = "SEARCH"
        lblTitle.textAlignment = .center
        lblTitle.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(lblTitle)
        
        txtQuery = UITextField(frame: CGRect(x: 10, y: 70, width: view.frame.width - 10 * 2, height: 30))
        txtQuery.placeholder = "What do you feel like cooking?..."
        txtQuery.textAlignment = .center
        view.addSubview(txtQuery)
        
        txtMaxTime = UITextField(frame: CGRect(x: 10, y: 110, width: view.frame.width - 10 * 2, height: 30))
        txtMaxTime.placeholder = "How much time you got? (in minutes)"
        txtMaxTime.textAlignment = .center
        txtMaxTime.delegate = NumberTextFieldDelegate()
        txtMaxTime.keyboardType = .numberPad
        view.addSubview(txtMaxTime)
        
        let lblCategory = UILabel(frame: CGRect(x: 10, y: 150, width: view.frame.width - 10 * 2, height: 30))
        lblCategory.text = "Select Category"
        lblCategory.textAlignment = .center
        view.addSubview(lblCategory)
        
        pkrCategory = UIPickerView(frame: CGRect(x: 10, y: 180, width: view.frame.width - 10 * 2, height: 100))
        pkrCategoryDelegate = CategoryPickerViewDelegate()
        pkrCategory.delegate = pkrCategoryDelegate
        pkrCategory.dataSource = pkrCategoryDelegate
        view.addSubview(pkrCategory)
        
        let lblSort = UILabel(frame: CGRect(x: 10, y: 290, width: view.frame.width - 10 * 2, height: 30))
        lblSort.text = "Sort By"
        lblSort.textAlignment = .center
        view.addSubview(lblSort)
        
        pkrSort = UIPickerView(frame: CGRect(x: 10, y: 320, width: view.frame.width - 10 * 2, height: 100))
        pkrSortDelegate = SortPickerViewDelegate()
        pkrSort.delegate = pkrSortDelegate
        pkrSort.dataSource = pkrSortDelegate
        view.addSubview(pkrSort)
        
        btnSearch = UIButton(type: .system)
        btnSearch.frame = CGRect(x: 0, y: view.frame.height - 80, width: view.frame.width / 2, height: 80)
        btnSearch.setTitle("Search", for: .normal)
        btnSearch.addTarget(self, action: #selector(btnSearchClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnSearch)
        
        btnCancel = UIButton(type: .system)
        btnCancel.frame = CGRect(x: view.frame.width / 2, y: view.frame.height - 80, width: view.frame.width / 2, height: 80)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
        view.addSubview(btnCancel)
        
        // Load the categories to the pickerView
        Category.loadCategories { categories in
            if let theCategories = categories {
                self.pkrCategoryDelegate.categories.append(contentsOf: theCategories)
                self.pkrCategory.reloadComponent(0)
            }
        }
    }
    
    @objc private func btnSearchClicked(sender: UIButton) {
        
        // Check input validity
        guard let maxTime = txtMaxTime.text!.isEmpty ? 0 : Int(txtMaxTime.text!) else {
            AlertViewController.alert(title: "Invalid Input", message: "Please enter a numeric value in the time field", presenting: self, handler: nil)
            return
        }
        
        // Convert all parameters to string
        
        var result = "&maxTime=\(maxTime)&sort=\(pkrSortDelegate.sortMethods[pkrSort.selectedRow(inComponent: 0)].param)"
        
        let catId = pkrCategoryDelegate.categories[pkrCategory.selectedRow(inComponent: 0)].id
        if catId != 0 {
            result.append("&cat_id=\(catId)")
        }
        
        if !txtQuery.text!.isEmpty {
            result.append("&q=\(txtQuery.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")
        }
        
        print("Search parameters: \(result)")
        
        self.dismiss(animated: true, completion: nil)
        searchHandler?(result)
        
    }
    
    @objc private func btnCancelClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func display(_ presenting: UIViewController, searchHandler handler: ((String) -> ())?) {
        let searchViewController = SearchViewController()
        searchViewController.searchHandler = handler
        presenting.present(searchViewController, animated: true, completion: nil)
    }

    fileprivate class CategoryPickerViewDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        
        fileprivate var categories: [Category]
        
        override init() {
            categories = [Category]()
            categories.append(Category(id: 0, name: "All Categories"))
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
    
    fileprivate class SortPickerViewDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        
        fileprivate class SortMethod {
            
            var name: String
            var param: String
            
            init(name: String, param: String) {
                self.name = name
                self.param = param
            }
        }
        
        fileprivate var sortMethods: [SortMethod]
        
        override init() {
            sortMethods = [SortMethod]()
//            sortMethods.append(SortMethod(name: "Rating", param: ""))
            sortMethods.append(SortMethod(name: "Latest", param: "latest"))
            sortMethods.append(SortMethod(name: "Preparation Time", param: "prep_time"))
            sortMethods.append(SortMethod(name: "Cooking Time", param: "cook_time"))
            sortMethods.append(SortMethod(name: "Total Time", param: "total_time"))
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return sortMethods.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return sortMethods[row].name
        }
        
    }

}


