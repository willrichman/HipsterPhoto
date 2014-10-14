//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by William Richman on 10/13/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

protocol GalleryDelegate {
    func didTapOnPicture(image : UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate : GalleryDelegate?
    let imageDownloadQueue = NSOperationQueue()
    
    var images = [UIImage]()
    var header : GalleryHeaderView?
    
    var titles = ["Contagious Potpourri", "Tricky Drone With Caustic Despondency", "Hollow Depression", "Progressive Tenderness", "Moderately Tweaking", "Dreary Androids", "Smugly Operating", "Pervicacious Operations", "Indomitable Power In Our Midst", "Freeze-Dried Cupcakes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        if self.images.isEmpty || indexPath.row > (self.images.count - 1){
            fetchImageForCell({ (errorDescription, returnedImage) -> Void in
                if errorDescription != nil {
                    println(errorDescription)
                }
                else {
                    self.images.append(returnedImage!)
                    cell.galleryCellImage.image = returnedImage!
                }
            })
        }
        
        else {
            cell.galleryCellImage.image = self.images[indexPath.row]
        }
        cell.galleryCellLabel.text = self.titles[Int(arc4random()) % self.titles.count]
        if self.header != nil {
            self.header!.galleryHeaderLabel.text = "100 Images"
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "GALLERY_HEADER", forIndexPath: indexPath) as GalleryHeaderView
        header.galleryHeaderLabel.text = "100 Images"
        self.header = header as GalleryHeaderView
        return header
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("indexpath: \(indexPath.row)")
        self.delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func fetchImageForCell (completionHandler: (errorDescription : String?, returnedImage : UIImage?) -> Void) {
        
        self.imageDownloadQueue.addOperationWithBlock { () -> Void in
            let imageURL = NSURL(string: "http://lorempixel.com/100/100/")
            let imageData = NSData(contentsOfURL: imageURL)
            let imageToReturn = UIImage(data: imageData)
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                completionHandler(errorDescription: nil, returnedImage: imageToReturn)
            }
        }
        
    }
    
    
    
}

