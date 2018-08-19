import UIKit

public class StepModifyViewController: UIViewController {
    
    var handler: ((String, Int?) -> ())?
    var deleteHandler: ((Int) -> ())?
    var step: String!
    var listIdx: Int?
    
    var txtStep: UITextView!
    
    public override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: view.frame.height * 0.4))
        container.backgroundColor = .white
        container.center = view.center
        container.layer.cornerRadius = 10.0
        
        txtStep = UITextView(frame: CGRect(x: 10, y: 10, width: container.frame.width - 10 * 2, height: container.frame.height - 120))
        txtStep.font = UIFont.systemFont(ofSize: 18)
        container.addSubview(txtStep)
        
        let btnOk = UIButton(type: .system)
        btnOk.frame = CGRect(x: 10, y: container.frame.height - 100, width: container.frame.width - 10 * 2, height: 30)
        btnOk.setTitle("OK", for: .normal)
        btnOk.addTarget(self, action: #selector(btnOkClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnOk)
        
        let btnDelete = UIButton(type: .system)
        btnDelete.frame = CGRect(x: 10, y: container.frame.height - 70, width: container.frame.width - 10 * 2, height: 30)
        btnDelete.setTitle("Delete Step", for: .normal)
        btnDelete.addTarget(self, action: #selector(btnDeleteClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnDelete)
        
        let btnCancel = UIButton(type: .system)
        btnCancel.frame = CGRect(x: 10, y: container.frame.height - 40, width: container.frame.width - 10 * 2, height: 30)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.red, for: .normal)
        btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnCancel)
        
        view.addSubview(container)
        
        if step != nil {
            txtStep.text = step
            btnDelete.isEnabled = true
        } else {
            btnDelete.isEnabled = false
        }
        
    }
    
    @objc private func btnOkClicked(sender: UIButton) {
        
        let trimmedStep = txtStep.text!.trimmingCharacters(in: .whitespaces)
        
        // Check input validity
        guard !trimmedStep.isEmpty else {
            AlertViewController.alert(title: "Invalid Input", message: "The field can't be empty", presenting: self)
            return
        }
        
        self.dismiss(animated: true, completion: nil)
        handler?(trimmedStep, listIdx)
        
    }
    
    @objc private func btnDeleteClicked(sender: UIButton) {
        
        guard let theIndex = listIdx else { return }
        
        DialogViewController.dialog(self, message: "Are you sure you want to delete this step?") {
            self.dismiss(animated: true, completion: nil)
            self.deleteHandler?(theIndex)
        }
    }
    
    @objc private func btnCancelClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func display(_ presenting: UIViewController, step: String? = nil, row: Int? = nil,
                               completionHandler: ((String, Int?) -> ())? = nil, deleteHandler: ((Int) -> ())? = nil) {
        let stepModifyViewController = StepModifyViewController()
        stepModifyViewController.modalPresentationStyle = .overCurrentContext
        stepModifyViewController.step = step
        stepModifyViewController.listIdx = row
        stepModifyViewController.handler = completionHandler
        stepModifyViewController.deleteHandler = deleteHandler
        presenting.present(stepModifyViewController, animated: true, completion: nil)
    }
    
}
