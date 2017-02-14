//
//  OfflineNotification.swift
//  OfflineDropDown
//
//  Created by ZackTvZ on 06/02/2017.
//  Copyright © 2017 ZackTvZ. All rights reserved.
//

import UIKit
import ReachabilitySwift

class OfflineNotification: NSObject {
    
    static let sharedInstance = OfflineNotification()
    
    let showView = OfflineNotificationViewController()
    
    var showViewOriHeight:CGFloat = 0.0
    
    var isShowing:Bool = false
    
    override init() {
        super.init()
        showViewOriHeight = showView.view.frame.size.height
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
    
    func getAlertPositionY() -> CGFloat{
        return get_visible_size_top().height
    }
    
    func get_visible_size_top() -> CGSize{
        var result:CGSize!
        var size:CGSize!
        
        size = UIApplication.shared.statusBarFrame.size
        result = size
        
        if(self.topViewController().navigationController != nil){
            size = self.topViewController().navigationController?.navigationBar.frame.size
            result.height = result.height + size.height
        }
        return result
    }
}

// MARK: - dropdown
extension OfflineNotification{
    func showOfflineMode(){
        if(self.isShowing == true){
            hideOfflineMode(animation: false)
        }
        self.isShowing = true
        var rect = self.showView.view.frame
        
        let startY = self.getAlertPositionY()
//        if(self.topViewController().navigationController != nil){
//            rect.origin.y = self.getAlertPositionY()
//            rect.size.height = 0;
//            self.showView.view.frame = rect;
//        }else{
            rect.origin.y = startY - self.showViewOriHeight
            self.showView.view.frame = rect
            rect.origin.y = self.getAlertPositionY()
//        }
        
        let topView = self.topViewController()
        if((topView.navigationController) != nil){
            topView.navigationController?.visibleViewController?.view.addSubview(self.showView.view)
        }
        else if((topView.tabBarController) != nil){
            topView.tabBarController?.view.addSubview(self.showView.view)
        }else{
            topView.view.addSubview(self.showView.view)
        }
        
//        self.showView.view.layer.zPosition = 1
        
        rect.size.height = self.showViewOriHeight;
        UIView.animate(withDuration: 0.25, animations: {
            self.showView.view.frame = rect
        }) { (finished) in
            
        }
        
    }
    func hideOfflineMode(){
        hideOfflineMode(animation: true)
    }
    
    func hideOfflineMode(animation: Bool){
        hideOfflineMode(vc: self.showView, animation: animation)
    }
    
    func hideOfflineMode(vc: OfflineNotificationViewController, animation: Bool){
        var rect = vc.view.frame
        
        let startY = self.getAlertPositionY()
        //        if(self.topViewController().navigationController != nil){
        //            rect.origin.y =  self.getAlertPositionY()
        //            rect.size.height = 0;
        //        }else{
        rect.origin.y = startY - vc.view.frame.size.height
        //        }
        
        if(animation == true){
            UIView.animate(withDuration: 0.25, animations: {
                vc.view.frame = rect
            }) { (finished) in
                vc.view.removeFromSuperview()
                self.isShowing = false
            }
        }else{
            vc.view.frame = rect
            vc.view.removeFromSuperview()
            self.isShowing = false
        }
    
    }

}
