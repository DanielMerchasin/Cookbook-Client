import UIKit

public class IngredientModifyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var handler: ((Ingredient, Int?) -> ())?
    var deleteHandler: ((Int) -> ())?
    var ingredient: Ingredient!
    var listIdx: Int?
    
    var btnDelete: UIButton!
    var pkrUnits: UIPickerView!
    var txtName, txtAmount: UITextField!
    
    public override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: view.frame.height * 0.5))
        container.backgroundColor = .white
        container.center = view.center
        container.layer.cornerRadius = 10.0
        
        txtName = UITextField(frame: CGRect(x: 10, y: 10, width: container.frame.width - 10 * 2, height: 30))
        txtName.placeholder = "Ingredient name"
        txtName.textAlignment = .center
        container.addSubview(txtName)
        
        txtAmount = UITextField(frame: CGRect(x: 10, y: 50, width: container.frame.width - 10 * 2, height: 30))
        txtAmount.placeholder = "Amount"
        txtAmount.textAlignment = .center
        txtAmount.delegate = NumberTextFieldDelegate()
        txtAmount.keyboardType = .numberPad
        container.addSubview(txtAmount)
        
        let lblUnitsTitle = UILabel(frame: CGRect(x: 10, y: 90, width: container.frame.width - 10 * 2, height: 30))
        lblUnitsTitle.text = "Select Units"
        lblUnitsTitle.textAlignment = .center
        container.addSubview(lblUnitsTitle)
        
        pkrUnits = UIPickerView(frame: CGRect(x: 10, y: 120, width: container.frame.width - 10 * 2, height: 100))
        pkrUnits.delegate = self
        pkrUnits.dataSource = self
        container.addSubview(pkrUnits)
        
        let btnOk = UIButton(type: .system)
        btnOk.frame = CGRect(x: 10, y: container.frame.height - 100, width: container.frame.width - 10 * 2, height: 30)
        btnOk.setTitle("OK", for: .normal)
        btnOk.addTarget(self, action: #selector(btnOkClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnOk)
        
        let btnDelete = UIButton(type: .system)
        btnDelete.frame = CGRect(x: 10, y: container.frame.height - 70, width: container.frame.width - 10 * 2, height: 30)
        btnDelete.setTitle("Delete Ingredient", for: .normal)
        btnDelete.addTarget(self, action: #selector(btnDeleteClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnDelete)
        
        let btnCancel = UIButton(type: .system)
        btnCancel.frame = CGRect(x: 10, y: container.frame.height - 40, width: container.frame.width - 10 * 2, height: 30)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.red, for: .normal)
        btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnCancel)
        
        view.addSubview(container)
        
        if ingredient != nil {
            txtName.text = ingredient.name ?? ""
            txtAmount.text = "\(ingredient.quantity)"
            pkrUnits.selectRow(ingredient.unit.ordinal(), inComponent: 0, animated: false)
            btnDelete.isEnabled = true
        } else {
            ingredient = Ingredient()
            btnDelete.isEnabled = false
        }
        
    }
    
    @objc private func btnOkClicked(sender: UIButton) {
        
        let trimmedName = txtName.text!.trimmingCharacters(in: .whitespaces)
        
        guard !trimmedName.isEmpty && !txtAmount.text!.isEmpty else {
            AlertViewController.alert(title: "Invalid Input", message: "The fields can't be empty", presenting: self)
            return
        }
        
        // Check input validity
        guard let amount = Double(txtAmount.text!) else {
            AlertViewController.alert(title: "Invalid Input", message: "The amount field must have a numeric values", presenting: self)
            return
        }
        
        // Build the ingredient
        ingredient.name = trimmedName
        ingredient.quantity = amount
        ingredient.unit = MeasurementUnit.values()[pkrUnits.selectedRow(inComponent: 0)]
        
        self.dismiss(animated: true, completion: nil)
        handler?(ingredient, listIdx)
    }
    
    @objc private func btnDeleteClicked(sender: UIButton) {
        
        guard let theIndex = listIdx else { return }
        
        DialogViewController.dialog(self, message: "Are you sure you want to delete this ingredient?") {
            self.dismiss(animated: true, completion: nil)
            self.deleteHandler?(theIndex)
        }
        
    }
    
    @objc private func btnCancelClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func display(_ presenting: UIViewController, ingredient: Ingredient? = nil, row: Int? = nil,
                               completionHandler: ((Ingredient, Int?) -> ())? = nil, deleteHandler: ((Int) -> ())? = nil) {
        let ingredientModifyViewController = IngredientModifyViewController()
        ingredientModifyViewController.modalPresentationStyle = .overCurrentContext
        ingredientModifyViewController.ingredient = ingredient
        ingredientModifyViewController.listIdx = row
        ingredientModifyViewController.handler = completionHandler
        ingredientModifyViewController.deleteHandler = deleteHandler
        presenting.present(ingredientModifyViewController, animated: true, completion: nil)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MeasurementUnit.values().count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return MeasurementUnit.values()[row].description()
    }
    
}

