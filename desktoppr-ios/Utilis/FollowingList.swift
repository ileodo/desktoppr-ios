//
//  FollowingList.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 23/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation

class FollowingList{
    
    private var _followingList : Set<String>
    private var _pagination:Pagination?{
        didSet{
            if _pagination!.pages!>0{
                for i:UInt in 1..._pagination!.pages!{
                    requestApi(page: i)
                }
            }
        }
    }
    
    func list() -> Set<String>{
        return _followingList
    }
    
    init() {
        _followingList = Set<String>.init()
        requestApi()
    }
    
    func add(username:String){
        _followingList.insert(username)
    }
    
    func remove(username:String){
        _followingList.remove(username)
    }
    
    func contains(username:String) -> Bool{
        return _followingList.contains(username)
    }
    
    private  func requestApi(page:UInt = 1){
        APIWrapper.instance().getFollowing(username: (Auth.user()?.username!)!, page: page, successHandler: { (users, count, pagination) in
            if(page==1){
                self._pagination = pagination
            }
            users.forEach({ (user) in
                self._followingList.insert(user.username!)
            })
        })
    }
    

}
