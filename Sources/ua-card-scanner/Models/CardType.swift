//
//  File.swift
//  
//
//  Created by Guillaume Audinet on 10/11/2021.
//

import Foundation

public enum CardType: CaseIterable {
    case cb
    case visa
    case mastercard
    case amex
    case dinersClub
    case discover
    
    // swiftlint:disable cyclomatic_complexity
    func isValid(cardNumber: String) -> Bool {
        guard luhnCheck(cardNumber) else { return false }
        
        switch self {
        case .cb:
            guard cardNumber.count == 16 else { return false }
        case .visa:
            guard cardNumber.count == 16 else { return false }
        case .mastercard:
            guard cardNumber.count == 16 else { return false }
        case .amex:
            guard cardNumber.count == 15 else { return false }
        case .dinersClub:
            guard cardNumber.count == 14 else { return false }
        case .discover:
            guard cardNumber.count == 16 else { return false }
        }
        
        return true
    }
    
    private func luhnCheck(_ number: String) -> Bool {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: number)) else { return false }

        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

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
