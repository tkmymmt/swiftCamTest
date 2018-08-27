//
//  ViewController.swift
//  camTest
//
//  Created by takumi on 2018/07/25.
//  Copyright © 2018年 takumi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate
{
    var isMainCamera = true;
    
    var captureSession = AVCaptureSession()
    
    var currentDevice: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var changeCameraButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        setupCaptureSession()
        styleCaptureButton()
    }
    
    @IBAction func cameraButton_TouchUpInside(_ sender: Any)
    {
         let settings = AVCapturePhotoSettings()
        
         settings.flashMode = .auto
        
         settings.isAutoStillImageStabilizationEnabled = true
        
         settings.isHighResolutionPhotoEnabled = false
        
         self.photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    @IBAction func ChangeCameraButton_TouchUpInside(_ sender: Any)
    {
        self.isMainCamera = !self.isMainCamera
        setupDevice(isMainCamera: self.isMainCamera)
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate
{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        if let imageData = photo.fileDataRepresentation()
        {
            let uiImage = UIImage(data: imageData)
            
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
        }
    }
}

extension ViewController
{
    func setupCaptureSession()
    {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(isMainCamera: Bool)
    {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices
        {
            let devicePosition: AVCaptureDevice.Position = isMainCamera ? .back : .front
            
            if device.position == devicePosition
            {
                currentDevice = device
            }
        }
    }
    
    func setupInputOutput()
    {
        do
        {
            let captureDeviceInput = try AVCaptureDeviceInput.init(device: currentDevice!)
            
            captureSession = AVCaptureSession()
            captureSession.addInput(captureDeviceInput)
            
            photoOutput = AVCapturePhotoOutput()
            
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            captureSession.addOutput(photoOutput!)
        }
        catch
        {
            print(error)
        }
    }
    
    func setupPreviewLayer()
    {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
        
        self.cameraPreviewLayer?.bounds = self.cameraView.frame
        
        self.cameraView.layer.addSublayer(self.cameraPreviewLayer!)
    }
    
    func styleCaptureButton()
    {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        
        cameraButton.layer.borderWidth = 5
        
        cameraButton.clipsToBounds = true
        
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
    @objc func onDidBecomeActive(_ notification: Notification?)
    {
        setupDevice(isMainCamera: self.isMainCamera)
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
    }
}
