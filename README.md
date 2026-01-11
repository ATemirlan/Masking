# Masking

A lightweight, dependency-free masking library for Swift with **Core**, **UIKit**, and **SwiftUI** support.

This package is split into modules:

- **MaskingCore** - pure Swift/Foundation masking logic
- **MaskingUIKit** - `UITextFieldDelegate` adapter
- **MaskingSwiftUI** - SwiftUI wrapper built on top of the UIKit adapter
- **Masking** - umbrella module that re-exports everything for a single import

## Features

- Mask expressions with placeholders:
  - `D` - digit (`0...9`)
  - `L` - letter (Unicode letters)
  - `C` - condition character (allowed values provided via `conditions`)
- Static characters in expressions (like `+`, `(`, `)`, `-`) are inserted automatically
- Optional `template` support (can force static characters at specific positions)
- Two invalid input behaviors via `InvalidInputPolicy`:
  - `.ignore` - **skips invalid characters** and tries to fill the same placeholder with the next input char (recommended)
  - `.consume` - **invalid characters consume placeholders** (strict mode)
- UIKit & SwiftUI ready

## Requirements

- iOS 13+
- Swift 5.9+

## Installation (Swift Package Manager)

### Xcode
1. **File → Add Packages...**
2. Paste the repository URL
3. Select a product:
   - **Masking** (recommended) - one import gives Core + UIKit + SwiftUI
   - or choose specific modules: **MaskingCore**, **MaskingUIKit**, **MaskingSwiftUI**

## Quick Start (Recommended)

```swift
import Masking
```

The umbrella module re-exports:

- `MaskingCore`
- `MaskingUIKit`
- `MaskingSwiftUI`

So you can use everything with a single import.

## MaskingCore

### Creating a mask

```swift
import MaskingCore

let mask = Mask(expression: "LL-DD")

mask.maskedString(input: "aa12") // "aa-12"
mask.maskedString(input: "ab1")  // "ab-1"
```

### InvalidInputPolicy

#### `.ignore` (recommended)

Invalid characters are skipped and **do not consume** mask slots:

```swift
import MaskingCore

let m = Mask(invalidInputPolicy: .ignore, expression: "LL-DD")
m.maskedString(input: "ab_12") // "ab-12"
```

#### `.consume`

Invalid characters **consume** mask slots:

```swift
import MaskingCore

let m = Mask(invalidInputPolicy: .consume, expression: "LL-DD")
m.maskedString(input: "ab_12") // "ab-1"
```

> Note about `.ignore`: placeholders are not skipped.  
> Example: `Mask(expression: "LL-DD")` requires 2 letters first.  
> So `"1212"` results in an empty string because no `L` placeholders can be filled.

### Condition placeholder (`C`)

`C` accepts only characters listed in `conditions`.

```swift
import MaskingCore

let m = Mask(
    invalidInputPolicy: .ignore,
    expression: "C-DD",
    conditions: ["7,8"]
)

m.maskedString(input: "712") // "7-12"
m.maskedString(input: "812") // "8-12"
```

Conditions can include spaces:

```swift
let m = Mask(expression: "C-DD", conditions: ["7, 8"])
m.maskedString(input: "812") // "8-12"
```

### Template

You can pass a template string with the same length as `expression`.
If the template character at a position is **static** (not `D/L/C`), it overrides the output at that position.

Example:

```swift
import MaskingCore

let phone = Mask(
    invalidInputPolicy: .ignore,
    expression: "+C(DDD)-DDD-DD-DD",
    conditions: ["7,8"],
    template: "+7(DDD)-DDD-DD-DD"
)

phone.maskedString(input: "77011234567") // "+7(701)-123-45-67"
phone.maskedString(input: "87011234567") // "+7(701)-123-45-67"
```

## MaskingUIKit

### UITextFieldDelegate

```swift
import UIKit
import MaskingUIKit
import MaskingCore

final class PhoneVC: UIViewController {
    private let textField = UITextField()

    private lazy var maskedDelegate = MaskedTextFieldDelegate(
        mask: Mask(
            invalidInputPolicy: .ignore,
            expression: "+C(DDD)-DDD-DD-DD",
            conditions: ["7,8"],
            template: "+7(DDD)-DDD-DD-DD"
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.keyboardType = .numberPad
        textField.delegate = maskedDelegate
    }
}
```

### Observing changes

```swift
import UIKit
import MaskingUIKit

final class PhoneObserver: MaskedTextFieldDelegateObserver {
    func textFieldChanged(_ textField: UITextField) {
        // handle live changes
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // handle end editing
    }
}
```

Attach observer:

```swift
maskedDelegate.observer = PhoneObserver()
```

> Observer methods have default empty implementations, so you can implement only what you need.

## MaskingSwiftUI

### MaskedTextField

```swift
import SwiftUI
import MaskingSwiftUI
import MaskingCore

struct ContentView: View {
    @State private var phone = ""

    var body: some View {
        MaskedTextField(
            "Phone",
            text: $phone,
            mask: Mask(
                invalidInputPolicy: .ignore,
                expression: "+C(DDD)-DDD-DD-DD",
                conditions: ["7,8"],
                template: "+7(DDD)-DDD-DD-DD"
            )
        )
        .padding()
    }
}
```

## Testing

This repository includes separate test suites for both policies:

- `MaskingConsumeCoreTests`
- `MaskingIgnoreCoreTests`
