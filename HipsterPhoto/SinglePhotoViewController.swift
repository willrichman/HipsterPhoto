//
//  ViewController.swift
//  HipsterPhoto
//
//  Created by William Richman on 10/14/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import OpenGLES
import CoreData

class SinglePhotoViewController: UIViewController, GalleryDelegate, PhotoFrameworkDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterCollectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    var ciContext : CIContext?
    var originalThumbnail : UIImage?
    //core data array
    var filters = [Filter]()
    //array of thumbnail wrapper objects
    var filterThumbnails = [FilterThumbnail]()
    var managedObjectContext : NSManagedObjectContext?
    let imageQueue = NSOperationQueue()
    var enterPress : UITapGestureRecognizer?
    var exitPress : UITapGestureRecognizer?
    var originalImage : UIImage?
    var filteredImage : UIImage?
    let scale = UIScreen.mainScreen().scale
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.originalImage = self.imageView.image
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        var seeder = CoreDataSeeder(context: self.managedObjectContext!)
        

        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.ciContext = CIContext(EAGLContext: myEAGLContext, options: options)

        self.fetchFilters()
        if filters.isEmpty {
            seeder.seedCoreData()
            self.fetchFilters()
        }
        
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.delegate = self
        
        self.generateThumbnail()
        
        self.enterPress = UITapGestureRecognizer(target: self, action: Selector("enterFilterMode:"))
        self.exitPress = UITapGestureRecognizer(target: self, action: Selector("exitFilterMode:"))
        self.imageView.addGestureRecognizer(enterPress!)
        self.resetFilterThumbnails()

    }
    
    //MARK: - Collection View Handler
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterViewCell
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        if filterThumbnail.filteredThumbnail != nil {
            cell.filterViewImage.image = filterThumbnail.filteredThumbnail
        } else {
            cell.filterViewImage.image = filterThumbnail.originalThumbnail
            
            filterThumbnail.generateThumbnail({ (image) -> Void in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterViewCell {
                    cell.filterViewImage.image = image
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let filterSelected = self.filterThumbnails[indexPath.row]
        println("Fired filter")
        filterSelected.applyFilter(self.originalImage!, completionHandler: { (filteredImage) -> Void in
            self.imageView!.image = filteredImage
            self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 3
            self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 3
            self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 3
            self.filterCollectionViewBottomConstraint.constant = -100
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            
            self.imageView.removeGestureRecognizer(self.exitPress!)
            self.imageView.addGestureRecognizer(self.enterPress!)
            self.filteredImage = filteredImage
        })
    }
    
    // MARK: - Navigation/Menus
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
//            if filteredImage != nil {
//                destinationVC.images.append(self.filteredImage!)
//            }
        }
        if segue.identifier == "SHOW_PHOTOS_FRAMEWORK" {
            let destinationVC = segue.destinationViewController as PhotoFrameworkViewController
            destinationVC.delegate = self
            let imageSize = self.imageView.frame.size
            destinationVC.assetLargeImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale)
        }
        else {
        
        }
    }
    
    func didTapOnPicture(image : UIImage) {
        self.imageView.image = image
        self.originalImage = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
    }
    
    @IBAction func photosPressed(sender: AnyObject) {
        
        /* Configure an alert controller for this button */
        let alertController = UIAlertController(title: nil, message: "Choose an option.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let photosAction = UIAlertAction(title: "Photos", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_PHOTOS_FRAMEWORK", sender: self)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (action) -> Void in
            imagePicker.allowsEditing = true
            if UIDevice.currentDevice().model == "iPhone Simulator" {
                imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            }
            else {
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        
        /* Add actions to the controller and present it */
        alertController.addAction(galleryAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            alertController.addAction(cameraAction)
        }
        alertController.addAction(photoLibraryAction)
        alertController.addAction(photosAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        self.generateThumbnail()
        self.resetFilterThumbnails()
    }
    
    // MARK: - Filter Functions
    
    func generateThumbnail () {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func fetchFilters() {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        let fetchResults = self.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            println("filters: \(filters.count)")
            self.filters = filters
        }
    }
    
    func resetFilterThumbnails () {
        var newFilters = [FilterThumbnail]()
        for var index = 0; index < self.filters.count; ++index {
            let filter = filters[index]
            let filterName = filter.name
            var thumbnail = FilterThumbnail(name: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.ciContext!)
            newFilters.append(thumbnail)
        }
        println("New Thumbnails!")
        self.filterThumbnails = newFilters
        self.filterCollectionView.reloadData()
    }
    
    func enterFilterMode(recognizer: UITapGestureRecognizer) {
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant * 3
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * 3
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * 3
        self.filterCollectionViewBottomConstraint.constant = 100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        self.imageView.removeGestureRecognizer(self.enterPress!)
        self.imageView.addGestureRecognizer(self.exitPress!)
    }
    
    
    func exitFilterMode(recognizer: UITapGestureRecognizer?) {
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 3
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 3
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 3
        self.filterCollectionViewBottomConstraint.constant = -100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        self.imageView.removeGestureRecognizer(self.exitPress!)
        self.imageView.addGestureRecognizer(self.enterPress!)
    }

}