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
        
        var bounds = self.previewView.layer.bounds
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
        
        videoConnection?.videoOrientation = AVCaptureVideoOrientation.Portrait

        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            
            // Crop the image to a square (yikes, fancy!)
            var size = CGSize(width: 960, height: 960)
            var croppedImage = self.squareImageWithImage(image, scaledToSize: size)
            
            self.capturePreviewImageView.image = croppedImage
            print(croppedImage.size)
        })
    }
    
    func returnToHome(tap: UIGestureRecognizer) {
        self.delegate?.didTapOnPicture(self.capturePreviewImageView.image!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func squareImageWithImage(image: UIImage, scaledToSize: CGSize) -> UIImage {
        var ratio: CGFloat!
        var delta: CGFloat!
        var offset: CGPoint!
        
        var size = CGSizeMake(scaledToSize.width, scaledToSize.width)
        
        if image.size.width > image.size.height {
            ratio = scaledToSize.width / image.size.width
            delta = ratio * image.size.width - ratio * image.size.height
            offset = CGPointMake(delta / 2, 0)
        } else {
            ratio = scaledToSize.width / image.size.height
            delta = ratio * image.size.height - ratio * image.size.width
            offset = CGPointMake(0, delta / 2)
        }
        
        var clipRect: CGRect = CGRectMake(-offset.x, -offset.y, (ratio * image.size.width) + delta, (ratio * image.size.height) + delta)
        
        if UIScreen.mainScreen().respondsToSelector("scale") {
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        UIRectClip(clipRect)
        image.drawInRect(clipRect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}