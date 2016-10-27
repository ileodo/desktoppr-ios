//
//  WallpaperViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 27/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit
import SKPhotoBrowser


class WallpaperViewController: SKPhotoBrowser, SKPhotoBrowserDelegate {
    var wallpapers:[Wallpaper] = []
    var isLike: Bool?
    var hasSync: Bool?
    var optionButton: UIImageView!
    var showUploaderDelegate: ShowUploaderDelegator?
    
    public convenience init(photos: [SKPhotoProtocol], wallpapers:[Wallpaper]) {
        self.init(photos: photos)
        self.wallpapers = wallpapers
        self.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.main.bounds
        optionButton = UIImageView(frame: CGRect(x: screenSize.maxX-45, y: 17.5, width: 30, height: 20))
        optionButton.contentMode = .scaleAspectFill
        optionButton.image = #imageLiteral(resourceName: "MoreIcon").imageWithColor(tintColor: UIColor.white)
        optionButton.isUserInteractionEnabled = true
        optionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreOptions(_:))))
        self.view.addSubview(optionButton)

        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func currentWallpaper() -> Wallpaper{
        return wallpapers[getCurrentPageIndex()]
    }


    // MARK: - SKPhotoBrowserDelegate
    func didShowPhotoAtIndex(_ index: Int) {
        var flag = 0
        optionButton!.isUserInteractionEnabled = false
        APIWrapper.instance().doesUserLike(username: Auth.user()!.username!, wallpaperId: currentWallpaper().id!, successHandler: { (isLike) in
            self.isLike = isLike
            flag = flag + 1
            if(flag==2){
                self.optionButton!.isUserInteractionEnabled = true
            }
            },failedHandler: {_,_ in
                self.isLike = nil
                flag = flag + 1
                if(flag==2){
                    self.optionButton!.isUserInteractionEnabled = true
                }
        })
        APIWrapper.instance().doesUserSync(username: Auth.user()!.username!, wallpaperId: currentWallpaper().id!, successHandler: { (hasSync) in
            self.hasSync = hasSync
            flag = flag + 1
            if(flag==2){
                self.optionButton!.isUserInteractionEnabled = true
            }
            },failedHandler: {_,_ in
                self.hasSync = nil
                flag = flag + 1
                if(flag==2){
                    self.optionButton!.isUserInteractionEnabled = true
                }
        })

    }
    
    func moreOptions(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Options", preferredStyle: .actionSheet)

        if showUploaderDelegate != nil, let uploader = currentWallpaper().uploader {
            if(uploader != Auth.user()?.username){
                let viewUploaderAction = UIAlertAction(title: "View Uploader:"+uploader, style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.showUploaderDelegate?.showUploaderView(uploader)
                    self.dismiss(animated: true, completion: nil)
                })
                optionMenu.addAction(viewUploaderAction)
            }
        }
        
        if isLike != nil {
            let likeAction = UIAlertAction(title: isLike! ? "Unlike" : "Like", style: isLike! ? .destructive : .default, handler: {
                (alert: UIAlertAction!) -> Void in
                let fun = self.isLike! ? APIWrapper.instance().unlikeWallpaper : APIWrapper.instance().likeWallpaper
                self.actionHelper(apiAction: fun, successHandler: {
                    self.isLike! = !self.isLike!
                })
            })
            optionMenu.addAction( likeAction )
        }
        
        if hasSync != nil {
            let syncAction = UIAlertAction(title: hasSync! ? "Unsync" : "Sync", style: hasSync! ? .destructive : .default, handler: {
                (alert: UIAlertAction!) -> Void in
                let fun = self.hasSync! ? APIWrapper.instance().unsyncWallpaper : APIWrapper.instance().syncWallpaper
                self.actionHelper(apiAction: fun, successHandler: {
                    self.hasSync! = !self.hasSync!
                })
            })
            optionMenu.addAction( syncAction )
        }
        
        let flagAction = UIAlertAction(title: "Flag", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showFlagOptions()
        })
        optionMenu.addAction(flagAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }

    func showFlagOptions(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Flag", preferredStyle: .actionSheet)
        
        let flagSafeAction = UIAlertAction(title: "Safe", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let fun = APIWrapper.instance().flagSafeWallpaper
            
            self.actionHelper(apiAction: fun)
        })
        
        let flagUnsafeAction = UIAlertAction(title: "Unsafe", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let fun = APIWrapper.instance().flagNotSafeWallpaper
            
            self.actionHelper(apiAction: fun)
        })
        
        let flagDeletionAction = UIAlertAction(title: "Deletion", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            let fun = APIWrapper.instance().flagDeletionWallpaper
            
            self.actionHelper(apiAction: fun)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(flagSafeAction)
        optionMenu.addAction(flagUnsafeAction)
        optionMenu.addAction(flagDeletionAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu,animated: true,completion: nil)
    }
    
    typealias actionApiProcesser = ((_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void,_ failedHandler:@escaping  (_ error:String?, _ errorDescription:String?) -> Void) -> Void)
    
    func actionHelper(apiAction:actionApiProcesser, successHandler:@escaping ()->Void = { _ in },failedHandler: @escaping () -> Void = { _ in }){
        apiAction(Auth.apiToken()!, (currentWallpaper().id)!, { (ret) in
            successHandler()
            }, { (error, errorDescription) in
                let alert = UIAlertController(title: error, message: errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert,animated: true,completion: nil)
                failedHandler()
        })
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
