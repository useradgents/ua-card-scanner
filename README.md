# ua-card-scanner

Minimal credit card scanner

## Prerequisite(s)
- iOS 13

Indeed, ua-card-scanner works with the Framework [Vision](https://developer.apple.com/documentation/vision) and more specifically with [VNRecognizeTextRequest](https://developer.apple.com/documentation/vision/vnrecognizetextrequest) who require iOS 13. This last, is the Apple's OCR.

## Setup

### Swift Package Manager

Add package with SPM

## Usage

### Initialization

```swift
import ua_card_scanner

let scanCardViewController = ScanCardViewController(delegate: self)
present(scanCardViewController, animated: true, completion: nil)
```
    
### Initialization alternative

```swift
import ua_card_scanner

let scanCardViewController = ScanCardViewController(cardsTypeAuthorized: [...], delegate: self)
present(scanCardViewController, animated: true, completion: nil)
```
    
`cardsTypeAuthorized` take en array of CardType. If you pass this paramater, ua-card-scanner return cardInformations by delegate only if the card number detected match with rules of one cardType

`CardType` available

```swift
enum CardType {
    case cb
    case visa
    case mastercard
    case amex
    case dinersClub
    case discover
}
```
    
### Implement Delegate

```swift
extension NewCardPaymentViewController: ScanCardViewControllerDelegate {
    func cardInformationDidFind(_ scanCardViewController: ScanCardViewController,
                                cardInformations: CardInformations) {
        // Do Stuff with cardInformations
    }
}
```

## Authors

- Guillaume AUDINET <[g.audinet@useradgents.com](mailto:g.audinet@useradgents.com)>
