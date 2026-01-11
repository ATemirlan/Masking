import Testing
@testable import MaskingCore

@Suite("Testing mask with consume policy")
struct MaskingConsumeCoreTests {
    let mask = Mask(invalidInputPolicy: .consume, expression: "LL-DD")
    
    let phoneMask = Mask(
        invalidInputPolicy: .consume,
        expression: "+C(DDD)-DDD-DD-DD",
        conditions: ["7, 8"],
        template: "+7(DDD)-DDD-DD-DD"
    )
    
    let conditionMask = Mask(invalidInputPolicy: .consume, expression: "C-DD", conditions: ["7,8"])
    
    @Test(arguments: [
        (input: "aa12", output: "aa-12"),
        (input: "1212", output: "-12"),
        (input: "12aa", output: ""),
        
        (input: "", output: ""),
        (input: "a", output: "a"),
        (input: "ab", output: "ab"),
        (input: "ab1", output: "ab-1"),
        (input: "ab12", output: "ab-12"),
        
        (input: "ab123", output: "ab-12"),
        (input: "abcd12", output: "ab"),
        
        (input: "a b 1 2", output: "a"),
        (input: "!!ab__12??", output: "")
    ])
    func baseExpression(input: String, output: String) async throws {
        let result = mask.maskedString(input: input)
        if result != output {
            print("faillled:", result, output)
        }
        #expect(result == output)
    }
    
    @Test(arguments: [
        (input: "7011234567", output: "+7(011)-234-56-7"),
        (input: "+7(701)-123-45-67", output: "+7(701)-123-45-67"),
        (input: "7 01 123 45 67", output: "+7(01)-12-3-45"),
        (input: "7(701)1234567", output: "+7(701)-123-45-67"),
        (input: "87011234567", output: "+7(701)-123-45-67"),
        (input: "77011234567", output: "+7(701)-123-45-67")
    ])
    func phoneMaskFullFormatting(input: String, output: String) async throws {
        let result = phoneMask.maskedString(input: input)
        #expect(result == output)
    }
    
    @Test(arguments: [
        (input: "", output: ""),
        (input: "7", output: "+7"),
        (input: "77", output: "+7(7"),
        (input: "7701", output: "+7(701"),
        (input: "77011", output: "+7(701)-1"),
        (input: "770112", output: "+7(701)-12"),
        (input: "7701123", output: "+7(701)-123"),
        (input: "77011234", output: "+7(701)-123-4")
    ])
    func phone_partialFormatting(input: String, output: String) async throws {
        let result = phoneMask.maskedString(input: input)
        #expect(result == output)
    }
    
    @Test
    func phoneDoesNotExceedTemplateLength() async throws {
        let long = "701123456789999999999"
        let result = phoneMask.maskedString(input: long)
        #expect(result.count <= "+7(DDD)-DDD-DD-DD".count)
    }
    
    @Test
    func phoneIdempotent() async throws {
        let raw = "7011234567"
        let once = phoneMask.maskedString(input: raw)
        let twice = phoneMask.maskedString(input: once)
        #expect(once == twice)
    }
    
    @Test(arguments: [
        (input: "712", output: "7-12"),
        (input: "8 12", output: "8-12"),
        (input: "912", output: "-12"),
        (input: "7123", output: "7-12")
    ])
    func conditionAppliesCorrectly(input: String, output: String) async throws {
        let result = conditionMask.maskedString(input: input)
        #expect(result == output)
    }
}
