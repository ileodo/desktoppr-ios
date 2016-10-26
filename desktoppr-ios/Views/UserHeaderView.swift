//
//  UserHeaderView.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 23/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

class UserHeaderView: UICollectionReusableView {

    var delegate:(UserHeaderViewDelegator & ViewPresentable)!
    
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var userInfoText: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var wallpaperNoText: UILabel!
    @IBOutlet weak var wallpaperNoLabel: UILabel!
    
    @IBOutlet weak var followersNoText: UILabel!
    @IBOutlet weak var followersNoLabel: UILabel!
    
    
    @IBOutlet weak var followingNoText: UILabel!
    @IBOutlet weak var followingNoLabel: UILabel!
    
    @IBOutlet weak var likesNoText: UILabel!
    @IBOutlet weak var likesNoLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    var followed: Bool?{
        didSet{
            if followed! {
                Auth.followingList()?.add(username: (self.user.username)!)
                followButton.setBackgroundImage(UIImage().makeImageWithColorAndSize(color: UIColor.red, size: followButton.frame.size), for: .normal)
                followButton.setTitle("Unfollow", for: .normal)
            }else{
                Auth.followingList()?.remove(username: (self.user.username)!)
                followButton.setBackgroundImage(UIImage().makeImageWithColorAndSize(color: UIColor.blue, size: followButton.frame.size), for: .normal)
                followButton.setTitle("Follow", for: .normal)
            }
        }
    }
    
    var user:User! {
        didSet{
            if self.user != nil {
                loadUserLikeCount()
                self.usernameText.text = self.user.username! + (self.user.lifetime_member! ? " ☑️" : "")
                var userInfoStr = [String]()
                if self.user.name != nil {
                    userInfoStr.append(self.user.name!)
                }
                
                if self.user.created_at != nil {
                    userInfoStr.append("join @ "+DateTransform.getStringFor(self.user.created_at!))
                }
                
                self.userInfoText.text = userInfoStr.joined(separator: " / ")
                self.wallpaperNoText.text = self.user.wallpapers_count?.description
                self.followersNoText.text = self.user.followers_count?.description
                self.followingNoText.text = self.user.following_count?.description
                if(self.user.username == Auth.user()?.username){
                    self.followButton.isHidden = true
                }else{
                    self.followButton.isHidden = false
                    self.followed = Auth.followingList()?.contains(username: (self.user.username)!)
                }
                if(oldValue == nil || self.user.avatar_url != oldValue!.avatar_url){
                    self.user.loadAvatarTo(self.avatarImage,finishCallback: {(view)->Void in
                        view.layer.cornerRadius = self.avatarImage.frame.height/2
                    })
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.followersNoText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.showFollowersList(_:))))
        self.followersNoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.showFollowersList(_:))))
        
        self.followingNoText.addGestureRecognizer((UITapGestureRecognizer(target:self,action: #selector(UserHeaderView.showFollowingsList(_:)))))
        self.followingNoLabel.addGestureRecognizer((UITapGestureRecognizer(target:self,action: #selector(UserHeaderView.showFollowingsList(_:)))))
        
        self.wallpaperNoText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.showWallpapersCollection(_:))))
        self.wallpaperNoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.showWallpapersCollection(_:))))
        
        self.likesNoText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.showLikesCollection(_:))))
        self.likesNoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.showLikesCollection(_:))))
        
    }
    
    override func prepareForReuse() {
        self.usernameText.text = ""
        self.userInfoText.text = ""
    }
    
    func loadUserLikeCount(){
        APIWrapper.instance().getLikesWallpaper(username: self.user.username!, successHandler: { (_, count, _) in
            self.likesNoText.text = count.description
        }) { (error, errorDescription) in
            print(error ?? "Error")
            print(errorDescription ?? "Some error happened")
        }
        
    }
    
    
    // MARK: - Logic:Actions
    @IBAction func toggleFollowShip(_ sender: UIButton) {
        sender.isEnabled = false
        let fun : actionApiProcesser!
        if self.followed! {
            fun = APIWrapper.instance().unfollowUser
            
        }else{
            fun = APIWrapper.instance().followUser
        }
        actionHelper(apiAction: fun, successHandler: {
            self.followed = !self.followed!
            sender.isEnabled = true
            }, failedHandler: {
                sender.isEnabled = true
        })
    }
    
    
    typealias actionApiProcesser = ((_ apiToken:String,_ username:String,_ successHandler:@escaping ()-> Void,_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void) -> Void)
    
    func actionHelper(apiAction:actionApiProcesser, successHandler:@escaping ()->Void,failedHandler: @escaping () -> Void){
        apiAction(Auth.apiToken()!, (self.user.username)!, { (ret) in
            successHandler()
            }, { (error, errorDescription) in
                let alert = UIAlertController(title: error, message: errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.delegate.presentView(alert,animated: true,completion: nil)
                failedHandler()
        })
        
    }
    
    func showFollowersList(_ sender: UITapGestureRecognizer) {
        self.delegate.callSegueFromUserHeadView(view: self, identifier: "showFollowersList")
    }
    func showFollowingsList(_ sender: UITapGestureRecognizer) {
        self.delegate.callSegueFromUserHeadView(view: self, identifier: "showFollowingsList")
    }
    
    func showWallpapersCollection(_ sender: UITapGestureRecognizer) {
        self.delegate.callSegueFromUserHeadView(view: self, identifier: "showWallpapersCollection")
    }
    
    func showLikesCollection(_ sender: UITapGestureRecognizer) {
        self.delegate.callSegueFromUserHeadView(view: self, identifier: "showLikesCollection")
    }
    
    
}
