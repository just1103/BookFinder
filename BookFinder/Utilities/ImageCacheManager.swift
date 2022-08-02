//
//  ImageCacheManager.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

final class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private let memoryWarningNotification = UIApplication.didReceiveMemoryWarningNotification // TODO: eviction 적용
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(removeAll),
            name: memoryWarningNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: memoryWarningNotification, object: nil)
    }
    
    @objc func removeAll() {
        ImageCacheManager.shared.removeAllObjects()
    }
}
