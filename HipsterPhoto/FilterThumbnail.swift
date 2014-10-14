//
//  FilterThumbnail.swift
//  HipsterPhoto
//
//  Created by William Richman on 10/14/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import CoreImage

class FilterThumbnail {
    
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var imageQueue : NSOperationQueue?
    var gpuContext : CIContext
    var filter : CIFilter?
    var filterName : String
    
    init (name : String, thumbnail : UIImage, queue : NSOperationQueue, context : CIContext) {
        self.filterName = name
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }
 
    func generateThumbnail (completionHandler : (image : UIImage) -> Void) {
        
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            /* Setting up your image with a CIImage */
            var image = CIImage(image: self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            /* Generate the results.  The value for key happens lazily, then actually filters in createCGImage */
            var result = imageFilter.valueForKey(kCIOutputImageKey) as? CIImage
            var extent = result!.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.filter = imageFilter
            self.filteredThumbnail = UIImage(CGImage: imageRef)
            
            /* Swap back to main queue to pass back the image */
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: self.filteredThumbnail!)
            })
        })
        
    }
    
    func applyFilter (image : UIImage, completionHandler : (filteredImage : UIImage) -> Void) {
        
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            /* Setting up your image with a CIImage */
            var image = CIImage(image: image)
            self.filter!.setValue(image, forKey: kCIInputImageKey)
            
            /* Generate the results.  The value for key happens lazily, then actually filters in createCGImage */
            var result = self.filter!.valueForKey(kCIOutputImageKey) as? CIImage
            var extent = result!.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            let filteredImage = UIImage(CGImage: imageRef)
            
            /* Swap back to main queue to pass back the image */
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(filteredImage: filteredImage)
            })

        })
    }
    
}