//
//  CoreDataSeeder.swift
//  HipsterPhoto
//
//  Created by William Richman on 10/14/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import Foundation
import CoreData

class CoreDataSeeder {
    var managedObjectContext: NSManagedObjectContext!
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedCoreData () {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gaussianBlur.name = "CIGaussianBlur"
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var noir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        noir.name = "CIPhotoEffectNoir"
        
        var instant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        instant.name = "CIPhotoEffectInstant"

//        var random = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
//        random.name = "CIRandomGenerator"
        
        var vignette = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        vignette.name = "CIVignette"

        var gloom = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gloom.name = "CIGloom"

//        var kaleidoscope = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
//        kaleidoscope.name = "CIKaleidoscope"

        var invert = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        invert.name = "CIColorInvert"
        
//        var pencil = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
//        pencil.name = "CILineOverlay"

        var chrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        chrome.name = "CIPhotoEffectChrome"
        
        var transfer = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        transfer.name = "CIPhotoEffectTransfer"
        
        var monochrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        monochrome.name = "CIColorMonochrome"
        
        var error: NSError?
        self.managedObjectContext?.save(&error)
        
        if error != nil {
            println(error?.localizedDescription)
        }
    }
    
}