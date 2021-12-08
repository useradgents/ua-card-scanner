//
//  String+Utils.swift
//  
//
//  Created by Guillaume Audinet on 07/12/2021.
//

import Foundation

extension String {
    var cardType: CardType? {
        if count == 16 {
            if isVisa && luhnCheck { return .visa }
            if isMastercard && luhnCheck { return .mastercard }
            if luhnCheck { return .cb }
        } else if count == 15 {
            if isAmex && luhnCheck { return .amex }
            if isCarteVitale { return .carteVitale }
        }
        
        return nil
    }

    func formatCardNumber(for type: CardType?) -> String? {
        guard let type = type else { return self }
        guard type.isValid(cardNumber: self) else { return nil }

        switch type {
        case .cb, .visa, .mastercard:
            return spaceChars(per: 4)
        case .amex:
            return formatForAmex
        case .carteVitale:
            return formatForCarteVitale
        }
    }
    
    private var formatForAmex: String {
        var tmp = self
        let spaceIndexes = [4, 11]
        for spaceIndex in spaceIndexes {
            let i = tmp.index(tmp.startIndex, offsetBy: spaceIndex)
            tmp.insert(" ", at: i)
        }
        return tmp
    }
    
    private var formatForCarteVitale: String {
        var tmp = self
        let spaceIndexes = [1, 4, 7, 10, 14, 18]
        for spaceIndex in spaceIndexes {
            let i = tmp.index(tmp.startIndex, offsetBy: spaceIndex)
            tmp.insert(" ", at: i)
        }
        return tmp
    }

    private func spaceChars(per batch: Int) -> String {
        var result = ""
        self.replacingOccurrences(of: " ", with: "")
            .enumerated()
            .forEach { index, character in
            if index % batch == 0 && index > 0 {
                result += " "
            }
            result.append(character)
        }
        return result
    }
}

extension String {
    private func matches(_ regex: String) -> Bool {
        range(of: regex, options: [.regularExpression]) != nil
    }
    
    var isVisa: Bool {
        let pattern = "^4[0-9]{12}(?:[0-9]{3})?$"
        return matches(pattern)
    }
    
    var isAmex: Bool {
        let pattern = "^3[47][0-9]{13}$"
        return matches(pattern)
    }

    var isMastercard: Bool {
        let pattern = "^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$"
        return matches(pattern)
    }
    
    var isCarteVitale: Bool {
        let pattern = "[1-2][0-9]{2}(0[1-9]|1[0-2]|20|3[0-9]|4[0-2]|[5-9][0-9])(0[1-9]|[1-9][0-9]|2A|2B)([0]{2}[1-9]|0[1-9][0-9]|[1-9][0-9]{2})([0]{2}[1-9]|0[1-9][0-9]|[1-9][0-9]{2})|([1-2][9]{12})"
        return matches(pattern)
    }
    
    // Check if card number match with Luhn algorithm
    var luhnCheck: Bool {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self)) else { return false }

        var sum = 0
        let digitStrings = self.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }

}
