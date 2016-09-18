//
//  FirstViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/09/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

import SKPhotoBrowser

class ExploreViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, WallpaperCellDelegator {
    
    // MARK: - Properties:Data
    static let countOfRandomWallpapers = 18
    var wallpapers = [Wallpaper]()
    
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UINib(nibName: "WallpaperCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: "WallpaperCollectionViewCell")
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(randomWallpaper), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        
        randomWallpaper()
    }
    
    
    // MARK: - Logic:Actions
    @IBAction func random(_ sender: AnyObject) {
        randomWallpaper()
    }
    
    @IBAction func searchUser(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Search User", message: "Enter the username", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "username"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let text = alert.textFields![0].text // Force unwrapping because we know it exists.
            APIWrapper.instance().userInfo(username: text!, successHandler: { (user) in
                self.performSegue(withIdentifier: "showUser", sender: text)
                }, failedHandler: { (_, _) in
                    let notify = UIAlertController(title: "Error", message: "Can't find the target User.", preferredStyle: .alert)
                    notify.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                    self.present(notify,animated: true,completion: nil)
                    
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Logic:Data
    func randomWallpaper(){
        self.navigationItem.rightBarButtonItem?.isEnabled=false
        let flagFirstTime = (wallpapers.isEmpty)
        
        for i in 0..<ExploreViewController.countOfRandomWallpapers{
            APIWrapper.instance().getRandomWallpaper(successHandler: { (wallpaper:Wallpaper) in
                if(flagFirstTime){
                    self.wallpapers.append(wallpaper)
                    if(self.wallpapers.count==ExploreViewController.countOfRandomWallpapers){
                        self.collectionView?.reloadData()
                        self.refresher.endRefreshing()
                    }
                }else{
                    self.wallpapers[i]=wallpaper
                    self.collectionView?.reloadItems(at: [IndexPath(row: i, section: 0)])
                    self.refresher.endRefreshing()
                }
            }) { (error:String?, errorDescription:String?) in
                print(error)
                print(errorDescription)
                self.refresher.endRefreshing()
            }
        }
        self.navigationItem.rightBarButtonItem?.isEnabled=true
    }
    
    
    // MARK: - Collection view data source
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cellIdentifier = "WallpaperCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WallpaperCollectionViewCell
        cell.wallpaper = wallpapers[indexPath.row]
        cell.delegate = self
        return cell
        
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
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
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //MARK: - WallpaperCellDelegator
    
    func callSegueFromCell(cell: WallpaperCollectionViewCell, identifier: String) {
        var images = [SKPhoto]()
        for wallpaper in wallpapers{
            let photo = SKPhoto.photoWithImageURL((wallpaper.preview?.url!)!)
            photo.shouldCachePhotoURLImage = true
            
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex((collectionView?.indexPath(for: cell)?.row)!)
        present(browser, animated: true, completion: {})
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="showUser"{
            let userHomeViewControlle = segue.destination as? UserHomeViewController
            userHomeViewControlle?.username=(sender as! String)
        }
        
    }
    
}


