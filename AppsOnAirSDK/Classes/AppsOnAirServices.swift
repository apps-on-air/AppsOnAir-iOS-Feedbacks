//
//  UpdateManager.swift
//  AppUpdateManager
//
//  Created by lw-66 on 29/09/22.
//

import Foundation
import UIKit
import AVFoundation
import IQKeyboardManagerSwift

public class AppsOnAirServices {
    public static let shared = AppsOnAirServices()
    
    private var appId: String = ""
    private var window: UIWindow?
    
    /// set navigationbar color (hex value eg: 000000)
    var navBarColor: String?
    
    /// set navigationbar title text
    var navBarTitle: String?
    
    /// set navigationbar title color (hex value eg: 000000)
    var navBarTitleTextColor: String?
    
    /// Set background color (hex value eg: 000000)
    var backgroundColor: String?
    
    /// set labelTicket text
    var labelTextColor: String?
    
    /// set inputfields hint text color
    var inputHintTextColor: String?
    
    /// set description field char limit (default 255)
    var txtDescriptionCharLimit: Int?
    
    /// set description hint text
    var txtDescriptionHintText: String?
    
    /// set btnSubmit text
    var btnSubmitText: String?
    
    /// set btnSubmit text color
    var btnSubmitTextColor: String?
    
    /// set btnSubmit background color
    var btnSubmitBackgroundColor: String?
    
    /// set Additional params while init
    var additionalParams: [String:String]?
    
    public func setAppId(_ appId: String) -> (Void) {
        self.appId = appId;
     
    }
    
    /// setup feedback screen 
    public func setupFeedbackScreen(backgroundColor: String? = nil, navBarColor: String? = nil,navBarTitle: String? = nil, navBarTitleTextColor: String? = nil,  labelTextColor: String? = nil, inputHintTextColor: String? = nil, descriptionCharLimit: Int? = nil,txtDescriptionHintText: String? = nil,  btnSubmitText: String? = nil, btnSubmitTextColor: String? = nil, btnSubmitBackgroundColor: String? = nil, additionalParams:[String:String]? = nil) {
    
        self.navBarColor = navBarColor
        self.navBarTitle = navBarTitle
        self.navBarTitleTextColor = navBarTitleTextColor
        
        self.backgroundColor = backgroundColor
        
        self.labelTextColor = labelTextColor
        self.inputHintTextColor = inputHintTextColor
        
        self.txtDescriptionCharLimit = descriptionCharLimit
        
        self.txtDescriptionHintText = txtDescriptionHintText
        
        self.btnSubmitText = btnSubmitText
        self.btnSubmitTextColor = btnSubmitTextColor
        self.btnSubmitBackgroundColor = btnSubmitBackgroundColor
        
        self.additionalParams = additionalParams
        
        _ = UIViewController.classInit
        IQKeyboardManager.shared.enable = true
        
        
    }
    
    
    public func openFeedbackScreen() {
        if let topViewController = UIApplication.topViewController(){
            topViewController.showFeedbackScreen()
        }
    }
    
}
