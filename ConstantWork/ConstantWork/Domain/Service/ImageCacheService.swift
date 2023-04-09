//
//  ImageCacheService.swift
//  ConstantWork
//
//  Created by juntaek.oh on 2023/04/09.
//

import UIKit

final class ImageCacheService {
    
    static let cache: NSCache<NSString, UIImage> = .init()
    static let path: String? = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    
    static func saveImageToCache(with key: String, image: UIImage?) {
        guard let image else {
            #if DEBUG
            print("Can not sampled Image with url")
            #endif
            
            return
        }
        
        cache.setObject(image, forKey: key as NSString)
        #if DEBUG
        print("Sampled Image saved in cache successly")
        #endif
    }
    
    static func loadImageFromCache(with key: String) -> UIImage? {
        guard let cachedImage = cache.object(forKey: key as NSString) else {
            #if DEBUG
            print("No image in cache")
            #endif
            
            return nil
        }
        
        #if DEBUG
        print("Fetch Image from cache")
        #endif
        
        return cachedImage
    }
    
    static func samplingImage(at imageURL: URL, to pointSize: CGSize, with scale: CGFloat) -> UIImage? {
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
                
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOption) else { return nil }
        
        let maxPixelSize = max(pointSize.width, pointSize.height) * scale
        
        let downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceShouldCacheImmediately: true, kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize:maxPixelSize] as CFDictionary
                
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
                
        return UIImage(cgImage: downsampledImage)
    }
}
