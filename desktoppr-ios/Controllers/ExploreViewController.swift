//
//  FirstViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/09/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

import SKPhotoBrowser

class ExploreViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, WallpaperCellDelegator, ShowUploaderDelegator {
    
    // MARK: - Properties:Data
    static let countOfRandomWallpapers = 18
    var wallpapers = [Wallpaper]()
    
    
    // MARK: - Properties:UI
    var refresher:UIRefreshControl!
    weak var searchUserAction: UIAlertAction?

    // MARK: - Logic:UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UINib(nibName: "WallpaperCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: "WallpaperCollectionViewCell")
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(randomWallpaper), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        
        randomWallpaper()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Logic:Actions
    @IBAction func random(_ sender: AnyObject) {
        randomWallpaper()
    }
    
    @IBAction func searchUser(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Search User", message: "Enter the username", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "username"
            textField.addTarget(self, action: #selector(self.textChanged(sender:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let text = alert.textFields![0].text // Force unwrapping because we know it exists.
            APIWrapper.instance().userInfo(username: text!, successHandler: { (user) in
                self.performSegue(withIdentifier: "showUser", sender: text)
            }, failedHandler: { (_, _) in
                let notify = UIAlertController(title: "Error", message: "Can't find the target User.", preferredStyle: .alert)
                notify.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(notify,animated: true,completion: nil)
                
            })
        })
        okAction.isEnabled = false
        self.searchUserAction = okAction
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func textChanged(sender:UITextField) {
        self.searchUserAction?.isEnabled = (!sender.text!.isEmpty)
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
                print(error ?? "Error")
                print(errorDescription ?? "Some error happened")
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
    

    
    
    // MARK: - WallpaperCellDelegator
    
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
        if segue.identifier=="showUser"{
            let userHomeViewControlle = segue.destination as? UserHomeViewController
            userHomeViewControlle?.username=(sender as! String)
        }
    }
    
}




