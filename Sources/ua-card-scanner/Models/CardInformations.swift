//
//  File.swift
//  
//
//  Created by Guillaume Audinet on 10/11/2021.
//

import Foundation

public struct CardInformations: Hashable, CustomStringConvertible {
    public let cardType: CardType?
    public let cardNumber: String?
    public let cardExpirationDate: String?
    
    // MARK: - CustomStringConvertible
    public var description: String {
        var message = "[CardInformations]\n"
        message.append(contentsOf: "- cardType : \(cardType?.rawValue ?? "empty")\n")
        message.append(contentsOf: "- cardNumber : \(cardNumber?.formatCardNumber(for: cardType) ?? "empty")\n")
        message.append(contentsOf: "- cardExpirationDate : \(cardExpirationDate ?? "empty")")
        return message
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        let h = "\(cardNumber ?? "")\(cardExpirationDate ?? "")"
        hasher.combine(h)
    }
}
