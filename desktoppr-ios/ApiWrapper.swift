//
//  ApiWrapper.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 15/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON


class APIWrapper{
    private static var _instance:APIWrapper?
    static func instance() -> APIWrapper{
        if (APIWrapper._instance == nil) {
            APIWrapper._instance = APIWrapper.init()
        }
        return APIWrapper._instance!
    }

    
    enum Filter{
        case safe
        case including_pending
        case all
    }
    struct urls {
        static let callback = "https://api.desktoppr.co?callback=hello"
        struct authentication{
            static let basic = "https://api.desktoppr.co/1/user/whoami"
            static let token = "https://api.desktoppr.co/1/user/whoami?auth_token=$API_TOKEN"
        }
        struct users {
            static let info = "https://api.desktoppr.co/1/users/$USERNAME"
            
            static let wallpapers = "https://api.desktoppr.co/1/users/$USERNAME/wallpapers?page=$PAGE&safe_filter=$FILTER";
            static let randomwallpapers = "https://api.desktoppr.co/1/users/$USERNAME/wallpapers/random";
            
            static let likes = "https://api.desktoppr.co/1/users/$USERNAME/likes?page=$PAGE"
            static let hasLikes = "https://api.desktoppr.co/1/users/$USERNAME/likes?wallpaper_id=$WALLPAPER_ID"
            
            static let hasSynced = "https://api.desktoppr.co/1/users/$USERNAME/wallpapers?wallpaper_id=$WALLPAPER_ID"
            
            static let followers = "https://api.desktoppr.co/1/users/$USERNAME/followers?page=$PAGE"
            static let following = "https://api.desktoppr.co/1/users/$USERNAME/following?page=$PAGE"
            
            static let follow = "https://api.desktoppr.co/1/users/$USERNAME/follow?auth_token=$API_TOKEN"
            static let unfollow = "https://api.desktoppr.co/1/users/$USERNAME/follow?auth_token=$API_TOKEN"
        }
        struct wallpapers {
            static let list = "https://api.desktoppr.co/1/wallpapers?page=$PAGE&safe_filter=$FILTER"
            static let random = "https://api.desktoppr.co/1/wallpapers/random"
            
            static let like = "https://api.desktoppr.co/1/user/wallpapers/$WALLPAPER_ID/like?auth_token=$API_TOKEN"
            static let unlike = "https://api.desktoppr.co/1/user/wallpapers/$WALLPAPER_ID/like?auth_token=$API_TOKEN"
            
            static let sync = "https://api.desktoppr.co/1/user/wallpapers/$WALLPAPER_ID/selection?auth_token=$API_TOKEN"
            static let unsync = "https://api.desktoppr.co/1/user/wallpapers/$WALLPAPER_ID/selection?auth_token=$API_TOKEN"
            
            static let flag_safe = "https://api.desktoppr.co/1/wallpapers/$WALLPAPER_ID/flag_safe?auth_token=$API_TOKEN"
            static let flag_not_safe = "https://api.desktoppr.co/1/wallpapers/$WALLPAPER_ID/flag_not_safe?auth_token=$API_TOKEN"
            static let flag_deletion = "https://api.desktoppr.co/1/wallpapers/$WALLPAPER_ID/flag_deletion?auth_token=$API_TOKEN"
        }
    }
    
    private init() {
        
    }
    
    // MARK: authentication
    
    func basicAuth(_ credential:(user:String,passwd:String),_ successHandler:@escaping (_ user: User,_ apiToken:String)-> Void = {_ in },_ failedHandler:@escaping (_ error:String?) -> Void = {_ in }) {
        Alamofire.request(urls.authentication.basic).authenticate(user: credential.user, password: credential.passwd)
            .responseJSON { (response:DataResponse<Any>) in
                if(response.response?.statusCode==200){
                    let json = JSON(response.result.value!)
                    let user = User(JSONString:json["response"].rawString()!)!
                    let apiToken = json["response"]["api_token"].string!
                    successHandler(user,apiToken)
                }else{
                    let error = JSON(response.result.value!)
                    failedHandler(error["error"].string)
                }
        }
        
    }
    
