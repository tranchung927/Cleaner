//
//  wifiStoryboard.swift
//  Cleaner
//
//  Created by Luyen on 10/3/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class WifiVC: UIViewController  {
    
    override func viewDidLoad() {
        GoogleAdMob.sharedInstance.initializeBannerView()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
