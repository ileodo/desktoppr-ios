//
//  GalleryCollectionViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 12/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit
import SKPhotoBrowser
class GeneralCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, WallpaperCellDelegator, ShowUploaderDelegator {

    // MARK: - Properties:Data

    enum CollectionType {
        case Wallpapers
        case Likes
    }
    
    
    var type:CollectionType!
    var baseUsername:String!
    
    var wallpapers = [Wallpaper]()
    var pagination:Pagination?
    
    // MARK: - Logic:View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UINib(nibName: "WallpaperCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: "WallpaperCollectionViewCell")

        switch self.type! {
        case .Wallpapers:
            self.navigationItem.title = "Wallpapers"
        case .Likes:
            self.navigationItem.title = "Likes"
        }
        loadWallpapers()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    
    // MARK: - Logic:Data
    func loadWallpapers(_ page:UInt = 1){
        switch self.type! {
        case .Wallpapers:
            APIWrapper.instance().getWallpapers(username: baseUsername, page: page, filter:.all, successHandler: { (wallpapers, count, pagination) in
                self.pagination = pagination
                if(count==0){
                    self.pagination?.next = nil
                }else{
                    self.wallpapers += wallpapers
                    self.collectionView?.reloadData()
                }
            })
        case .Likes:
            APIWrapper.instance().getLikesWallpaper(username: baseUsername, page: page, successHandler: { (wallpapers, count, pagination) in
                self.pagination = pagination
                if(count==0){
                    self.pagination?.next = nil
                }else{
                    self.wallpapers += wallpapers
                    self.collectionView?.reloadData()
                }
            })
        }
    }


    // MARK: - Collection view data source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(indexPath.row==wallpapers.count-1){
            // load more
            if(pagination?.next != nil){
                loadWallpapers((pagination?.next!)!)
            }
        }
        
        let cellIdentifier = "WallpaperCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WallpaperCollectionViewCell
        
        // Configure the cell
        cell.wallpaper = wallpapers[indexPath.row]
        cell.delegate = self
        return cell
        
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    fileprivate func itemsPerRow() -> CGFloat{
        return view.frame.height>view.frame.width ? 3.0 : 6.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow() + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow()
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    //MARK: - WallpaperCellDelegator
    func showWallpaperView(cell: WallpaperCollectionViewCell, data: Any?) {
        let indexPath = collectionView?.indexPath(for: cell)!
        
        var images = [SKPhoto]()
        for wallpaper in wallpapers{
            let photo = SKPhoto.photoWithImageURL((wallpaper.preview?.url)!)
            photo.shouldCachePhotoURLImage = true
            if let uploader = wallpaper.uploader {
                photo.caption = "upload by " + uploader + " @ " + DateTransform.getStringFor(wallpaper.created_at!)
            }
            images.append(photo)
        }
        
        let browser = WallpaperViewController(photos: images, wallpapers:wallpapers)
        browser.showUploaderDelegate = self
        browser.initializePageIndex((indexPath?.row)!)
        present(browser, animated: true, completion: {})
    }
    
    
    // MARK: - ShowUploaderDelegator
    func showUploaderView(_ uploader: String) {
        self.performSegue(withIdentifier: "showUser", sender: uploader)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser"{
            let userHomeViewControlle = segue.destination as? UserHomeViewController
            userHomeViewControlle?.username=(sender as! String)
        }
    }
    
    
    
}
