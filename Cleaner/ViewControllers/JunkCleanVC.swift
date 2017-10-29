//
//  JunkCleanVC.swift
//  Cleaner
//
//  Created by Hao on 10/2/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit

class JunkCleanVC: UIViewController,CAAnimationDelegate {
    
    @IBOutlet weak var middleView: View!
    @IBOutlet weak var biggerView: View!
    @IBOutlet weak var UnderView: GradientView!
    @IBOutlet weak var AboveView: GradientView!
    @IBOutlet weak var freeDiskLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var coverButton: Button!
    @IBOutlet weak var SpaceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    // Mark: Properties
    var gradient: CAGradientLayer!
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var hander : Bool = true {
        didSet{
            if currentColorSet < colorSets.count - 1 {
                currentColorSet! += 1
            }
            else {
                currentColorSet = 0
            }
            let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
            colorChangeAnimation.repeatCount = 100
            colorChangeAnimation.duration = 3.0
            colorChangeAnimation.toValue = colorSets[currentColorSet]
            colorChangeAnimation.fillMode = kCAFillModeForwards
            colorChangeAnimation.isRemovedOnCompletion = false
            colorChangeAnimation.delegate = self
            gradient.add(colorChangeAnimation, forKey: "color")
        }
    }
    var storeageReduce: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.freeDiskLabel.text  = ByteCountFormatter.string(fromByteCount: Int64(SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace), countStyle: .binary)
        storeageReduce = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.createColorSets()
        self.createGradientLayer()
    }
    // Mark: Clear Cache Memory
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    var isNeedToChange: Bool = true {
        didSet {
            if isNeedToChange {
                self.SpaceLabel.isHidden = true
                self.availableLabel.isHidden = true
                biggerView.backgroundColor = UIColor.clear
                self.changeLabel.text = " Getting the data .... Please wait!"
                self.freeDiskLabel.text = "    Loading ...    "
                coverButton.isEnabled = false
            } else {
                let systemChange = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace > storeageReduce ? SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace - storeageReduce : storeageReduce - SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace
                let systemReduce = ByteCountFormatter.string(fromByteCount: Int64(systemChange), countStyle: .binary)
                let storageChange = SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace > storeageReduce ? SystemServices.shared.diskSpaceUsage(inPercent: false).freeDiskSpace :
                storeageReduce
                self.freeDiskLabel.alpha = 1
                self.freeDiskLabel.text  = ByteCountFormatter.string(fromByteCount: Int64(storageChange), countStyle: .binary)
                self.SpaceLabel.isHidden = false
                self.availableLabel.isHidden = false
                coverButton.isEnabled = true
                coverButton.setTitle("FINISH", for: .normal)
                self.showAlertCompelete(vc: self, title: "Do you want go to setting manage?", message: "The process is complete! Storage reduced \(systemReduce) but some items with private content can not be removed!")
            }
        }
    }
    // Mark: Active
    @IBAction func clickAndRunBoost(_ sender: UIButton) {
        if sender.currentTitle == "CLEAN" {
            self.chosenAll()
            clearTempFolder()
            isNeedToChange = true
//            showAlert(vc: self, title: "Warning!", message: "You want go to Settings?")
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .curveLinear] , animations: {
                self.changeAlpha(label: self.changeLabel)
                self.changeAlpha(label: self.markLabel)
            }) { (_) in
            }
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .curveLinear] , animations: {
                self.changeAlpha(label: self.freeDiskLabel)
            }) { (_) in
            }
            let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(7)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
             self.runBoost()
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    // - create active when finish
    @objc func runBoost() {
        isNeedToChange = false
    }
    // Create Alert
    // - Show setting
    func showAlert(vc: UIViewController, title:String, message: String) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: "App-Prefs:root=General&path=Keyboard") else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(_) -> Void in
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // - Alert when run out
    func showAlertCompelete(vc: UIViewController, title:String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let goToStorageBackup = UIAlertAction(title: "Setting", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: "App-prefs:root=General&path=STORAGE_ICLOUD_USAGE/DEVICE_STORAGE") else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        let okAction = UIAlertAction(title: "Cancle", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            GoogleAdMob.sharedInstance.showInterstitial()
        }
        alertController.addAction(goToStorageBackup)
        alertController.addAction(okAction)
        vc.present(alertController, animated: true, completion: nil)
    }
}



