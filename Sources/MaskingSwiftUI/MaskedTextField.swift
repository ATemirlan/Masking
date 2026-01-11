import SwiftUI
import MaskingCore
import MaskingUIKit
import UIKit

public struct MaskedTextField: UIViewRepresentable {
    public final class Coordinator: NSObject, MaskedTextFieldDelegateObserver {
        var text: Binding<String>
        let mask: Mask
        let delegate: MaskedTextFieldDelegate

        init(text: Binding<String>, mask: Mask) {
            self.text = text
            self.mask = mask
            self.delegate = MaskedTextFieldDelegate(mask: mask)
            super.init()
            self.delegate.setListener(self)
        }

        public func textFieldChanged(_ textField: UITextField) {
            let value = textField.text ?? ""
            if text.wrappedValue != value {
                text.wrappedValue = value
            }
        }

        public func textFieldDidEndEditing(_ textField: UITextField) { }
    }

    private let placeholder: String
    private let mask: Mask
    private var keyboardType: UIKeyboardType
    private var textContentType: UITextContentType?
    
    @Binding private var text: String

    private var configure: (UITextField) -> Void = { _ in }

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        mask: Mask,
        keyboardType: UIKeyboardType = .numberPad,
        textContentType: UITextContentType? = nil,
        configure: @escaping (UITextField) -> Void = { _ in }
    ) {
        self.placeholder = placeholder
        self._text = text
        self.mask = mask
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.configure = configure
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, mask: mask)
    }

    public func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.placeholder = placeholder
        tf.keyboardType = keyboardType
        tf.textContentType = textContentType
        tf.delegate = context.coordinator.delegate
        configure(tf)

        let masked = mask.maskedString(input: text)
        tf.text = masked
        return tf
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        let masked = mask.maskedString(input: text)
        if uiView.text != masked {
            uiView.text = masked
        }
    }
}
