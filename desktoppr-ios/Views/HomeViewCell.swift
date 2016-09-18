//
//  HomeTableViewCell.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

class HomeViewCell: UICollectionViewCell {

    // MARK: Properties
    var delegate:(HomeCellDelegator & ViewPresentable)!
    
    @IBOutlet weak var wallpaperImageView: UIImageView!
    @IBOutlet weak var uploadTimeText: UILabel!
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var uploaderText: UILabel!
    
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var syncIcon: UIImageView!
    
    var isLike: Bool! {
        didSet{
            if isLike! {
                self.likeIcon.image = #imageLiteral(resourceName: "LikeIconFilled")
            }else {
                self.likeIcon.image = #imageLiteral(resourceName: "LikeIconEmpty")
            }

        }
    }
    
    var hasSync: Bool! {
        didSet{
            if hasSync! {
                self.syncIcon.image = #imageLiteral(resourceName: "SyncIconFilled")
            }else {
                self.syncIcon.image = #imageLiteral(resourceName: "SyncIconEmpty")
            }
        }
    }
    
    
    var wallpaper:Wallpaper? {
        didSet{
            if let wallpaper = wallpaper{
                wallpaper.loadImageTo(wallpaperImageView, size: .preview)
                
                uploaderText.text=wallpaper.uploader
                
                uploadTimeText.text="uploaded @ "+DateTransform.getStringFor(wallpaper.created_at!)
                if(wallpaper.uploader != nil){
                    APIWrapper.instance().userInfo(username: wallpaper.uploader!, successHandler: { (user:User) in
                        user.loadAvatarTo(self.userAvatarView)
                        self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.height/2
                    })
                    APIWrapper.instance().doesUserLike(username: Auth.user()!.username!, wallpaperId: wallpaper.id!, successHandler: { (isLike) in
                        self.isLike = isLike
                    })
                    APIWrapper.instance().doesUserSync(username: Auth.user()!.username!, wallpaperId: wallpaper.id!, successHandler: { (hasSync) in
                        self.hasSync = hasSync
                    })
                }
                
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wallpaperImageView.image=nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wallpaperImageView.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(HomeViewCell.showWallpaperDetails(_:))))
        uploaderText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewCell.showUserHome(_:))))
        userAvatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HomeViewCell.showUserHome(_:))))
        likeIcon.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(HomeViewCell.toggleLikeWallpaper(_:))))
        syncIcon.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(HomeViewCell.toggleSyncWallpaper(_:))))
    }


    @IBAction func flagWallpaper(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        let optionMenu = UIAlertController(title: nil, message: "Choose Flag", preferredStyle: .actionSheet)
        
        let flagSafeAction = UIAlertAction(title: "Safe", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let fun = APIWrapper.instance().flagSafeWallpaper
                
            self.actionHelper(apiAction: fun, successHandler: {
                    sender.isUserInteractionEnabled = true
                }, failedHandler: {
                    sender.isUserInteractionEnabled = true
            })
        })
        
        let flagUnsafeAction = UIAlertAction(title: "Unsafe", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let fun = APIWrapper.instance().flagNotSafeWallpaper
            
            self.actionHelper(apiAction: fun, successHandler: {
                sender.isUserInteractionEnabled = true
                }, failedHandler: {
                    sender.isUserInteractionEnabled = true
            })
        })
        
        let flagDeletionAction = UIAlertAction(title: "Deletion", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            let fun = APIWrapper.instance().flagDeletionWallpaper
            
            self.actionHelper(apiAction: fun, successHandler: {
                sender.isUserInteractionEnabled = true
                }, failedHandler: {
                    sender.isUserInteractionEnabled = true
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            sender.isUserInteractionEnabled = true
        })
        
        
        optionMenu.addAction(flagSafeAction)
        optionMenu.addAction(flagUnsafeAction)
        optionMenu.addAction(flagDeletionAction)
        optionMenu.addAction(cancelAction)
        
        self.delegate.presentView(optionMenu,animated: true,completion: nil)
    }
    
    func showUserHome(_ sender: UITapGestureRecognizer) {
        self.delegate.callSegueFromCell(cell: self,identifier: "showUser")
    }
    
    func showWallpaperDetails(_ sender: UITapGestureRecognizer) {
        self.delegate.callSegueFromCell(cell: self,identifier: "showDetails")
    }
    
    func toggleLikeWallpaper(_ sender: UITapGestureRecognizer) {
        self.likeIcon.isUserInteractionEnabled = false

        let fun = self.isLike! ? APIWrapper.instance().unlikeWallpaper : APIWrapper.instance().likeWallpaper
        actionHelper(apiAction: fun, successHandler: {
                self.isLike = !self.isLike
                self.likeIcon.isUserInteractionEnabled = true
            }, failedHandler: {
                self.likeIcon.isUserInteractionEnabled = true
        })
        
    }

    func toggleSyncWallpaper(_ sender: UITapGestureRecognizer) {
        self.syncIcon.isUserInteractionEnabled = false
        
        let fun = self.isLike! ? APIWrapper.instance().unsyncWallpaper : APIWrapper.instance().syncWallpaper
        actionHelper(apiAction: fun, successHandler: {
                self.hasSync = !self.hasSync
                self.syncIcon.isUserInteractionEnabled = true
            }, failedHandler: {
                self.syncIcon.isUserInteractionEnabled = true
        })
    }
    
    typealias actionApiProcesser = ((_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void,_ failedHandler:@escaping  (_ error:String?, _ errorDescription:String?) -> Void) -> Void)
    
    func actionHelper(apiAction:actionApiProcesser, successHandler:@escaping ()->Void,failedHandler: @escaping () -> Void){
        apiAction(Auth.apiToken()!, (self.wallpaper?.id)!, { (ret) in
                successHandler()
            }, { (error, errorDescription) in
                let alert = UIAlertController(title: error, message: errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.delegate.presentView(alert,animated: true,completion: nil)
                failedHandler()
        })

    }

}
