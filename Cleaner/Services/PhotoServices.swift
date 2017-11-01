//
//  PhotoServices.swift
//  Cleaner
//
//  Created by Truong Thang on 10/31/17.
//  Copyright © 2017 BaBaBiBo. All rights reserved.
//

import UIKit
import Photos

class PhotoServices : NSObject {
    static let shared : PhotoServices = PhotoServices()
    var isFetching : Bool = true
    fileprivate let concurrentCleanerAssetQueue =
        DispatchQueue(
            label: "com.bababibo.CleanerAsset.cleanerAssetQueue",
            attributes: .concurrent)
    var fetchResult : PHFetchResult<PHAsset>?
    private var _displayedAssets : [CleanerAsset] = []
    weak var changeObserver : PHPhotoLibraryChangeObserver? {
        didSet {
            if changeObserver != nil {
                PHPhotoLibrary.shared().register(changeObserver!)
            } else {
                guard oldValue != nil else {return }
                PHPhotoLibrary.shared().unregisterChangeObserver(oldValue!)
            }

        }
    }
    var displayedAssets : [CleanerAsset] {
        var displayedAssetsCopy : [CleanerAsset]!
        concurrentCleanerAssetQueue.sync {
            displayedAssetsCopy = self._displayedAssets
        }
        return displayedAssetsCopy
    }
    
    func addCleanerAsset(_ cleanerAsset : CleanerAsset) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            self._displayedAssets.append(cleanerAsset)
        }
    }
    
    func removeCleanerAsset(_ cleanerAsset : CleanerAsset) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            self._displayedAssets.remove(object: cleanerAsset)
        }
        
    }
    func insertCleanerAsset(at index: Int) {
        concurrentCleanerAssetQueue.async(flags: .barrier) {
            let cleanerAsset = CleanerAsset(asset: self.fetchResult!.object(at: index))
            self._displayedAssets.insert(cleanerAsset, at: index)
        }
    }
    
    override init() {
        super.init()
        reqestAuthorization()
        
    }
    
    func reqestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
               self.fetchAsset()
            case .denied:
                fallthrough
            case .notDetermined:
                fallthrough
            case .restricted:
                showAlertToAccessAppFolder(title: "No Photo Permissions", message: "Please grant photo permissions in Settings")
            }
        }
    }
    
    
    func fetchAsset() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        updateDisplayedAssets()
    }
    
    func updateDisplayedAssets() {
        guard let count = fetchResult?.count, count > 0 else { return }
        let downloadGroup = DispatchGroup()
        for index in 0 ..< count {
            downloadGroup.enter()
            _displayedAssets.append(CleanerAsset(asset: fetchResult!.object(at: index), completeBlock: {
                downloadGroup.leave()
                NotificationCenter.default.post(name: NotificationName.didFinishFetchPHAsset, object: nil)
            }))
        }
        hideActivity()
        downloadGroup.notify(queue: DispatchQueue.main) {
            self._displayedAssets = self._displayedAssets.sorted(by: {$0.fileSize > $1.fileSize})
            NotificationCenter.default.post(name: NotificationName.didFinishFetchPHAsset, object: nil)
            self.isFetching = false
            
        }
    }
}

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}


