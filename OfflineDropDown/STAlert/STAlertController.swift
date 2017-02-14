//
//  STAlertTypeViewController.swift
//  OfflineDropDown
//
//  Created by ZackTvZ on 07/02/2017.
//  Copyright © 2017 ZackTvZ. All rights reserved.
//

import UIKit
enum STAlertType: Int {
    case STAlertSuccess = 1,
    STAlertError,
    STAlertPopover
}

enum STDismissType: Int {
    case STDismissFromTop = 1,
    STDismissFromLeft,
    STDismissFromRight
}

enum STAlertDisplayType: Int {
    case STAlertDisplayTypeTop = 1,
    STAlertDisplayTypeOverlayNavBar,
    STAlertDisplayTypeOverlayNavBar_Custom,
    STAlertDisplayTypeBottom,
    STAlertDisplayTypeOverlayTabBar
}
extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

class STAlertController: NSObject, UIPopoverPresentationControllerDelegate {
    typealias TapClose = ()->()
    
    
    static let sharedInstance = STAlertController()
    
    var showView:STAlertTypeViewController?
    var messages:[STAlertTypeViewController] = []
    var isShowing:Bool = false
    var timer:Timer?
    
    let defaultDuration:TimeInterval = 0.25
    let defaultshowDuration:TimeInterval = 3
    
    override init() {
        super.init()
    }
    
    // MARK: - Popover
    class func popoverErrorMessage(message: String, target: Any, popFrom: Any){
        let vc = STAlertTypeViewController.init(stAlertType: .STAlertPopover, message: message)
        
        let popFromTarget = popFrom as! UIView
        
        vc.preferredContentSize = CGSize(width: popFromTarget.frame.size.width, height: 50)
        
        vc.view.clipsToBounds = true
        vc.modalPresentationStyle = .popover
        
        let popController = vc.popoverPresentationController
        popController?.permittedArrowDirections = .down
        popController?.delegate = self.sharedInstance
        popController?.backgroundColor = vc.view.backgroundColor
        
        popController?.sourceView = (target as! UIViewController).view
        popController?.sourceRect = self.getViewRect(view: popFromTarget, target: target)
        popController?.canOverlapSourceViewRect = false
        (target as! UIViewController).present(vc, animated: true, completion: nil)
    }
    
