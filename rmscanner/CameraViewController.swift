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

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraPreview: UIImageView!
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        session = AVCaptureSession()
//        session!.sessionPreset = AVCaptureSession.Preset.photo
//        let backCamera =  AVCaptureDevice.default(for: AVMediaType.video)
//        var error: NSError?
//        var input: AVCaptureDeviceInput!
//        do {
//            input = try AVCaptureDeviceInput(device: backCamera!)
//        } catch let error1 as NSError {
//            error = error1
//            input = nil
//            print(error!.localizedDescription)
//        }
//        if error == nil && session!.canAddInput(input) {
//            session!.addInput(input)
//            stillImageOutput = AVCapturePhotoOutput()
////            stillImageOutput?.output outputSettings = [AVVideoCodecKey:  AVVideoCodecJPEG]
//            if session!.canAddOutput(stillImageOutput!) {
//                session!.addOutput(stillImageOutput!)
//                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
//                videoPreviewLayer!.videoGravity =    AVLayerVideoGravity.resizeAspect
//                videoPreviewLayer!.connection?.videoOrientation =   AVCaptureVideoOrientation.portrait
//                cameraPreview.layer.addSublayer(videoPreviewLayer!)
//                session!.startRunning()
//            }
//        }
//    }

    @IBAction func tapTakePictureButton(_ sender: UIButton) {
    }
}
