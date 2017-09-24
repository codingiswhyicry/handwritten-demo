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
import CoreML

class ViewController: UIViewController {

    
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
        
        DispatchQueue.main.async() {
            
            self.imageView.layer.sublayers?.removeSubrange(1...)
            
            for region in result {
                
                guard let rg = region else {
                
                    //no regions found :(
                   continue
                }
                
                self.detectWord(box: rg)
                
            }
        }
    }
    
    func detectWord(box: VNTextObservation) {
        
        guard let boxes = box.characterBoxes else {
            
            //no boxes were found :(
            return
        }
        
        var maxX = CGFloat(9999.0)
        var minX = CGFloat(0.0)
        var maxY = CGFloat(9999.0)
        var minY = CGFloat(0.0)
        
        for char in boxes {
            
            if char.bottomLeft.x < maxX  {  maxX = char.bottomLeft.x    }
            if char.bottomRight.x > minX {  minX = char.bottomRight.x   }
            if char.bottomRight.y < maxY {  maxY = char.bottomRight.y   }
            if char.topRight.y > minY    {  minY = char.topRight.y      }
            
            let x_co = maxX * imageView.frame.size.width
            let y_co = (1 - minY) * imageView.frame.size.height
            let width = (minX - maxX) * imageView.frame.size.width
            let height = (minY - maxY) * imageView.frame.size.height
            
            var highlight = CALayer()
            highlight.frame = CGRect(x: x_co, y: y_co, width: width, height: height)
            highlight.borderWidth = 1
            highlight.cornerRadius = 3
            highlight.borderColor = UIColor(red:0.11, green:0.91, blue:0.71, alpha:1.0).cgColor
            
            imageView.layer.addSublayer(highlight)
        }
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

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            
            //no sample buffer :(
            return
        }
        
        var request_opt: [VNImageOption : Any] = [:]
        
        if let cam_data = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            
            request_opt = [.cameraIntrinsics: cam_data]
        }
        
        let image_request_handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: request_opt)
        
        do { try image_request_handler.perform(self.requests)  }
        catch { print (error) }
        
    }
}

