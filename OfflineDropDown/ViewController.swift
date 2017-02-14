//
//  ViewController.swift
//  OfflineDropDown
//
//  Created by ZackTvZ on 06/02/2017.
//  Copyright © 2017 ZackTvZ. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ViewController: UIViewController {
    
    let defaultMessage:[String] = ["message 1", "message 2", "message 3"]
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func showSuccess(_ sender: Any) {
        if(self.messageTextField.text?.isEmpty == true){
            for message in defaultMessage{
                STAlertController.presentSTAlert(stAlertType: .STAlertSuccess, stAlertDisplayType: .STAlertDisplayTypeTop, message: message)
            }
        }else{
            STAlertController.presentSTAlert(stAlertType: .STAlertSuccess, stAlertDisplayType: .STAlertDisplayTypeTop, message: self.messageTextField.text!)
        }
    }
    
    @IBAction func showError(_ sender: Any) {
        if(self.messageTextField.text?.isEmpty == true){
            for message in defaultMessage{
                STAlertController.presentSTAlert(stAlertType: .STAlertError, stAlertDisplayType: .STAlertDisplayTypeTop, message: message)
            }
        }else{
            STAlertController.presentSTAlert(stAlertType: .STAlertError, stAlertDisplayType: .STAlertDisplayTypeTop, message: self.messageTextField.text!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    @IBAction func showOffline(_ sender: Any) {
        OfflineNotification.sharedInstance.showOfflineMode()
    }

    @IBAction func hideOffline(_ sender: Any) {
        OfflineNotification.sharedInstance.hideOfflineMode()
    }
}

extension ViewController: NetworkStatusListener {
    
    func networkStatusDidChange(status: Reachability.NetworkStatus) {
        
        switch status {
        case .notReachable:
            print("ViewController: Network became unreachable")
        case .reachableViaWiFi:
            print("ViewController: Network reachable through WiFi")
        case .reachableViaWWAN:
            print("ViewController: Network reachable through Cellular Data")
        }
    }
}
