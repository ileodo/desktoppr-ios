//
//  Auth.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 22/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation
import KeychainAccess

class Auth{
    private static let keychain = Keychain(service:"com.ileodo.desktoppr-ios")
    
    private static var _user:User?
    private static var _token:String?
    private static var _followingList:FollowingList?
    private static var _userConfig:UserConfig?
    
    // MARK: - Getters
    static func user() -> User?{
        return _user
    }
    
    static func apiToken() -> String? {
        return _token
    }
    
    static func followingList() -> FollowingList? {
        return _followingList
    }
    
    static func getRemember() -> (username:String,apiToken:String)?{
        if let username = UserDefaults.standard.string(forKey: "username") , let apiToken = keychain["api_token"]{
            return (username,apiToken)
        }
        return nil
    }
    
    static func userConfig() -> UserConfig? {
        return _userConfig
    }
    
    // MARK: - Actions
    static func login(user:User,apiToken:String, remember:Bool = true){
        _user = user
        _token = apiToken
        _followingList = FollowingList()
        _userConfig = UserConfig()
        if(remember){
            Auth.remember(username: user.username!,apiToken: apiToken)
        }
        
    }
    
    static func logout() {
        _user = nil
        _token = nil
        _followingList = nil
        deleteRemember()
    }
    
    static func remember(username:String,apiToken:String){
        UserDefaults.standard.set(true, forKey: "hasRemember")
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.synchronize()
        keychain["api_token"]=apiToken
    }
    
    static func deleteRemember(){
        UserDefaults.standard.set(false, forKey: "hasRemember")
        keychain["api_token"]=nil
        do {
            try keychain.removeAll()
        } catch let error {
            print(error)
        }
        
    }


    
}
