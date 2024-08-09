//
//  Extensions.swift
//  appsonair
//
//  Created by vishal-zaveri-us on 22/04/24.
//

import Foundation
import UIKit
import CoreMotion
import Toast_Swift
import ZLImageEditor
import AVKit
import Photos

// MARK: - EXTENSION UIViewController
typealias ToastCompletionHandler = (_ success:Bool) -> Void
var isFeedbackInProgress = false

extension UIViewController {
    
    static let classInit: Void = {
        let originalSelector = #selector(UIViewController.viewDidLoad)
        let swizzledSelector = #selector(UIViewController.swizzled_viewDidLoad)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else {
            return
        }
        
        let originalSelectorViewDidDisappear = #selector(UIViewController.viewDidDisappear(_:))
        let swizzledSelectorViewDidDisappear = #selector(UIViewController.swizzled_viewDidDisappear(_:))
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelectorViewDidDisappear),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelectorViewDidDisappear) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
    }()
    
    @objc func swizzled_viewDidLoad() {
        self.swizzled_viewDidLoad()
        
        
        if let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last {
         print("View controller viewDidLoad: \(name)")
            // Check the name and perform actions accordingly
            if(name == "ZLEditImageViewController" || name == "FeedbackController" || name == "_UIImagePickerPlaceholderViewController" || name ==
            "PUPhotoPickerHostViewController" || name == "UIImagePickerController") {
             isFeedbackInProgress = true
             return
            } else {
                setupMotionDetection()
            }
        }
    
    }
    
    @objc private func swizzled_viewDidDisappear(_ animated: Bool) {
        self.swizzled_viewDidDisappear(animated)
               if let name = NSStringFromClass(type(of: self)).components(separatedBy: ".").last {
                print("View controller disappeared: \(name) & isBeingDismissed: \(isBeingDismissed)")
                    // Check the name and perform actions accordingly
                
                   if((name == "ZLEditImageViewController" || name == "FeedbackController") && isBeingDismissed) {
                       isFeedbackInProgress = false
                   }
               }
       }
    
    @objc func swizzled_dealloc() {
           // Clean up resources here if needed
           self.swizzled_dealloc()
    }
    
    func setupMotionDetection() {
        // Set the view controller to become the first responder
        _ = self.view // Ensure the view is loaded
        self.becomeFirstResponder()
        
        // Add motion detection
        let motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    
    }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
       
            if motion == .motionShake {
                print("Shake Gesture Detected")
               handleShakeGesture()
            }
    }
    
    func handleShakeGesture() {
        var screenshot: UIImage?
        
        guard !isFeedbackInProgress else {
            return
        }
        
        
        if let captureImage = UIApplication.shared.windows.first?.takeScreenshot() {
            // Do something with the screenshot, like saving it to the photo library
            // UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
            screenshot = captureImage
        }
        
       ZLImageEditorConfiguration.default()
            .editImageTools([.draw, .clip, .textSticker])
            .adjustTools([.brightness, .contrast, .saturation])
        
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: screenshot ?? UIImage()) { image, Editmodel in
            screenshot = image
            
            self.showFeedbackScreen(screenshot: screenshot)
            
        }
        
       
    }
   
    func presentScreenFromTop(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .overFullScreen // or .overCurrentContext
    
        DispatchQueue.main.async { [weak self] in
            self?.present(viewController, animated: animated, completion: completion)
        }
    }
    
    func showToast(message : String, duration: Double = 2.0,completion:@escaping ToastCompletionHandler){
        
        self.view.makeToast(message,duration: duration)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            completion(true)
        })
        
    }
    
    //IMAGE SELECTION  PRESENT CAMERA/PHOTO_LIBRARY
    func selectImagePopup(_ title: String? = "Choose your Image source" , isAllFile: Bool = false){
        
        let alert = UIAlertController(title: nil, message: title , preferredStyle: UIAlertController.Style.actionSheet)
        
        /*
             alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
                self.openCamera()
             })
         */
        
        alert.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) { (result : UIAlertAction) -> Void in
            
            self.openGalery(isAllFile: isAllFile)
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (result : UIAlertAction) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
            
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        
        print("==> Camera selected")
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if (status == .authorized || status == .notDetermined) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = (self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                
            }else if status == .denied {
                
                let alert = UIAlertController(title: "Feedback" , message: "Camera permission required", preferredStyle: UIAlertController.Style.alert);
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(self) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            
            print("Camera not Avalilable on this device")
            
            /*self.view.makeToast("Camera not Avalilable on this device", duration: 0.4, position: .bottom)*/
        }
    }
    
    func openGalery(isAllFile: Bool = false){
        print("==> Gallery selected")
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .denied {
                let alert = UIAlertController(title: "Feedback" , message: "Gallery permission required", preferredStyle: UIAlertController.Style.alert);
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(self) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
            } else {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    DispatchQueue.main.async {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = (self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate)
                        imagePicker.sourceType = .photoLibrary
                        if isAllFile {
                            imagePicker.mediaTypes = ["public.image", "public.movie"]
                        }
                        
                        imagePicker.allowsEditing = false
                        imagePicker.modalPresentationStyle = .fullScreen
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                    
                    
                }
            }
        }
       
    }
    
    public func showFeedbackScreen(screenshot: UIImage? = nil) {
        //let bundle = Bundle(for: type(of: self))
        let bundle = Bundle(identifier: "org.cocoapods.AppsOnAir")
        let storyboard = UIStoryboard(name: "Feedback", bundle: bundle)
        let Vc = storyboard.instantiateViewController(withIdentifier: "FeedbackController") as? FeedbackController
        
        if(screenshot != nil) {
            Vc?.selectedImage = [screenshot ?? UIImage()]
        }
        
        Vc?.navBarColor = AppsOnAirServices.shared.navBarColor
        Vc?.navBarTitle = AppsOnAirServices.shared.navBarTitle
        Vc?.navBarTitleTextColor = AppsOnAirServices.shared.navBarTitleTextColor
        
        Vc?.backgroundColor = AppsOnAirServices.shared.backgroundColor
        
        Vc?.labelTextColor = AppsOnAirServices.shared.labelTextColor
        Vc?.inputHintTextColor = AppsOnAirServices.shared.inputHintTextColor
        Vc?.backgroundColor = AppsOnAirServices.shared.backgroundColor
        
        Vc?.labelTextColor = AppsOnAirServices.shared.labelTextColor
        Vc?.inputHintTextColor = AppsOnAirServices.shared.inputHintTextColor
        
        
        Vc?.txtDescriptionCharLimit = AppsOnAirServices.shared.txtDescriptionCharLimit ?? 255
        Vc?.txtDescriptionHintText = AppsOnAirServices.shared.txtDescriptionHintText
        
        Vc?.btnSubmitText = AppsOnAirServices.shared.btnSubmitText
        Vc?.btnSubmitTextColor = AppsOnAirServices.shared.btnSubmitTextColor
        Vc?.btnSubmitBackgroundColor = AppsOnAirServices.shared.btnSubmitBackgroundColor
        
        self.presentScreenFromTop(Vc ?? UIViewController())
    }
}

