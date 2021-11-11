//
//  ScanCardViewController.swift
//  Franprix App
//
//  Created by Guillaume Audinet on 04/10/2021.
//  Copyright © 2021 userAdgents. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

public protocol ScanCardViewControllerDelegate: AnyObject {
    func cardInformationDidFind(_ scanCardViewController: ScanCardViewController, cardInformations: CardInformations)
}

public class ScanCardViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var cameraPreviewView: UIView!
    @IBOutlet private weak var overlayView: UIView!

    private let cardsTypeAuthorized: [CardType]
    private weak var delegate: ScanCardViewControllerDelegate?

    // MARK: - Video variables
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspectFill
        return preview
    }()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    // MARK: - Help variables
    private let requestHandler = VNSequenceRequestHandler()
    private var paymentCardRectangleObservation: VNRectangleObservation?

    // MARK: - Result variables
    private var resultFound = false
    private var resultCount: [CardInformations: Int] = [:]
    
    // MARK: - Initializers
    public init(cardsTypeAuthorized: [CardType] = CardType.allCases,
         delegate: ScanCardViewControllerDelegate?) {
        self.cardsTypeAuthorized = cardsTypeAuthorized
        self.delegate = delegate

        super.init(nibName: "ScanCardViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBar.appearance()
        let titleColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor
        titleLabel.textColor = titleColor
        
        dismissButton.setTitle("", for: .normal)
        
        self.setupCaptureSession()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        overlayView.isHidden = true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.previewLayer.frame = self.view.bounds
    }
        
    // MARK: - Camera setup
    private func setupCaptureSession() {
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
        self.captureSession.startRunning()
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        let cameraInput = try? AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput!)
    }
    
    private func addPreviewLayer() {
        cameraPreviewView.layer.addSublayer(self.previewLayer)
    }
        
    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "scan-card.queue"))
        self.captureSession.addOutput(self.videoOutput)
        guard let connection = self.videoOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }

    // MARK: - Result computing
    private func extractPaymentCardNumber(frame: CVImageBuffer) {
        let ciImage = CIImage(cvImageBuffer: frame)

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? stillImageRequestHandler.perform([request])

        guard let texts = request.results, texts.count > 0 else {
            return
        }

        let bestStrings = texts
            .flatMap({ $0.topCandidates(10).map({ $0.string }) })
        let cardNumbersRecognized = bestStrings
            .map({ $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "") })
            .first(where: { CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: $0)) })
        let expiredDateRecognizedSub = bestStrings
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .first(where: { $0.contains("/") })?
            .split(separator: " ")
            .first(where: { $0.contains("/") })
        let expiredDateRecognized = expiredDateRecognizedSub != nil
            ? String(expiredDateRecognizedSub ?? "")
            : nil

        if !resultFound,
           let cardNumber = cardNumbersRecognized {
            guard checkCardNumber(cardNumber) else { return }

            let cardInformations = CardInformations(cardNumber: cardNumber,
                                                    cardExpirationDate: expiredDateRecognized)
            let newValue = (resultCount[cardInformations] ?? 0) + 1
            resultCount[cardInformations] = newValue
            
            guard newValue >= 5 else { return }

            DispatchQueue.main.async {
                self.resultFound = true
                self.captureSession.stopRunning()
                self.dismiss(animated: true) {
                    self.delegate?.cardInformationDidFind(self, cardInformations: cardInformations)
                }
            }
        }
    }
    
    // MARK: - Utils
    private func checkCardNumber(_ cardNumber: String) -> Bool {
        for card in cardsTypeAuthorized {
            if card.isValid(cardNumber: cardNumber) { return true }
        }
        
        return false
    }
        
    // MARK: - Actions
    @IBAction func dismissButtonDidTouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ScanCardViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.extractPaymentCardNumber(frame: frame)
        }
    }
}
