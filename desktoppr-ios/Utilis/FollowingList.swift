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
            for i:UInt in 1..<_pagination!.count!{
                requestApi(page: i)
            }
        }
    }
    
    func list() -> Set<String>{
        return _followingList
    }
    
    init() {
        _followingList = Set<String>.init()
        APIWrapper.instance().getFollowing(username: (Auth.user()?.username!)!, page: 0, successHandler: { (users, count, pagination) in
            self._pagination = pagination
            users.forEach({ (user) in
                self._followingList.insert(user.username!)
            })
        })
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
    
    private  func requestApi(page:UInt){
        APIWrapper.instance().getFollowing(username: (Auth.user()?.username!)!, page: page, successHandler: { (users, count, pagination) in
            users.forEach({ (user) in
                self._followingList.insert(user.username!)
            })
        })
    }
    

}
