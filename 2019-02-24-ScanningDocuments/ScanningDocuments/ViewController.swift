//
//  ViewController.swift
//  ScanningDocuments
//
//  Created by Julian Schiavo on 22/2/2019.
//  Copyright © 2019 Julian Schiavo. All rights reserved.
//

import UIKit
import WeScan

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanButton.layer.cornerRadius = 10.0
        scanButton.addTarget(self, action: #selector(scanImage), for: .touchUpInside)
    }

    
    @objc func scanImage() {
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        present(scannerViewController, animated: true)
    }

}

extension ViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // The image scanner failed with an error.
        // For now, we'll print it, but you should handle it correctly in your app.
        print(error)
        
        // You are responsible for dismissing the controller.
        scanner.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // The image scanner finished scanning. The results contain the original, cropped, and enhanced images as well as other properties.
        imageView.image = results.doesUserPreferEnhancedImage ? results.enhancedImage : results.scannedImage
        
        // You are responsible for dismissing the controller.
        scanner.dismiss(animated: true)
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // The user clicked the Cancel button on the image scanner controller.
        
        // You are responsible for dismissing the controller.
        scanner.dismiss(animated: true)
    }
    
}
