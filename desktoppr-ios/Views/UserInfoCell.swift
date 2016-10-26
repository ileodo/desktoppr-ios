import UIKit

class UserInfoCell: UITableViewCell {

    var delegate:(ViewPresentable)!
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var followButton: UIButton!

    var followed:Bool!{
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
    
    var user:User!{
        didSet {
            userNameText.text = user.username! + (self.user.lifetime_member! ? " ☑️" : "")
            if(user.username == Auth.user()?.username){
                followButton.isHidden = true
            }else{
                followButton.isHidden = false
                followed = Auth.followingList()?.contains(username: (self.user.username)!)
            }
            
            self.user.loadAvatarTo(self.userAvatarView,finishCallback: {(view)->Void in
                self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.height/2
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userAvatarView.image=nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
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

}
