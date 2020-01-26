//
//  CameraViewController.swift
//  rmscanner
//
//  Created by stud on 30/11/2019.
//  Copyright © 2019 ol. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var captureView: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var decodeButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium

        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)

            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }


    }

    func setupLivePreview() {

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreview.layer.addSublayer(videoPreviewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.cameraPreview.bounds
            }
        }
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        scanButton.alpha = 0
        scanButton.isEnabled = false
        tryAgainButton.alpha = 1
        tryAgainButton.isEnabled = true
        decodeButton.alpha = 1
        decodeButton.isEnabled = true
        captureView.alpha = 1
        cameraPreview.alpha = 0
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        captureView.image = image
    }
    
    @IBAction func tryAgain(_ sender: UIButton) {
        captureView.alpha = 0
        cameraPreview.alpha = 1
        scanButton.alpha = 1
        scanButton.isEnabled = true
        tryAgainButton.alpha = 0
        tryAgainButton.isEnabled = false
        decodeButton.alpha = 0
        decodeButton.isEnabled = false
    }
    
    @IBAction func decode(_ sender: UIButton) {
        //decoding process will take place here
        //passing image from captureView to the native code function
        //...
        
        captureView.alpha = 0
        cameraPreview.alpha = 1
        scanButton.alpha = 1
        scanButton.isEnabled = true
        tryAgainButton.alpha = 0
        tryAgainButton.isEnabled = false
        decodeButton.alpha = 0
        decodeButton.isEnabled = false
        
        performSegue(withIdentifier: "openResult", sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
}
