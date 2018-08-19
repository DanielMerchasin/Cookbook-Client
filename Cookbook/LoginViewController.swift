import UIKit

public class LoginViewController: UIViewController {
    
    var handler: ((String) -> Void)?
    var txtUsername, txtPassword: UITextField!
    var btnLogin, btnSignUp, btnCancel: UIButton!
    
    public override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: view.frame.height * 0.4))
        container.backgroundColor = UIColor.white
        container.center = view.center
        container.layer.cornerRadius = 10.0
        
        let lblTitle = UILabel(frame: CGRect(x: 10, y: 10, width: container.frame.width - 10 * 2, height: 30))
        lblTitle.text = "LOG IN"
        lblTitle.textAlignment = .center
        lblTitle.font = UIFont.boldSystemFont(ofSize: 20)
        container.addSubview(lblTitle)
        
        txtUsername = UITextField(frame: CGRect(x: 10, y: 60, width: container.frame.width - 10 * 2, height: 30))
        txtUsername.placeholder = "Username"
        txtUsername.textAlignment = .center
        container.addSubview(txtUsername)
        
        txtPassword = UITextField(frame: CGRect(x: 10, y: 100, width: container.frame.width - 10 * 2, height: 30))
        txtPassword.placeholder = "Password"
        txtPassword.textAlignment = .center
        txtPassword.isSecureTextEntry = true
        container.addSubview(txtPassword)
        
        btnLogin = UIButton(type: .system)
        btnLogin.frame = CGRect(x: 10, y: container.frame.height - 120, width: container.frame.width - 10 * 2, height: 30)
        btnLogin.setTitle("Log In", for: .normal)
        btnLogin.addTarget(self, action: #selector(btnLoginClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnLogin)
        
        btnSignUp = UIButton(type: .system)
        btnSignUp.frame = CGRect(x: 10, y: container.frame.height - 80, width: container.frame.width - 10 * 2, height: 30)
        btnSignUp.setTitle("Sign Up", for: .normal)
        btnSignUp.addTarget(self, action: #selector(btnSignUpClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnSignUp)
        
        btnCancel = UIButton(type: .system)
        btnCancel.frame = CGRect(x: 10, y: container.frame.height - 40, width: container.frame.width - 10 * 2, height: 30)
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(.red, for: .normal)
        btnCancel.addTarget(self, action: #selector(btnCancelClicked(sender:)), for: .touchUpInside)
        container.addSubview(btnCancel)
        
        view.addSubview(container)
        
    }
    
    private func enableUI(_ enable: Bool) {
        btnLogin.isEnabled = enable
        btnSignUp.isEnabled = enable
        btnCancel.isEnabled = enable
    }
    
    @objc private func btnLoginClicked(sender: UIButton) {
        
        // Check validity of input
        if txtUsername.text!.isEmpty || txtPassword.text!.isEmpty {
            AlertViewController.alert(title: "Invalid input", message: "Please enter your username and password.", presenting: self, handler: nil)
            return
        }
        
        // Disable UI
        enableUI(false)
        
        let session = URLSession(configuration: .default)
        let url = URL(string: "\(Utils.BASE_URL)/users")
        var request = URLRequest(url: url!)
        request.setValue(User.createAuthHeaderForUser(txtUsername.text!, password: txtPassword.text!), forHTTPHeaderField: "Authorization")
        
        DispatchQueue.global().async {
            session.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    do {
                        if (response as! HTTPURLResponse!).statusCode < 400 {
                            // OK
                            
                            if let theData = data {
                                
                                let user = try User.save(data: theData)
                                
                                DispatchQueue.main.async {
                                    // Handle successful login
                                    session.finishTasksAndInvalidate()
                                    self.dismiss(animated: true, completion: nil)
                                    self.handler?(user.username)
                                }
                                return
                            }
                        }
                    } catch {}
                }
                
                DispatchQueue.main.async {
                    AlertViewController.alert(data: data, presenting: self, handler: nil)
                    self.enableUI(true)
                    session.finishTasksAndInvalidate()
                }
            }.resume()
        }
        
    }
    
    @objc private func btnSignUpClicked(sender: UIButton) {
        // Handle transition to register view controller
        RegisterViewController.display(self) { (username) in
            self.dismiss(animated: true, completion: nil)
            if let theHandler = self.handler {
                theHandler(username)
            }
        }
    }
    
    @objc private func btnCancelClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func display(_ presenting: UIViewController, handler: ((String) -> Void)?) {
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .overCurrentContext
        loginViewController.handler = handler
        presenting.present(loginViewController, animated: true, completion: nil)
    }
    
}
