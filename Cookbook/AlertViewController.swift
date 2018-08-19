import UIKit

public class AlertViewController: UIViewController {
    
    var messageTitle: String?
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
        
        if let theMessageTitle = messageTitle {
            lblMessage.frame.offsetBy(dx: 0, dy: 30)
            
            let lblTitle = UILabel(frame: CGRect(x: 10, y: 10, width: container.frame.width - 10 * 2, height: 30))
            lblTitle.text = theMessageTitle
            lblTitle.textAlignment = .center
            lblTitle.font = UIFont.boldSystemFont(ofSize: 20)
            container.addSubview(lblTitle)
        }
        
        let btnOk = UIButton(type: .system)
        btnOk.frame = CGRect(x: 20, y: container.frame.height - 40, width: container.frame.width - 20 * 2, height: 30)
        btnOk.setTitle("OK", for: .normal)
        btnOk.addTarget(self, action: #selector(btnOkClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnOk)
        
        view.addSubview(container)
    }
    
    @objc private func btnOkClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        handler?()
    }
    
    public static func alert(title: String?, message: String, presenting: UIViewController, handler: (() -> ())? = nil) {
        let alertViewController = AlertViewController()
        alertViewController.modalPresentationStyle = .overCurrentContext
        alertViewController.messageTitle = title
        alertViewController.message = message
        alertViewController.handler = handler
        presenting.present(alertViewController, animated: true, completion: nil)
    }
    
    public static func alert(data: Data?, presenting: UIViewController, defaultMessage: String = "An error has occurred, please try again.", handler: (() -> ())? = nil) {
        
        guard let theData = data, 
            let json = try? JSONSerialization.jsonObject(with: theData, options: .allowFragments) as! [String:Any],
            let message = json["message"] as? String else {
                AlertViewController.alert(title: "Error", message: defaultMessage, presenting: presenting, handler: handler)
                return
        }
        
        print("Message: \(message)")
        AlertViewController.alert(title: "Error", message: message, presenting: presenting, handler: handler)
    }
    
}
