//
//  ViewController.swift
//  ScanningDocuments
//
//  Created by Julian Schiavo on 22/2/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet var imageView: BoundingBoxImageView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var progressIndicator: UIProgressView!
    @IBOutlet var scanButton: UIButton!
    
    var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.layer.cornerRadius = 10.0
        
        imageView.layer.cornerRadius = 10.0
        scanButton.layer.cornerRadius = 10.0
        
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
        
        setupVision()
    }
    
    /// Setup the Vision request as it can be reused
    private func setupVision() {
        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedText = ""
            var boundingBoxes = [CGRect]()
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                detectedText += topCandidate.string
                detectedText += "\n"
                
                do {
                    guard let rectangle = try topCandidate.boundingBox(for: topCandidate.string.startIndex..<topCandidate.string.endIndex) else { return }
                    boundingBoxes.append(rectangle.boundingBox)
                } catch {
                    // You should handle errors appropriately in your app
                    print(error)
                }
            }
            
            DispatchQueue.main.async {
                self.scanButton.isEnabled = true
                self.progressIndicator.progress = 1
                
                self.textView.text = detectedText
                self.textView.flashScrollIndicators()
                
                self.imageView.load(boundingBoxes: boundingBoxes)
            }
        }
        
        // I have not yet been able to get the progressHandler working (to display the progress indicator progress normally) as it seems to have a bug that causes random crashes
//        textRecognitionRequest.progressHandler = { [weak self] (_, progress, _) in
//            DispatchQueue.main.async {
//                self.scanButton.isEnabled = progress == 1
//                self.progressIndicator.progress = Float(progress)
//            }
//        }
        
        textRecognitionRequest.recognitionLevel = .accurate
    }
    
    /// Shows a `VNDocumentCameraViewController` to let the user scan documents
    @objc func scanDocument() {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = self
        present(scannerViewController, animated: true)
    }
    
    // MARK: - Scan Handling
    
    /// Processes the image by displaying it and extracting text which is shown to the user
    /// - Parameter image: A `UIImage` to process
    private func processImage(_ image: UIImage) {
        imageView.image = image
        imageView.removeExistingBoundingBoxes()
        
        recognizeTextInImage(image)
    }
    
    /// Recognizes and displays the text from the image
    /// - Parameter image: `UIImage` to process and perform OCR on
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        textView.text = ""
        scanButton.isEnabled = false
        progressIndicator.progress = 0
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - VNDocumentCameraViewControllerDelegate

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Make sure the user scanned at least one page
        guard scan.pageCount >= 1 else {
            // You are responsible for dismissing the VNDocumentCameraViewController.
            controller.dismiss(animated: true)
            return
        }
        
        // This is a workaround for the VisionKit bug which breaks the `UIImage` returned from `VisionKit`
        // See the `Image Loading Hack` section below for more information.
        let originalImage = scan.imageOfPage(at: 0)
        let fixedImage = reloadedImage(originalImage)
        
        // You are responsible for dismissing the VNDocumentCameraViewController.
        controller.dismiss(animated: true)
        
        // Process the image
        processImage(fixedImage)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // The VNDocumentCameraViewController failed with an error.
        // For now, we'll print it, but you should handle it appropriately in your app.
        print(error)
        
        // You are responsible for dismissing the VNDocumentCameraViewController.
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        // You are responsible for dismissing the VNDocumentCameraViewController.
        controller.dismiss(animated: true)
    }
    
    // MARK: - Image Loading Hack
    
    /// VisionKit currently has a bug where the images returned reference unique files on disk which are deleted after dismissing the VNDocumentCameraViewController.
    /// To work around this, we have to create a new UIImage from the data of the original image from VisionKit.
    /// I have filed a bug (FB6156927) - hopefully this is fixed soon.
    
    func reloadedImage(_ originalImage: UIImage) -> UIImage {
        guard let imageData = originalImage.jpegData(compressionQuality: 1),
            let reloadedImage = UIImage(data: imageData) else {
                return originalImage
        }
        return reloadedImage
    }
}
