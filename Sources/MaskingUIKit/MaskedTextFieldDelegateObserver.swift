import UIKit

public protocol MaskedTextFieldDelegateObserver: AnyObject {
    func textFieldChanged(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
}

public extension MaskedTextFieldDelegateObserver {
    func textFieldChanged(_ textField: UITextField) {}
    func textFieldDidEndEditing(_ textField: UITextField) {}
}
