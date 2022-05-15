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
    case unknown
    
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
        default:
            return false
            
        }
    }
    // List of all card regex
        
    var regex : String {
        switch self {
        case .amex:
            return "^3[47][0-9]{5,}$"
        case .visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .mastercard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .dinersClub:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        default:
            return ""
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
    static func cardType(_ number: String?) -> CardType {
        // Get only numbers from the input string
        guard let number = number else { return .unknown }
        var type: CardType = .unknown
        // detect card type
        for card in CardType.allCases {
            if (matchesRegex(card.regex, text: number)) {
                type = card
                break
            }
        }
        // return the type
        return type
    }
    private static func matchesRegex(_ regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
}
