//
//  File.swift
//  
//
//  Created by Guillaume Audinet on 10/11/2021.
//

import Foundation

public enum CardType: String, CaseIterable {
    case cb
    case visa
    case mastercard
    case amex
        
    case carteVitale
    
    // Check if card number count match with count required according to type
    private var isCreditCard: Bool {
        switch self {
        case .cb, .visa, .mastercard, .amex:
            return true
        case .carteVitale:
            return false
        }
    }

    // Check if all rules are respected
    func isValid(cardNumber: String) -> Bool {
        guard isCreditCard ? cardNumber.luhnCheck : true else { return false }
        guard cardNumberCountCheck(cardNumber) else { return false }
        guard isValidForThisType(cardNumber: cardNumber) else { return false }
        
        return true
    }
    
    private func isValidForThisType(cardNumber: String) -> Bool {
        switch self {
        case .carteVitale:
            guard cardNumber.isCarteVitale else { return false }
            return true
        default:
            return true
        }
    }
    
    // Check if card number count match with count required according to type
    private func cardNumberCountCheck(_ number: String) -> Bool {
        switch self {
        case .cb, .visa, .mastercard:
            return number.count == 16
        case .amex, .carteVitale:
            return number.count == 15
        }
    }

}
