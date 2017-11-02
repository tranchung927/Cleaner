//
//  WifiScanResultVC.swift
//  Cleaner
//
//  Created by Quốc Đạt on 07.10.17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

class WifiScanResultVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NetworkScannerDelegate  {

    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var networkScanner: NetworkScanner!
    private var myContext = 0
    
    @IBOutlet weak var adsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.networkScanner = NetworkScanner(delegate:self)
        self.spinner.startAnimating()
        self.networkScanner.scan()
        self.addObserversForKVO()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        networkScanner.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func addObserversForKVO ()->Void {
        self.networkScanner.addObserver(self, forKeyPath: "connectedDevices", options: .new, context:&myContext)
        self.networkScanner.addObserver(self, forKeyPath: "isScanRunning", options: .new, context:&myContext)
    }
    
    func removeObserversForKVO ()->Void {
        self.networkScanner.removeObserver(self, forKeyPath: "connectedDevices")
        self.networkScanner.removeObserver(self, forKeyPath: "isScanRunning")
    }
    
    
    
    @IBAction func reScan(_ sender: UIButton) {
        self.networkScanner.scan()
        self.spinner.isHidden = false
        self.spinner.startAnimating()
    }
    
    // MARK: NetworkScannerDelegate
    
    func networkScannerIPSearchFinished() {
        showAlert(title: "Scan Finished", message: "Number of devices connected to the Local Area Network : \(self.networkScanner.connectedDevices.count)", completeHandler: {
            GoogleAdMob.sharedInstance.showInterstitial()
        })
        resultLabel.text = "There are \(self.networkScanner.connectedDevices.count) connected to \( self.networkScanner.ssidName ) "
          self.spinner.stopAnimating()
            self.spinner.hidesWhenStopped = true
    }
    
    func networkScannerIPSearchCancelled() {
        self.tableView.reloadData()
    }
    
    func networkScannerIPSearchFailed() {
        showAlert(title: "Please connect to Wi-Fi first", message: "", completeHandler: {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        networkScanner.stop()
        self.spinner.stopAnimating()
        self.spinner.hidesWhenStopped = true
    }
    
    // -MARK: -Table View DataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.networkScanner.connectedDevices!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! WifiScanResultTableViewCell
        let device = self.networkScanner.connectedDevices[indexPath.row]
        cell.deviceIPLabel.text = device.ipAddress
        if indexPath.row == 0{
            cell.deviceNameLabel.text = "Me"
            cell.deviceImageView.image = #imageLiteral(resourceName: "user icon")
        } else {
            cell.deviceNameLabel.text = device.hostname
           cell.deviceImageView.image = #imageLiteral(resourceName: "guest icon")
        }
        return cell
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (context == &myContext) {
            
            switch keyPath! {
            case "connectedDevices":
                self.tableView.reloadData()
                
            case "isScanRunning":

                break
            default:
                print("Not valid key for observing")
            }
            
        }
    }
    
    deinit {
        self.removeObserversForKVO()
    }
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}
