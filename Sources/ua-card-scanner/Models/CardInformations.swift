//
//  File.swift
//  
//
//  Created by Guillaume Audinet on 10/11/2021.
//

import Foundation

public struct CardInformations: Hashable, CustomStringConvertible {
    public let cardNumber: String?
    public let cardExpirationDate: String?
    public let cardType: CardType
    
    // MARK: - CustomStringConvertible
    public var description: String {
        var message = "[CardInformations] cardNumber : \(cardNumber ?? "empty")"
        message.append(contentsOf: ", ")
        message.append(contentsOf: "cardExpirationDate : \(cardExpirationDate ?? "empty")")
        return message
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        let h = "\(cardNumber ?? "")\(cardExpirationDate ?? "")"
        hasher.combine(h)
    }
}
