//
//  OfflineNotificationViewController.swift
//  OfflineDropDown
//
//  Created by ZackTvZ on 06/02/2017.
//  Copyright © 2017 ZackTvZ. All rights reserved.
//

import UIKit

class OfflineNotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var rect = self.view.frame
        rect.size.width = UIScreen.main.bounds.size.width
        self.view.frame = rect;
        
        setupTouchEvent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close(){
        OfflineNotification.sharedInstance.hideOfflineMode(vc: self, animation: true)
    }
    
    // MARK: - Touch Event
    func setupTouchEvent() {
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(close))
        self.view.addGestureRecognizer(tapRecognizer)
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
