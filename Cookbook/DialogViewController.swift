import UIKit

public class DialogViewController: UIViewController {
    
    var message: String!
    var handler: (() -> ())?
    
    public override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: view.frame.height * 0.3))
        container.backgroundColor = UIColor.white
        container.center = view.center
        container.layer.cornerRadius = 10.0
        
        let lblMessage = UILabel(frame: CGRect(x: 10, y: 30, width: container.frame.width - 10 * 2, height: 100))
        lblMessage.text = message
        lblMessage.textAlignment = .center
        lblMessage.lineBreakMode = .byWordWrapping
        lblMessage.numberOfLines = 4
        container.addSubview(lblMessage)
        
        let btnYes = UIButton(type: .system)
        btnYes.frame = CGRect(x: 20, y: container.frame.height - 40, width: container.frame.width / 2 - 20, height: 30)
        btnYes.setTitle("Yes", for: .normal)
        btnYes.addTarget(self, action: #selector(btnYesClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnYes)
        
        let btnNo = UIButton(type: .system)
        btnNo.frame = CGRect(x: container.frame.width / 2, y: container.frame.height - 40, width: container.frame.width / 2 - 20, height: 30)
        btnNo.setTitle("No", for: .normal)
        btnNo.setTitleColor(.red, for: .normal)
        btnNo.addTarget(self, action: #selector(btnNoClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnNo)
        
        view.addSubview(container)
        
    }
    
    @objc private func btnYesClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        handler?()
    }
    
    @objc private func btnNoClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func dialog(_ presenting: UIViewController, message: String, handler: (() -> ())? = nil) {
        let dialogViewController = DialogViewController()
        dialogViewController.modalPresentationStyle = .overCurrentContext
        dialogViewController.message = message
        dialogViewController.handler = handler
        presenting.present(dialogViewController, animated: true, completion: nil)
    }
    
}
