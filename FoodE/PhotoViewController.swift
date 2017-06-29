//
//  PhotoViewController.swift
//  FoodE
//
//  Created by Rola Kitaphanich on 2017-04-28.
//  Copyright © 2017 Rola Kitaphanich. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class PhotoViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var livePhotoView: UIView!
    @IBOutlet weak var photoPreview: UIImageView!
    @IBOutlet weak var restaurantInput: UITextField!
    
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
    var previewLayer = AVCaptureVideoPreviewLayer();
    
    var photo = NSData()
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = livePhotoView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
    
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
       
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.back){
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        
                        if(captureSession.canAddOutput(sessionOutput)){
                            captureSession.addOutput(sessionOutput);
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                            livePhotoView.layer.addSublayer(previewLayer);
                            captureSession.startRunning()
                            
                        }
                    }
                    
                }
                catch{
                    print("exception!");
                }
            }
        }
        
    }
    
    
    @IBAction func cameraCapture(_ sender: Any) {
        sessionOutput.isHighResolutionCaptureEnabled = true
        sessionOutputSetting.isHighResolutionPhotoEnabled = true
        sessionOutputSetting.isAutoStillImageStabilizationEnabled = true
    
        if sessionOutputSetting.availablePreviewPhotoPixelFormatTypes.count > 0 {
            sessionOutputSetting.previewPhotoFormat = [ kCVPixelBufferPixelFormatTypeKey as String : sessionOutputSetting.availablePreviewPhotoPixelFormatTypes.first!]
        }
        
        sessionOutput.capturePhoto(with: sessionOutputSetting, delegate: self)
        
    }
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if photoSampleBuffer != nil {
            
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
           
            let photoDataProvider = CGDataProvider(data: photoData! as CFData)
           
            let cgImagePhotoRef = CGImage(jpegDataProviderSource: photoDataProvider!, decode: nil, shouldInterpolate: true, intent: .absoluteColorimetric)
           
            let newPhoto = UIImage(cgImage: cgImagePhotoRef!, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.photoPreview.image = newPhoto
            
            photo = photoData! as NSData
            
            
        }

    }
    
    
    @IBAction func savePhoto(_ sender: Any) {
        
        
           let userPhoto = UserPhotos(context: self.sharedContext)
            
            userPhoto.imageData = photo
            
            userPhoto.restaurantName = restaurantInput.text
            
            CoreDataStack.sharedInstance().save()
        
            navigationController?.popViewController(animated: true)
        
            dismiss(animated: true, completion: nil)
    }
    
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
}
