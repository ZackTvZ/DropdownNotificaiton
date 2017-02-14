//
//  STAlertTypeViewController.swift
//  OfflineDropDown
//
//  Created by ZackTvZ on 07/02/2017.
//  Copyright © 2017 ZackTvZ. All rights reserved.
//

import UIKit

class STAlertTypeViewController: UIViewController {
    @IBOutlet var successView: UIView!
    @IBOutlet var errorView: UIView!
    @IBOutlet var popoverView: UIView!
    
    var oriHeight:CGFloat?
    var stAlertType:STAlertType = .STAlertSuccess
    var stAlertDisplayType:STAlertDisplayType = .STAlertDisplayTypeTop
    var stDismissType:STDismissType = .STDismissFromTop
    var duration:TimeInterval?
    var showDuration:TimeInterval?
    var topView:UIViewController?
    var message:String = ""
    var didTapCloseBlock:STAlertController.TapClose?
    
    
    
    var oriYGap:CGFloat = 10.0
    
    convenience init(stAlertType: STAlertType, message: String) {
        self.init()
        self.stAlertType = stAlertType
        self.message = message
    }
    
    convenience init(stAlertType: STAlertType,
                     stAlertDisplayType: STAlertDisplayType,
                     message: String,
                     duration: TimeInterval,
                     showDuration: TimeInterval,
                     topView: UIViewController,
                     tapClose: STAlertController.TapClose?) {
        self.init()
        self.stAlertType = stAlertType
        self.stAlertDisplayType = stAlertDisplayType
        self.message = message
        self.duration = duration
        self.showDuration = showDuration
        self.topView = topView
        self.didTapCloseBlock = tapClose
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(self.stAlertType != .STAlertPopover){
            self.setupDisplayType()
            self.setupTouchEvent()
            
            let label:UILabel = self.view.viewWithTag(1) as! UILabel
            label.text = self.message
        }else{
            self.setupPopoverDisplayType()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Display type
    func setupDisplayType(){
        switch self.stAlertType {
        case .STAlertSuccess:
            self.view = self.successView
            break;
        case .STAlertError:
            self.view = self.errorView
            break;
        default:
            break;
        }
        
        var rect = self.view.frame
        rect.size.width = UIScreen.main.bounds.size.width - 20
        rect.origin.x = 10
        rect.origin.y = 10
        self.view.frame = rect
        self.oriHeight = self.view.frame.size.height
        
        self.view.layer.borderWidth = 1.0
        self.view.layer.borderColor = UIColor.clear.cgColor
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
    }
    
    // MARK: - Popover Display type
    func setupPopoverDisplayType(){
        self.view = self.popoverView
        
        let label:UILabel = self.view.viewWithTag(1) as! UILabel
        label.text = self.message
        
        var rect = label.frame
        rect.size.width = self.preferredContentSize.width
        label.frame = rect
        label.sizeToFit()
        
        rect = self.view.frame
        rect.size.width = label.frame.size.width + 20
        rect.size.height = label.frame.size.height + 20
        self.view.frame = rect
        
        self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.oriHeight = self.view.frame.size.height
    }
    
    // MARK: - Popover Display type
    func setupTouchEvent(){
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(close))
        self.view.addGestureRecognizer(tapRecognizer)
        
        let swipeUp = UITapGestureRecognizer.init(target: self, action: #selector(close))
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeLeft = UITapGestureRecognizer.init(target: self, action: #selector(close))
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UITapGestureRecognizer.init(target: self, action: #selector(close))
        self.view.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - show shadow
    func showShadow(){
        self.view.layer.masksToBounds = false
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.1
        self.view.layer.shadowRadius = 4.0
        self.view.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
    }
    
    // MARK: - Close
    
    func fadeMeOut(){
        STAlertController.sharedInstance.performSelector(onMainThread: #selector(STAlertController.fadeOutNotification(_:)), with: self, waitUntilDone: false)
    }
    
    func closeFromLeft(){
        self.stDismissType = .STDismissFromLeft
        self.close()
    }
    
    func closeFromRight(){
        self.stDismissType = .STDismissFromRight
        self.close()
    }
    
    func close(){
        if(self.didTapCloseBlock != nil){
            self.didTapCloseBlock!()
        }
        self.fadeMeOut()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
