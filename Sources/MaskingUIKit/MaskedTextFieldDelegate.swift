import UIKit
import MaskingCore

public final class MaskedTextFieldDelegate: NSObject, UITextFieldDelegate {
    private let mask: Mask
    
    private weak var observer: MaskedTextFieldDelegateObserver?
    
    public init(mask: Mask, observer: MaskedTextFieldDelegateObserver? = nil) {
        self.mask = mask
        self.observer = observer
    }
    
    public func setListener(_ observer: MaskedTextFieldDelegateObserver) {
        self.observer = observer
    }
    
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text as NSString?
        let updatedText = currentText?.replacingCharacters(in: range, with: string) ?? ""
        
        let maskedText = mask.maskedString(input: updatedText)
        
        if maskedText.count > mask.limit {
            return false
        }

        textField.text = maskedText
        observer?.textFieldChanged(textField)
        
        return false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        observer?.textFieldDidEndEditing(textField)
    }
}
