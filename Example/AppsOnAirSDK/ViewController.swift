//
//  ViewController.swift
//  AppsOnAirSDK
//
//  Created by nikesh8 on 11/24/2022.
//  Copyright (c) 2022 nikesh8. All rights reserved.
//

import UIKit
import AppsOnAir

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
            let appUpdateManager = AppsOnAirServices()
            Please replace your APP_ID from https://appsonair.com
            appUpdateManager.setAppId(APP_ID: "XXXXX-XXXX-XXXX-XXXX-XXXXXXXX", showNativeUI: true/false)
            appUpdateManager.setAppId("XXXXX-XXXX-XXXX-XXXX-XXXXXXXX")
        */
        
        AppsOnAirServices.shared.setAppId("XXXXX-XXXX-XXXX-XXXX-XXXXXXXX")
        AppsOnAirServices.shared.setupFeedbackScreen(btnSubmitText: "Save",additionalParams: ["environment":"Development"])
        
        // OPEN SCREEN FROM USER ACTION
        let button:UIButton = UIButton(frame: CGRectMake(100, 400, 100, 50))
        button.setTitle("Button", for: .normal)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        self.view.addSubview(button)
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonClicked(_ sender: Any?) {
        AppsOnAirServices.shared.openFeedbackScreen()
    }

}