    func tokenAuth(_ apiToken:String,_ successHandler:@escaping (_ User: User)-> Void = {_ in },_ failedHandler:@escaping (_ error:String?) -> Void = {_ in }) {
        Alamofire.request(urls.authentication.token.replacingOccurrences(of: "$API_TOKEN", with: apiToken))
            .responseJSON { (response:DataResponse<Any>) in
                if(response.result.isSuccess){
                    let json = JSON(response.result.value)
                    let user = User(JSONString:json["response"].rawString()!)!
                    successHandler(user)
                }else{
                    let error = JSON(response.result.value)
                    failedHandler(error["error"].string)
                }
        }
        
    }
    
    // MARK: users
    func userInfo(username:String,successHandler:@escaping (User) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.info.replacingOccurrences(of: "$USERNAME", with: username)
        processSingleUser(url,successHandler,failedHandler)
    }
    
    func getWallpapers(username:String,page:UInt = 1,filter:Filter = .safe,successHandler:@escaping (_ wallpapers:[Wallpaper],_ count:UInt,_ pagination:Pagination) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.wallpapers.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$FILTER", with: APIWrapper.getFilter(filter)).replacingOccurrences(of: "$PAGE", with: String(page))
        processWallpapers(url,successHandler,failedHandler)
    }
    
    func getRandomWallpaper(username:String,successHandler:@escaping (_ wallpaper:Wallpaper) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.randomwallpapers.replacingOccurrences(of: "$USERNAME", with: username)
        processSingleWallpaper(url,successHandler,failedHandler)
    }
    
    
    func getLikesWallpaper(username:String,page:UInt = 1,successHandler:@escaping (_ wallpapers:[Wallpaper],_ count:UInt,_ pagination:Pagination) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.likes.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$PAGE", with: String(page))
        processWallpapers(url,successHandler,failedHandler)
    }
    
