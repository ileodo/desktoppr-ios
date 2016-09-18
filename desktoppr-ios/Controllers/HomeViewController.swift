//
//  SecondViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/09/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

class HomeViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout, HomeCellDelegator, ViewPresentable {

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


    // MARK: - Logic:Data
    func loadWallpapers(page:UInt = 0){
        APIWrapper.instance().getWallpapers(page:page,filter:.all, successHandler: { (wallpapers, count, pagination) in
            self.wallpapers += wallpapers
            self.pagination = pagination
            self.collectionView?.reloadData()
        }) { (error, errorDescription) in
            print(error)
            print(errorDescription)
        }
    }
    
    func refreshHandler(){
        loadWallpapers(page: 0)
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
        self.performSegue(withIdentifier: identifier, sender:cell )
        
    }
    
    // MARK: - ViewPresentable
    func presentView(_ view:UIViewController,animated: Bool,completion: (()->Void)?) {
        self.present(view, animated: animated, completion: completion)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailsViewController = segue.destination as! DetailsViewController
            if let selectedCell = sender as? HomeViewCell {
                let indexPath = collectionView?.indexPath(for: selectedCell)!
                let selectedWallpaper = wallpapers[(indexPath?.row)!]
                detailsViewController.wallpapers = [selectedWallpaper]
                detailsViewController.currentIndex = 0
            }
        }else if segue.identifier == "showUser" {
            let userHomeViewController = segue.destination as! UserHomeViewController
            if let selectedCell = sender as? HomeViewCell {
                let indexPath = collectionView?.indexPath(for: selectedCell)!
                let selectedUsername = wallpapers[(indexPath?.row)!].uploader
                userHomeViewController.username = selectedUsername
            }
        }
    }
    
}

