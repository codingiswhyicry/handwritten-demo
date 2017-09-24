//
//  ViewController.swift
//  handwritingDemo
//
//  Created by Amanda Southworth on 9/23/17.
//  Copyright © 2017 Amanda Southworth. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    func detectText() {
        
        var request = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        request.reportCharacterBoxes = true
        self.requests = [request]
        
        
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        
        guard let observations = request.results else {
            //no results returned
            return
        }
        
        let result = observations.map({$0 as? VNTextObservation})
        
    }
    
    func startSession() {
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        let device_in = try! AVCaptureDeviceInput(device: device!)
        let device_out = AVCaptureVideoDataOutput()
        
        device_out.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: (Int(kCVPixelFormatType_32BGRA))]
        device_out.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        session.addInput(device_in)
        session.addOutput(device_out)
        
        var imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.alpha = 0.0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.imageView.alpha = 1.0
        })
        
        startSession()
        detectText()
    }
    
    override func viewDidLayoutSubviews() {
        
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    @IBOutlet weak var imageView: UIImageView!
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    
    
}

