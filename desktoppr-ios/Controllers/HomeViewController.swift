//
//  SecondViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/09/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class HomeViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout, HomeCellDelegator, ViewPresentable, ShowUploaderDelegator {

    // MARK: - Properties:Data
    var wallpapers=[Wallpaper]()
    var pagination:Pagination?
    
    var refresher:UIRefreshControl!
    
    // MARK: - Logic:View
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(UINib(nibName:"HomeViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeViewCell")
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        refreshHandler()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }


    // MARK: - Logic:Data
    func loadWallpapers(page:UInt = 1){
        APIWrapper.instance().getWallpapers(page:page, successHandler: { (wallpapers, count, pagination) in
            self.pagination = pagination
            if(count==0){
                self.pagination?.next = nil
            }else{
                self.wallpapers += wallpapers
                self.collectionView?.reloadData()
            }
        }) { (error, errorDescription) in
            print(error ?? "Error")
            print(errorDescription ?? "Some error happened")
        }
    }
    
    func refreshHandler(){
        loadWallpapers()
        self.refresher.endRefreshing()
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
                loadWallpapers(page: (pagination?.next!)!)
            }
        }
        
        let cellIdentifier = "HomeViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HomeViewCell
        
        // Configure the cell
        cell.wallpaper = wallpapers[indexPath.row]
        cell.delegate = self
        return cell
        
    }

    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // MARK: - HomeCellDelegator
    func callSegueFromCell(cell: HomeViewCell, identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: cell)
    }
    
    func showWallpaperView(cell: HomeViewCell, data: Any?) {
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
    
    // MARK: - ViewPresentable
    func presentView(_ view:UIViewController,animated: Bool,completion: (()->Void)?) {
        self.present(view, animated: animated, completion: completion)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser" {
            let userHomeViewController = segue.destination as! UserHomeViewController
            if let selectedCell = sender as? HomeViewCell {
                let indexPath = collectionView?.indexPath(for: selectedCell)!
                let selectedUsername = wallpapers[(indexPath?.row)!].uploader
                userHomeViewController.username = selectedUsername
            }else if let uploader = sender as? String{
                userHomeViewController.username = uploader
            }
        }
    }
    
}