// MARK: - EXTENSION UIView
extension UIView {
    /*===================================================
     * function Purpose: CAPTURE SNAPSHOT OF SCREEN
     ===================================================*/
    ///capture screen snapshot
    func takeScreenshot() -> UIImage? {
        // Get the screen bounds including the status bar
        let screenBounds = UIScreen.main.bounds
        
        // Begin image context
        UIGraphicsBeginImageContextWithOptions(screenBounds.size, false, UIScreen.main.scale)
        
        // Render the window's layer into the current context
        UIApplication.shared.windows.forEach { window in
            window.drawHierarchy(in: screenBounds, afterScreenUpdates: true)
        }
        
        // Get the captured image
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        // End image context
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    /*===================================================
     * function Purpose: ADD BOTTOM SHADOW TO VIEW
     ===================================================*/
    ///set shadow in bottom of view
    func addShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 2)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,y: bounds.maxY - layer.shadowRadius,
                                                         width: bounds.width,
                                                         height: layer.shadowRadius)).cgPath
    }
    
    // OLD
     func addShadows(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0,
                   cornerRadiusIs:CGFloat = 0.0) {
        
            layer.cornerRadius = cornerRadiusIs
            layer.shadowColor = shadowColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
        
    }
    
    func addCornerRadius(color: UIColor = UIColor.lightGray, raduis: CGFloat?)  {
        self.layer.cornerRadius = raduis ?? 8.0
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true 
        self.layer.borderColor = color.cgColor
    }
    
    /*===================================================
     * function Purpose: ROUND CORNERS ON SPECIFIC SIDES
     ===================================================*/
    ///set round corrners on specific side
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
    }

}

// MARK: - EXTENSION UIDevice
extension UIDevice {
    
        var modelIdentifier: String {
            #if targetEnvironment(simulator)
            if let simDeviceName = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
                return "Simulator (\(simDeviceName))"
            } else {
                return "Simulator"
            }
            #else
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
            #endif
        }
    
}

// MARK: - EXTENSION UIApplication
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
