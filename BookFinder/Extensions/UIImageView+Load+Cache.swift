//
//  UIImageView+Load+Cache.swift
//  BookFinder
//
//  Created by Hyoju Son on 2022/07/31.
//

import UIKit

extension UIImageView {
    func loadCachedImage(of key: String) {
        let cacheKey = NSString(string: key)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        DispatchQueue.global().async {
            guard
                let url = URL(string: key),
                var urlCompoentns = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { return }
            
            urlCompoentns.scheme = "https"
            
            guard
                let imageURL = urlCompoentns.url,
                let imageData = try? Data(contentsOf: imageURL),
                let loadedImage = UIImage(data: imageData)
            else { return }
            
            ImageCacheManager.shared.setObject(loadedImage, forKey: cacheKey)
            
            DispatchQueue.main.async { [weak self] in
                self?.image = loadedImage
            }
        }
    }
}