    func doesUserLike(username:String,wallpaperId:UInt, successHandler:@escaping (_ like: Bool)-> Void={_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let helperSuccessHandler = {( wallpapers:[Wallpaper],  count:UInt,  pagination:Pagination) -> Void in
            if wallpapers.count==1 {
                successHandler(true)
            }else{
                successHandler(false)
            }
        }
    
        let url = urls.users.hasLikes.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId))
        processWallpapers(url,helperSuccessHandler,failedHandler)
    }
    
    func doesUserSync(username:String,wallpaperId:UInt, successHandler:@escaping (_ like: Bool)-> Void={_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let helperSuccessHandler = {( wallpapers:[Wallpaper],  count:UInt,  pagination:Pagination) -> Void in
            if wallpapers.count==1 {
                successHandler(true)
            }else{
                successHandler(false)
            }
        }
        
        let url = urls.users.hasSynced.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId))
        processWallpapers(url,helperSuccessHandler,failedHandler)
    }
    
    func doesUserFollow(username:String, successHandler:@escaping (_ like: Bool)-> Void={_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        
    }
    
    func getFollowers(username:String,page:UInt = 1,successHandler:@escaping (_ followers:[User],_ count:UInt,_ pagination:Pagination) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.followers.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$PAGE", with: String(page))
        processUsers(url,successHandler,failedHandler)
    }
    
    func getFollowing(username:String,page:UInt = 1,successHandler:@escaping (_ following:[User],_ count:UInt,_ pagination:Pagination) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.following.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$PAGE", with: String(page))
        processUsers(url,successHandler,failedHandler)
    }
    
   func followUser(_ apiToken:String,_ username:String,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
       let url = urls.users.follow.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .post, successHandler, failedHandler)
   }
    
    func unfollowUser(_ apiToken:String,_ username:String,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.users.unfollow.replacingOccurrences(of: "$USERNAME", with: username).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .delete, successHandler, failedHandler)
    }

    
    // MARK: wallpapers
    
    func getWallpapers(page:UInt = 1,filter:Filter = .safe, successHandler:@escaping (_ wallpapers:[Wallpaper],_ count:UInt,_ pagination:Pagination) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.list.replacingOccurrences(of: "$PAGE", with: String(page)).replacingOccurrences(of: "$FILTER", with: APIWrapper.getFilter(filter))
        processWallpapers(url,successHandler,failedHandler)
    }
    
    func getRandomWallpaper(successHandler:@escaping (_ wallpaper:Wallpaper) -> Void = {_ in },failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.random
        processSingleWallpaper(url,successHandler,failedHandler)
    }
    
    func likeWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.like.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .post, successHandler, failedHandler)
    }
    
    func unlikeWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.unlike.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .delete, successHandler, failedHandler)
    }
    
    func syncWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.sync.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .post, successHandler, failedHandler)
    }
    
    func unsyncWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.unsync.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .delete, successHandler, failedHandler)
    }
    
    func flagSafeWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.flag_safe.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .post, successHandler, failedHandler)
    }
    
    func flagNotSafeWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.flag_not_safe.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .post, successHandler, failedHandler)
    }
    
    func flagDeletionWallpaper(_ apiToken:String,_ wallpaperId:UInt,_ successHandler:@escaping ()-> Void={_ in },_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void = {_ in }){
        let url = urls.wallpapers.flag_deletion.replacingOccurrences(of: "$WALLPAPER_ID", with: String(wallpaperId)).replacingOccurrences(of: "$API_TOKEN", with: apiToken)
        processAction(url, .post, successHandler, failedHandler)
    }
    
    // MARK: Helpers
    
    func processWallpapers(_ url:String,_ successHandler:@escaping (_ wallpapers:[Wallpaper],_ count:UInt,_ pagination:Pagination) -> Void, _ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void){
        Alamofire.request(url).responseJSON { (response:DataResponse<Any>) in
            if(response.result.isSuccess){
                let json = JSON(response.result.value)
                let count:UInt = json["count"].uInt!
                let pagination = Pagination(JSONString:json["pagination"].rawString()!)!
                let wallpapers:[Wallpaper] = Array<Wallpaper>(JSONString:json["response"].rawString()!)!
                successHandler(wallpapers,count,pagination)
            }else{
                let error = JSON(response.result.value)
                failedHandler(error["error"].string,error["error_description"].string)
            }
        }
    }
    
    func processUsers(_ url:String,_ successHandler:@escaping (_ users:[User],_ count:UInt,_ pagination:Pagination) -> Void, _ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void){
        Alamofire.request(url).responseJSON { (response:DataResponse<Any>) in
            if(response.result.isSuccess){
                let json = JSON(response.result.value)
                let count:UInt = json["count"].uInt!
                let pagination = Pagination(JSONString:json["pagination"].rawString()!)!
                let wallpapers:[User] = Array<User>(JSONString:json["response"].rawString()!)!
                successHandler(wallpapers,count,pagination)
            }else{
                let error = JSON(response.result.value)
                failedHandler(error["error"].string,error["error_description"].string)
            }
        }
    }
    
    func processSingleUser(_ url:String,_ successHandler:@escaping (User) -> Void,_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void){
        Alamofire.request(url).responseObject(keyPath:"response") { (response:DataResponse<User>) in
            if(response.result.isSuccess){
                assert(response.result.value != nil)
                successHandler(response.result.value!)
            }else{
                let error = JSON(data:response.data!)
                failedHandler(error["error"].string,error["error_description"].string)
            }
        }
    }
    
    func processSingleWallpaper(_ url:String,_ successHandler:@escaping (Wallpaper) -> Void,_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void){
        Alamofire.request(url).responseObject(keyPath:"response") { (response:DataResponse<Wallpaper>) in
            if(response.result.isSuccess){
                assert(response.result.value != nil)
                successHandler(response.result.value!)
            }else{
                let error = JSON(data:response.data!)
                failedHandler(error["error"].string,error["error_description"].string)
            }
        }
    }
    
    
    
    func processAction(_ url:String,_ method:HTTPMethod, _ successHandler:@escaping ()-> Void,_ failedHandler:@escaping (_ error:String?, _ errorDescription:String?) -> Void){
        Alamofire.request(url,method:method).responseJSON { (response:DataResponse<Any>) in
            let json = JSON(response.result.value)
            if(response.response?.statusCode==200){
                successHandler()
            }else{
                failedHandler(json["error"].string,json["error_description"].string)
            }
        }
    
    }
    
    
    static func getFilter(_ filter:Filter) -> String{
        switch filter {
        case .safe:
            return "safe"
        case .including_pending:
            return "including_pending"
        case .all:
            return "all"
        }
    }
    static func getFilter(_ string:String) -> Filter?{
        switch string {
        case "safe":
            return .safe
        case "including_pending":
            return .including_pending
        case "all":
            return .all
        default:
            return nil
        }
    }
    
    
}