    class func getViewRect(view: UIView, target: Any) -> CGRect{
        let viewPoint = view.convert(view.bounds.origin, to: (target as! UIViewController).view)
        return CGRect(x: viewPoint.x, y: viewPoint.y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    class func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Show Alert
    //set 1
    class func presentSTAlert(stAlertType: STAlertType, stAlertDisplayType: STAlertDisplayType, message: String){
        self.presentSTAlert(stAlertType: stAlertType, stAlertDisplayType: stAlertDisplayType, message: message, tapClose: nil)
    }
    
    class func presentSTAlert(stAlertType: STAlertType, stAlertDisplayType: STAlertDisplayType, message: String, tapClose: TapClose?){
        self.presentSTAlert(stAlertType: stAlertType, stAlertDisplayType: stAlertDisplayType, message: message, tapClose: tapClose, duration: self.sharedInstance.defaultDuration)
    }
    
    class func presentSTAlert(stAlertType: STAlertType, stAlertDisplayType: STAlertDisplayType, message: String, tapClose: TapClose?, duration: TimeInterval){
        self.presentSTAlert(stAlertType: stAlertType, stAlertDisplayType: stAlertDisplayType, message: message, tapClose: tapClose, duration: self.sharedInstance.defaultDuration, showDuration: self.sharedInstance.defaultshowDuration)
    }
    
    class func presentSTAlert(stAlertType: STAlertType, stAlertDisplayType: STAlertDisplayType, message: String, tapClose: TapClose?=nil, duration: TimeInterval, showDuration: TimeInterval){
        let vc = STAlertTypeViewController.init(stAlertType: stAlertType, stAlertDisplayType: stAlertDisplayType, message: message, duration: duration, showDuration: showDuration, topView: self.sharedInstance.topViewController(), tapClose: tapClose)
        self.prepareNotificationToBeShown(messageView: vc)
    }
    
    class func prepareNotificationToBeShown(messageView: STAlertTypeViewController){
        for vc in self.sharedInstance.messages{
            if(vc.message == messageView.message){
                return
            }
        }
        
        self.sharedInstance.messages.append(messageView)
        
        if(self.sharedInstance.isShowing == false){
            self.sharedInstance.showAlert()
        }
    }
    
    func showAlert(){
        if(self.messages.count == 0){
            return
        }
        
        self.showView = self.messages[0] as STAlertTypeViewController
        
        if(self.showView?.topView.self != self.topViewController().self){
            self.prepareForNextMessage()
            return
        }
        
        self.isShowing = true
        
        var rect = self.showView?.view.frame
        if(self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar || self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar_Custom){
            rect?.origin.y = 0 - (self.showView?.oriHeight)!
            self.showView?.view.frame = rect!;
            rect?.origin.y = self.getSTAlertPositionY() + (self.showView?.oriYGap)!
        }else{
            rect?.origin.y = self.getSTAlertPositionY() + (self.showView?.oriYGap)!
            rect?.size.height = 0
            self.showView?.view.frame = rect!
        }
        
        if(self.showView?.topView?.navigationController != nil && (self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar || self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar_Custom)){
            self.showView?.topView?.navigationController?.view.addSubview((self.showView?.view)!)
        }else if(self.showView?.topView?.tabBarController != nil && self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayTabBar){
            self.showView?.topView?.tabBarController?.view.addSubview((self.showView?.view)!)
        }else{
            self.showView?.topView?.view.addSubview((self.showView?.view)!)
        }
        
        self.showView?.view.layer.zPosition = 1
        if(self.showView?.stAlertDisplayType == .STAlertDisplayTypeBottom || self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayTabBar){
            rect?.origin.y = (rect?.origin.y)! - (self.showView?.oriHeight)!
        }
        rect?.size.height = (self.showView?.oriHeight)!
        UIView.animate(withDuration: (self.showView?.duration)!, animations: {
            if(self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar || rect?.origin.y == 0){
                UIApplication.shared.delegate?.window??.windowLevel = UIWindowLevelStatusBar+1
            }
            self.showView?.view.frame = rect!
        }) { (finished) in
            self.showView?.showShadow()
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: (self.showView?.showDuration)!, target: self, selector: #selector(self.dismissAlert(timer:)), userInfo: ["animation" :true], repeats: false)
        }
    }
    
    // MARK: - Dismiss
    func fadeOutNotification(_ currentView: STAlertTypeViewController){
        if(currentView == self.showView && self.timer?.isValid == true){
            self.timer?.invalidate()
            self.dismissAlert()
        }
    }
    
    func dismissAlert(){
        self.dismissAlert(animation: true)
    }
    
    func dismissAlert(timer: Timer){
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let animation:Bool = (userInfo["animation"] as! Bool)
        self.dismissAlert(animation: animation)
    }
    
    func dismissAlert(animation: Bool){
        var rect = self.showView?.view.frame
        if(self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar || self.showView?.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar_Custom){
            if(self.showView?.stDismissType == .STDismissFromLeft){
                rect?.origin.x = -(self.showView?.view.frame.size.width)!
            }else if(self.showView?.stDismissType == .STDismissFromRight){
                rect?.origin.x = UIScreen.main.bounds.size.width
            }else{
                rect?.origin.y = 0 - (self.showView?.view.frame.size.height)!
            }
        }else{
            rect?.origin.y = self.getSTAlertPositionY()
            rect?.size.height = 0
        }
        
        if(animation == true){
            UIView.animate(withDuration: (self.showView?.duration)!, animations: {
                self.showView?.view.frame = rect!
            }) { (finished) in
                self.showView?.view.removeFromSuperview()
                self.prepareForNextMessage()
            }
        }else{
            self.showView?.view.frame = rect!
            self.showView?.view.removeFromSuperview()
            self.prepareForNextMessage()
        }
    }
    
    func prepareForNextMessage(){
//        self.messages.remove(at: self.showView!)
        self.messages.remove(object: self.showView!)
        self.isShowing = false
        self.showAlert()
    }
    
    // MARK: - get top view controller
    func topViewController() -> UIViewController{
        return topViewControllerWithRootViewController(rootViewContoller: (UIApplication.shared.keyWindow?.rootViewController)!)
    }
    
    func topViewControllerWithRootViewController(rootViewContoller: UIViewController) -> UIViewController{
        if(rootViewContoller.isKind(of: UITabBarController.self)){
            let tabbarController:UITabBarController = rootViewContoller as! UITabBarController
            return topViewControllerWithRootViewController(rootViewContoller: tabbarController.selectedViewController!)
        }else if(rootViewContoller.isKind(of: UINavigationController.self)){
            let naviController:UINavigationController = rootViewContoller as! UINavigationController
            return topViewControllerWithRootViewController(rootViewContoller: naviController.visibleViewController!)
        }else if(rootViewContoller.presentedViewController != nil){
            let viewController:UIViewController = rootViewContoller
            return topViewControllerWithRootViewController(rootViewContoller: viewController)
        }else{
            return rootViewContoller
        }
    }
    
    func getSTAlertPositionY() -> CGFloat{
        //top
        let vcParent = self.showView?.topView?.parent
        if(vcParent?.isKind(of: UITabBarController.self) == true){
            return (vcParent?.presentingViewController?.view.frame.origin.y)!
        }else if(vcParent?.isKind(of: UINavigationController.self) == true){
            return (self.showView!.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar || self.showView!.stAlertDisplayType == .STAlertDisplayTypeOverlayNavBar_Custom) ? 0 : self.get_visible_size_top().height
        }else if((vcParent?.presentedViewController) != nil){
            return (vcParent?.presentedViewController!.view.frame.origin.y)!
        }else{
            return 0
        }
        
        return get_visible_size_top().height
    }
    
    func get_visible_size_top() -> CGSize{
        var result:CGSize!
        var size:CGSize!
        
        size = UIApplication.shared.statusBarFrame.size
        result = size
        
        if(self.showView?.topView?.navigationController != nil){
            size = self.showView?.topView?.navigationController?.navigationBar.frame.size
            result.height = result.height + size.height
        }
        return result
    }
    
    func get_visible_size_bottom() -> CGSize{
        var result:CGSize!
        var size:CGSize!
        
        size = UIScreen.main.bounds.size
        result = size
        
        if(self.topViewController().navigationController != nil){
            size = self.showView?.topView?.tabBarController?.tabBar.frame.size
            result.height = result.height - min(size.width, (self.showView?.topView?.tabBarController?.tabBar.isHidden)! ? 0 : size.height);
        }
        return result
    }
}
