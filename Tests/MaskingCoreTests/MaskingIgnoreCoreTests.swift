import Testing
@testable import MaskingCore

@Suite("Testing mask with ignore policy")
struct MaskingIgnoreCoreTests {
    let mask = Mask(invalidInputPolicy: .ignore, expression: "LL-DD")
    
    let phoneMask = Mask(
        invalidInputPolicy: .ignore,
        expression: "+C(DDD)-DDD-DD-DD",
        conditions: ["7, 8"],
        template: "+7(DDD)-DDD-DD-DD"
    )
    
    let conditionMask = Mask(invalidInputPolicy: .ignore, expression: "C-DD", conditions: ["7,8"])

    @Test(arguments: [
        (input: "aa12", output: "aa-12"),
        (input: "1212", output: ""),
        (input: "12aa", output: "aa"),
        (input: "", output: ""),
        (input: "a", output: "a"),
        (input: "ab", output: "ab"),
        (input: "ab1", output: "ab-1"),
        (input: "ab12", output: "ab-12"),
        (input: "ab123", output: "ab-12"),
        (input: "abcd12", output: "ab-12"),
        (input: "a b 1 2", output: "ab-12"),
        (input: "!!ab__12??", output: "ab-12"),
        (input: "ab_12", output: "ab-12")
    ])
    func baseExpression(input: String, output: String) async throws {
        let result = mask.maskedString(input: input)
        if result != output {
            print("failed:", input, "got:", result, "expected:", output)
        }
        #expect(result == output)
    }

    @Test(arguments: [
        (input: "77011234567", output: "+7(701)-123-45-67"),
        (input: "87011234567", output: "+7(701)-123-45-67"),
        (input: "+7(701)-123-45-67", output: "+7(701)-123-45-67"),
        (input: "7 701 123 45 67", output: "+7(701)-123-45-67"),
        (input: "8 (701) 123-45-67", output: "+7(701)-123-45-67"),
        (input: "7(701)1234567", output: "+7(701)-123-45-67"),
        (input: "7xx701--123__45..67", output: "+7(701)-123-45-67")
    ])
    func phoneMaskFullFormatting(input: String, output: String) async throws {
        let result = phoneMask.maskedString(input: input)
        if result != output {
            print("failed:", input, "got:", result, "expected:", output)
        }
        #expect(result == output)
    }

    @Test(arguments: [
        (input: "", output: ""),
        (input: "x", output: ""),
        (input: "7", output: "+7"),
        (input: "8", output: "+7"),
        (input: "77", output: "+7(7"),
        (input: "7701", output: "+7(701"),
        (input: "77011", output: "+7(701)-1"),
        (input: "770112", output: "+7(701)-12"),
        (input: "7701123", output: "+7(701)-123"),
        (input: "77011234", output: "+7(701)-123-4"),
        (input: "7 701 1", output: "+7(701)-1"),
        (input: "7 701 12", output: "+7(701)-12")
    ])
    func phone_partialFormatting(input: String, output: String) async throws {
        let result = phoneMask.maskedString(input: input)
        if result != output {
            print("failed:", input, "got:", result, "expected:", output)
        }
        #expect(result == output)
    }

    @Test func phoneDoesNotExceedTemplateLength() async throws {
        let long = "7 701 123 45 67 999 888 777"
        let result = phoneMask.maskedString(input: long)
        #expect(result.count <= "+7(DDD)-DDD-DD-DD".count)
    }

    @Test func phoneIdempotent() async throws {
        let raw = "77011234567"
        let once = phoneMask.maskedString(input: raw)
        let twice = phoneMask.maskedString(input: once)
        #expect(once == twice)
    }

    @Test(arguments: [
        (input: "712", output: "7-12"),
        (input: "812", output: "8-12"),
        (input: "912", output: ""),
        (input: "x7 12", output: "7-12"),
        (input: "7123", output: "7-12")
    ])
    func conditionAppliesCorrectly(input: String, output: String) async throws {
        let result = conditionMask.maskedString(input: input)
        #expect(result == output)
    }
}
