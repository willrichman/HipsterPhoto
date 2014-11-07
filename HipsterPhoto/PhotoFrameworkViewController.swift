//
//  PhotoFrameworkViewController.swift
//  HipsterPhoto
//
//  Created by William Richman on 10/15/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import Photos

class PhotoFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var assetFetchResults: PHFetchResult!
    var assetCollection : PHAssetCollection!
    var imageManager: PHCachingImageManager!
    var assetCellSize: CGSize!
    var delegate : ImageSelectDelegate?
    var assetLargeImageSize : CGSize!
    let scale = UIScreen.mainScreen().scale
    var header : PhotosHeaderView?
    var flowLayout: UICollectionViewFlowLayout!
    var frameworkQueue = NSOperationQueue()
    var origin: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        /* Get image manager, and asset fetch results */
        self.imageManager = PHCachingImageManager()
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        /* Adjust asset cell size */
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
        var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.collectionView.addGestureRecognizer(pinchRecognizer)
        
    }
    
    //MARK: - Collection View Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTOS_CELL", forIndexPath: indexPath) as PhotoFrameworkCell
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            if cell.tag == currentTag {
                cell.imageView.image = image
            }
        }
        
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PHOTOS_HEADER", forIndexPath: indexPath) as PhotosHeaderView
        header.label.text = "\(self.assetFetchResults.count) Photos"
        self.header = header as PhotosHeaderView
        return header
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let attributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let origin = self.view.convertRect(attributes!.frame, fromView: collectionView)
        println("origin: \(origin)")
        println("indexpath: \(indexPath.row)")
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetLargeImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image: UIImage!, info) -> Void in
            self.delegate?.didTapOnPicture(image)
            return(  )
        }
//        
//        self.dismissViewControllerAnimated(true, completion: { () -> Void in
//        })
    }
    
    //MARK: - GestureRecognizer Handler
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            self.collectionView.performBatchUpdates({ () -> Void in
                var currentSize = self.flowLayout.itemSize
                if recognizer.velocity > 0 && currentSize.width < 300 {
                    //pinching out, make cells larger
                    var currentSize = self.flowLayout.itemSize
                    self.flowLayout.itemSize = CGSize(width: currentSize.width * 2, height: currentSize.height * 2)
                    self.assetCellSize = self.flowLayout.itemSize
                }
                else if recognizer.velocity < 0 && currentSize.width > 37.5 {
                    // shrink the cell size
                    var currentSize = self.flowLayout.itemSize
                    self.flowLayout.itemSize = CGSize(width: currentSize.width * 0.5, height: currentSize.height * 0.5)
                    self.assetCellSize = self.flowLayout.itemSize
                }
            }, completion: nil)
        }
    }
    
}