import UIKit

public class UIVerticalScrollView: UIScrollView {
    
    public override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        let newOffset = CGPoint(x: 0, y: contentOffset.y)
        
        if newOffset.y > self.contentOffset.y {
            super.setContentOffset(newOffset, animated: animated)
        }
    }
    
}

public class NumberTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedChars = CharacterSet(charactersIn: "1234567890")
        let charSet = CharacterSet(charactersIn: string)
        return allowedChars.isSuperset(of: charSet)
    }
    
}
