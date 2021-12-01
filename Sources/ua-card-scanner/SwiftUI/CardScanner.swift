//
//  SwiftUIView.swift
//  
//
//  Created by Guillaume Audinet on 01/12/2021.
//

import SwiftUI

public struct CardScanner: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var cardInformations: CardInformations?
    
    private var cardsTypeAuthorized: [CardType]
    
    public init(cardsTypeAuthorized: [CardType] = CardType.allCases,
                cardInformations: Binding<CardInformations?>) {
        self.cardsTypeAuthorized = cardsTypeAuthorized
        self._cardInformations = cardInformations
    }
    
    public func makeUIViewController(context: Context) -> ScanCardViewController {
        let scanCardViewController = ScanCardViewController(cardsTypeAuthorized: self.cardsTypeAuthorized,
                                                            delegate: context.coordinator)
        return scanCardViewController
    }
    
    public func updateUIViewController(_ uiViewController: ScanCardViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, ScanCardViewControllerDelegate {
        private let parent: CardScanner

        public init(_ parent: CardScanner) {
            self.parent = parent
        }
        
        public func cardInformationDidFind(_ scanCardViewController: ScanCardViewController, cardInformations: CardInformations) {
            parent.cardInformations = cardInformations
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
