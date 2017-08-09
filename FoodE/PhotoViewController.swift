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

    
    @IBOutlet weak var cameraButton: UIButton!
   
    var photo: NSData?
    
    var cameraAvaliable = true
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
       
        
        super.viewDidLoad()
    
            if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
                
                cameraButton.isEnabled = false
                
                cameraAvaliable = false
                
                let alert = UIAlertController(title: "Alert", message: "No camera detected. Capture button has been disabled", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
        }
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = livePhotoView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
         subscribeToKeyboardNotifications()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: .UIKeyboardWillShow, object: nil)
        
      NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name:
            
            NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder();
        
        return true
    }
    
    
    func keyBoardWillShow(notification: NSNotification) {
        
        if(textField.isEditing){
            
            view.frame.origin.y =  getKeyboardHeight(notification: notification) * -1
        }
        
    }
    
    func keyBoardWillHide(notification: NSNotification) {
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        return keyboardSize.cgRectValue.height
    }
    
    
    @IBAction func cameraCapture(_ sender: Any) {
        
        sessionOutput.isHighResolutionCaptureEnabled = true
        sessionOutputSetting.isHighResolutionPhotoEnabled = true
        sessionOutputSetting.isAutoStillImageStabilizationEnabled = true
    
        if sessionOutputSetting.availablePreviewPhotoPixelFormatTypes.count > 0 {
            sessionOutputSetting.previewPhotoFormat = [ kCVPixelBufferPixelFormatTypeKey as String : sessionOutputSetting.availablePreviewPhotoPixelFormatTypes.first!]
        }
        
        let uniqueSettings = AVCapturePhotoSettings.init(from: sessionOutputSetting)
        
        sessionOutput.capturePhoto(with: uniqueSettings, delegate: self)
        
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
        
        if(!cameraAvaliable){
            
            navigationController?.popViewController(animated: true)
            
            dismiss(animated: true, completion: nil)
            
        }
            
        else if ((photo == nil)||(textField.text == "" )){
            
            let alert = UIAlertController(title: "Alert", message: "No Photo or Restaurant Name was entered. Please enter the restaurant name first and retake the photo. ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popViewController(animated: true)
            
            dismiss(animated: true, completion: nil)
        }
    
        else {
        
           let userPhoto = UserPhotos(context: self.sharedContext)
            
            userPhoto.imageData = photo
            
            userPhoto.restaurantName = restaurantInput.text
            
            CoreDataStack.sharedInstance().save()
        
            navigationController?.popViewController(animated: true)
        
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStack.sharedInstance().managedObjectContext!
    }
}
