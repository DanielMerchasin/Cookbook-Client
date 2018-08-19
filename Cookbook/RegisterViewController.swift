import UIKit

public class RegisterViewController: UIViewController {
    
    var handler: ((String) -> ())?
    var txtUsername, txtPassword, txtConfirmPassword: UITextField!
    var btnSignUp, btnCancel: UIButton!
    
    public override func viewDidLoad() {
        
        view.backgroundColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.3)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: view.frame.height * 0.4))
        container.backgroundColor = UIColor.white
        container.center = view.center
        container.layer.cornerRadius = 10.0
        
        let lblTitle = UILabel(frame: CGRect(x: 10, y: 10, width: container.frame.width - 10 * 2, height: 30))
        lblTitle.text = "SIGN UP"
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
        
        txtConfirmPassword = UITextField(frame: CGRect(x: 10, y: 140, width: container.frame.width - 10 * 2, height: 30))
        txtConfirmPassword.placeholder = "Confirm Password"
        txtConfirmPassword.textAlignment = .center
        txtConfirmPassword.isSecureTextEntry = true
        container.addSubview(txtConfirmPassword)
        
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
        txtUsername.isEnabled = enable
        txtPassword.isEnabled = enable
        txtConfirmPassword.isEnabled = enable
        btnSignUp.isEnabled = enable
        btnCancel.isEnabled = enable
    }
    
    @objc private func btnSignUpClicked(sender: UIButton) {
        
        let username = txtUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = txtPassword.text!
        
        // Check validity of input
        guard !username.isEmpty && !password.isEmpty else {
            AlertViewController.alert(title: "Invalid input", message: "Please enter a username and a password.", presenting: self, handler: nil)
            return
        }
        
        guard password == txtConfirmPassword.text! else {
            AlertViewController.alert(title: "Invalid input", message: "Passwords don't match!", presenting: self, handler: nil)
            return
        }
        
        let session = URLSession(configuration: .default)
        let url = URL(string: "\(Utils.BASE_URL)/users/register")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        // Construct JSONObject from user input
        let dataToSend: Data!
        do {
            let dataAsJSON = [
                "username": username,
                "password": password
            ]
            
            print(dataAsJSON)
            
            dataToSend = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        } catch {
            AlertViewController.alert(title: "Invalid input", message: "An error has occurred! Please try again.", presenting: self, handler: nil)
            return
        }
        
        // Disable UI
        enableUI(false)
        
        DispatchQueue.global().async {
            session.uploadTask(with: request, from: dataToSend) { (data, response, error) in
                if error == nil, let theData = data, (response as! HTTPURLResponse!).statusCode < 400 {
                    do {
                        
                        let user = try User.save(data: theData)
                        
                        DispatchQueue.main.async {
                            // Handle successful sign up
                            session.finishTasksAndInvalidate()
                            self.dismiss(animated: true, completion: nil)
                            self.handler?(user.username)
                        }
                        return
                    } catch {}
                }
                
                DispatchQueue.main.async {
                    session.finishTasksAndInvalidate()
                    AlertViewController.alert(data: data, presenting: self, handler: nil)
                    self.enableUI(true)
                }
            }.resume()
        }
        
    }
    
    @objc private func btnCancelClicked(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public static func display(_ presenting: UIViewController, handler: ((String) -> ())?) {
        let registerViewController = RegisterViewController()
        registerViewController.modalPresentationStyle = .overCurrentContext
        registerViewController.handler = handler
        presenting.present(registerViewController, animated: true, completion: nil)
    }
    
}
