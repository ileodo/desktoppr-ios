//
//  Auth.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 22/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation

class Auth{

    private static var _user:User?
    private static var _token:String?
    private static var _followingList:FollowingList?
    
    static func user() -> User?{
        return _user
    }
    
    static func login(user:User){
        _user = user
        _followingList = FollowingList()
    }
    
    static func apiToken() -> String? {
        return _token
    }
    
    static func setApiToken(token:String){
        _token = token
    }
    
    static func logout() {
        _user = nil
        _token = nil
        _followingList = nil
    }
    
    static func followingList() -> FollowingList? {
        return _followingList
    }
    
}
