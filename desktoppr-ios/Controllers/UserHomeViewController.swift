//
//  UserHomeViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 19/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class UserHomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WallpaperCellDelegator, UserHeaderViewDelegator, ViewPresentable, ShowUploaderDelegator {
    
    // MARK: - Properties:UI
    @IBOutlet weak var wallpaperCollectionView: UICollectionView!
    var refresher:UIRefreshControl!
    
    // MARK: - Properties:Data
    var username:String?
    
    var user:User?{
        didSet{
            self.wallpaperCollectionView.reloadSections(IndexSet.init(integer:0))
        }
    }
    
    
    var wallpapers=[Wallpaper]()
    var pagination:Pagination?
    
    // MARK: - Logic:View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.wallpaperCollectionView.register(UINib(nibName: "WallpaperCollectionViewCell",bundle: nil), forCellWithReuseIdentifier: "WallpaperCollectionViewCell")
        self.wallpaperCollectionView.register(UINib(nibName: "UserHeaderView",bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserHeaderView")
        if username==nil{
            username=Auth.user()?.username
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "TabIconSetting"), style: .done, target: self, action: #selector(UserHomeViewController.goToSetting))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Logout", style: .done, target: self, action: #selector(UserHomeViewController.logout))
        }
        self.navigationItem.title = self.username
        
        self.refresher = UIRefreshControl()
        self.wallpaperCollectionView!.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(loadUserAndWallpapers), for: .valueChanged)
        self.wallpaperCollectionView!.addSubview(refresher)
        
        loadUserAndWallpapers()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        wallpaperCollectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Logic:Business
    func logout(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginView = storyBoard.instantiateViewController(withIdentifier: "loginView")
        loginView.modalPresentationStyle = .fullScreen
        Auth.logout()
        let alert = UIAlertController(title: "Logout Success", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            self.present(loginView, animated: false, completion: nil)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func goToSetting(){
        self.performSegue(withIdentifier: "showSettings", sender: self.navigationItem.leftBarButtonItem)
    }
    
    
    // MARK: - Logic:Data
    func loadUserAndWallpapers(){
        APIWrapper.instance().userInfo(username: username!, successHandler: { (user) in
            self.user = user
        }) { (error, errorDescription) in
            print(error ?? "Error")
            print(errorDescription ?? "Some error happened")
        }
        wallpapers.removeAll()
        wallpaperCollectionView.reloadData()
        loadWallpapers()

        self.refresher.endRefreshing()
    }
    
    
    func loadWallpapers(page:UInt = 1){
        
        let filter = Auth.user()?.username == self.username ? .all : Auth.userConfig()?.getFilter()
        APIWrapper.instance().getWallpapers(username: username!, page:page, filter: filter!, successHandler: { (wallpapers, count, pagination) in
            self.pagination = pagination
            if(count==0){
                self.pagination?.next = nil
            }else{
                self.wallpapers += wallpapers
                self.wallpaperCollectionView?.reloadData()
            }
        }) { (error, errorDescription) in
            print(error ?? "Error")
            print(errorDescription ?? "Some error happened")
        }
    }
   
    

    // MARK: - WallpaperCellDelegator
    
    func showWallpaperView(cell: WallpaperCollectionViewCell, data: Any?) {
        let indexPath = wallpaperCollectionView?.indexPath(for: cell)!
        
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
        let userHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "userHome") as! UserHomeViewController
        userHomeViewController.username = uploader
        self.navigationController?.pushViewController(userHomeViewController, animated: true)
    }
    
    // MARK: - UserHeaderViewDelegator
    func callSegueFromUserHeadView(view: UserHeaderView, identifier: String){
        self.performSegue(withIdentifier: identifier, sender: view)
    }
   
    
    // MARK: - ViewPresentable
    func presentView(_ view:UIViewController,animated: Bool,completion: (()->Void)?) {
        self.present(view, animated: animated, completion: completion)
    }
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.row==wallpapers.count-1){
        // load more
            if(pagination?.next != nil){
                loadWallpapers(page: (pagination?.next!)!)
            }
        }
        
        let cellIdentifier = "WallpaperCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WallpaperCollectionViewCell
        
        // Configure the cell
        cell.wallpaper = wallpapers[indexPath.row]
        cell.delegate = self
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0.0, height: 166.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if(kind == UICollectionElementKindSectionHeader){
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserHeaderView", for: indexPath) as! UserHeaderView
            headerView.user=self.user
            headerView.delegate = self
            return headerView
        }else{
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserHeaderView", for: indexPath) as! UserHeaderView
        }
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
    
    


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFollowersList" {
            let userInfoListViewController = segue.destination as! UserInfoListController
            userInfoListViewController.type = UserInfoListController.ListType.Followers
            userInfoListViewController.baseUsername = self.username
        }else if segue.identifier == "showFollowingsList" {
            let userInfoListViewController = segue.destination as! UserInfoListController
            userInfoListViewController.type = UserInfoListController.ListType.Followings
            userInfoListViewController.baseUsername = self.username
        }else if segue.identifier == "showWallpapersCollection" {
            let generalCollectionViewController = segue.destination as! GeneralCollectionViewController
            generalCollectionViewController.type = GeneralCollectionViewController.CollectionType.Wallpapers
            generalCollectionViewController.baseUsername = self.username
        }else if segue.identifier == "showLikesCollection" {
            let generalCollectionViewController = segue.destination as! GeneralCollectionViewController
            generalCollectionViewController.type = GeneralCollectionViewController.CollectionType.Likes
            generalCollectionViewController.baseUsername = self.username
        }
        
    }
    
    

}




