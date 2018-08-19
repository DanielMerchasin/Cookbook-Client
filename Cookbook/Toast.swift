import UIKit

public class Toast {

    public enum Length {
        case long
        case short
    }
    
    public static func makeText(_ presenting: UIViewController, message: String, length: Length) {
        
        let lblToast = UILabel(frame: CGRect(x: presenting.view.frame.width / 2 - 75,
                                             y: presenting.view.frame.height - 100,
                                             width: 150,
                                             height: 35))
        
        lblToast.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        lblToast.textColor = UIColor.white
        lblToast.textAlignment = .center
        lblToast.font = UIFont(name: "Montserrat-Light", size: 12.0)
        lblToast.text = message
        lblToast.alpha = 1.0
        lblToast.layer.cornerRadius = 10
        lblToast.clipsToBounds = true
        presenting.view.addSubview(lblToast)
        
        UIView.animate(withDuration: length == .long ? 4.0 : 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            lblToast.alpha = 0.0
        }, completion: { (isCompleted) in
            lblToast.removeFromSuperview()
        })
        
    }
    
}
