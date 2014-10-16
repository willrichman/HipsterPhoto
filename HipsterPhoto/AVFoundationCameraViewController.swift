//
//  AVFoundationCameraViewController.swift
//  CFImageFilterSwift
//
//  Created by Bradley Johnson on 9/22/14.
//  Copyright (c) 2014 Brad Johnson. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class AVFoundationCameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturePreviewImageView: UIImageView!
    
    var stillImageOutput = AVCaptureStillImageOutput()
    var returnTap : UIGestureRecognizer?
    var delegate : ImageSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        var bounds = self.previewView.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.bounds = bounds
        previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

        self.previewView.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        if input == nil {
            println("bad!")
        }
        captureSession.addInput(input)
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        captureSession.addOutput(self.stillImageOutput)
        captureSession.startRunning()
        
        self.returnTap = UITapGestureRecognizer(target: self, action: "returnToHome:")
        capturePreviewImageView.addGestureRecognizer(returnTap!)
    }
    
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func capturePressed(sender: AnyObject) {
        
        var videoConnection : AVCaptureConnection?
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                            break;
                        }
                    }
                }
            }
            
            if videoConnection != nil {
                break;
            }
        }
        
        if (videoConnection?.supportsVideoOrientation != nil) {
            videoConnection?.videoOrientation = self.interfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)!
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            self.capturePreviewImageView.image = image
            println(image.size)
        })
        
    }
    
    func returnToHome(tap: UIGestureRecognizer) {
        self.delegate?.didTapOnPicture(self.capturePreviewImageView.image!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func interfaceOrientationToVideoOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        switch orientation {
        case UIInterfaceOrientation.Portrait:
            return AVCaptureVideoOrientation.Portrait
        case UIInterfaceOrientation.PortraitUpsideDown:
            return AVCaptureVideoOrientation.PortraitUpsideDown
        case UIInterfaceOrientation.LandscapeLeft:
            return AVCaptureVideoOrientation.LandscapeLeft
        case UIInterfaceOrientation.LandscapeRight:
            return AVCaptureVideoOrientation.LandscapeRight
        default:
            println("Warning - Didn't recognise interface orientation")
            return AVCaptureVideoOrientation.Portrait;
        }
    }
    
}