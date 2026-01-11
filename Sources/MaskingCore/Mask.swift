import Foundation

public struct Mask {
    private let invalidInputPolicy: InvalidInputPolicy
    private let expression: String
    private let template: String?
    private let conditions: [String]
    
    public var limit: Int {
        return expression.count
    }
    
    public init(
        invalidInputPolicy: InvalidInputPolicy = .ignore,
        expression: String,
        conditions: [String] = [],
        template: String? = nil
    ) {
        self.invalidInputPolicy = invalidInputPolicy
        self.expression = expression
        self.conditions = conditions
        
        if template?.count == expression.count {
            self.template = template
        } else {
            self.template = nil
        }
    }
    
    public func maskedString(input: String) -> String {
        switch invalidInputPolicy {
        case .ignore:
            return maskIgnoringInvalid(input: input)
        case .consume:
            return maskConsumingInvalid(input: input)
        }
    }
    
    private func maskIgnoringInvalid(input: String) -> String {
        var result = ""
        var segmentString = ""
        
        var inputIndex = input.startIndex
        var conditionIndex = 0
        
        var expIndex = expression.startIndex
        var i = 0 // позиция в expression для доступа к template
        
        func templateCharacter(at i: Int, fallback: Character) -> Character {
            guard let template, i < template.count else {
                return fallback
            }
            
            let tIndex = template.index(template.startIndex, offsetBy: i)
            
            let tChar = template[tIndex]
            // Если в template на этой позиции стоит НЕ D/L/C — это статический символ, используем его
            if CharType(tChar) == nil {
                return tChar
            }
            return fallback
        }
        
        func updateSegment(with ch: Character) {
            segmentString.append(ch)
            result.append(segmentString)
            segmentString = ""
        }
        
        while expIndex < expression.endIndex, inputIndex < input.endIndex {
            let expChar = expression[expIndex]
            
            if CharType(expChar) == nil {
                if input[inputIndex] == expChar {
                    inputIndex = input.index(after: inputIndex)
                }
                segmentString.append(expChar)
                
                expIndex = expression.index(after: expIndex)
                i += 1
                continue
            }
            
            let charType = CharType(expChar)!
            let inChar = input[inputIndex]
            
            switch charType {
            case .digit:
                guard inChar.isNumber else {
                    inputIndex = input.index(after: inputIndex)
                    continue
                }
                let out = templateCharacter(at: i, fallback: inChar)
                updateSegment(with: out)
                
            case .letter:
                guard inChar.isLetter else {
                    inputIndex = input.index(after: inputIndex)
                    continue
                }
                let out = templateCharacter(at: i, fallback: inChar)
                updateSegment(with: out)
                
            case .condition:
                guard let condition = conditions[safe: conditionIndex] else {
                    inputIndex = input.index(after: inputIndex)
                    continue
                }
                
                let allowed = condition
                    .replacingOccurrences(of: " ", with: "")
                    .split(separator: ",")
                    .map(String.init)
                
                guard allowed.contains(String(inChar)) else {
                    inputIndex = input.index(after: inputIndex)
                    continue
                }
                
                let out = templateCharacter(at: i, fallback: inChar)
                updateSegment(with: out)
                conditionIndex += 1
            }
            
            inputIndex = input.index(after: inputIndex)
            expIndex = expression.index(after: expIndex)
            i += 1
        }
        
        return result
    }
    
    private func maskConsumingInvalid(input: String) -> String {
        var result = ""
        var segmentString = ""
        var inputIndex = input.startIndex
        var conditionIndex = 0
        
        for (i, char) in expression.enumerated() where inputIndex < input.endIndex {
            guard let charType = CharType(char) else {
                if char == input[inputIndex] { inputIndex = input.index(after: inputIndex) }
                segmentString.append(char)
                continue
            }
            
            let character = input[inputIndex]
            var templateCharacter = character
            
            if
                let startIndex = template?.startIndex,
                let templateIndex = template?.index(startIndex, offsetBy: i),
                let templateChar = template?[templateIndex],
                CharType(templateChar) == nil
            {
                templateCharacter = templateChar
            }
            
            func updateSegment() {
                segmentString.append(templateCharacter)
                result.append(segmentString)
                segmentString = ""
            }
            
            switch charType {
            case .digit:
                if character.isNumber { updateSegment() }
            case .letter:
                if character.isLetter { updateSegment() }
            case .condition:
                guard let condition = conditions[safe: conditionIndex] else {
                    continue
                }
                
                let allowedCases = condition.replacingOccurrences(of: " ", with: "")
                                            .split(separator: ",")
                                            .map { String($0) }
                
                if allowedCases.contains(String(character)) {
                    updateSegment()
                    conditionIndex += 1
                }
            }
            
            inputIndex = input.index(after: inputIndex)
        }
        
        return result
    }
}



extension Mask {
    enum CharType: String {
        case digit = "D"
        case letter = "L"
        case condition = "C"
        
        init?(_ character: Character) {
            guard let rawValue = CharType(rawValue: String(character)) else {
                return nil
            }
            self = rawValue
        }
    }
}
