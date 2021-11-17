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
        
    // Check if all rules are respected
    func isValid(cardNumber: String) -> Bool {
        guard luhnCheck(cardNumber) else { return false }
        guard cardNumberCountCheck(cardNumber) else { return false }
                
        return true
    }
    
    // Check if card number count match with count required according to type
    private func cardNumberCountCheck(_ number: String) -> Bool {
        switch self {
        case .cb, .visa, .mastercard, .discover:
            return number.count == 16
        case .amex:
            return number.count == 15
        case .dinersClub:
            return number.count == 14
        }
    }

    // Check if card number match with Luhn algorithm
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
