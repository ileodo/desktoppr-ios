//
//  User.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 15/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable{
    var username:String?
    var name:String?
    var avatar_url:String?
    var wallpapers_count:Int?
    var uploaded_count:Int?
    var followers_count:Int?
    var following_count:Int?
    var created_at:Date?
    var lifetime_member:Bool?
    
    var likes_count: Int? // not in json
    
    required init?(map: Map){
    
    }
    
    func mapping(map: Map){
        username <- map["username"]
        name <- map["name"]
        avatar_url <- map["avatar_url"]
        wallpapers_count <- map["wallpapers_count"]
        uploaded_count <- map["uploaded_count"]
        followers_count <- map["followers_count"]
        following_count <- map["following_count"]
        created_at <- (map["created_at"], DateTransform())
        lifetime_member <- map["lifetime_member"]
    }
    
    func loadAvatarTo(_ view:UIImageView, finishCallback:@escaping (_ view:UIImageView)->Void = { _ in }){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: avatar_url!)
        session.dataTask(with: url!,
                         completionHandler: {(data, response, error) in
                            if error == nil {
                                DispatchQueue.main.async {
                                    view.image = UIImage(data: data!)
                                    finishCallback(view)
                                }
                            }
        }).resume()
        
    }
}
