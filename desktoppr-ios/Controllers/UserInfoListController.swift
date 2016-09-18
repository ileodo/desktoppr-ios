//
//  UserInfoListController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 21/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

class UserInfoListController: UITableViewController, ViewPresentable {
    
    // MARK: - Properties:Data
    enum ListType {
        case Followers
        case Followings
    }
    
    var baseUsername:String?
    var users = [User]()
    var pagination:Pagination?
    var type:ListType?
    
    // MARK: - Logic:View
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "UserInfoCell",bundle: nil), forCellReuseIdentifier: "UserInfoCell")
        switch self.type! {
        case .Followers:
            self.navigationItem.title = "Followers"
        case .Followings:
            self.navigationItem.title = "Followings"
        }
        loadUsersList(page: 0)
    }
    
    // MARK: - Logic:Data
    func loadUsersList(page:UInt) {
        switch self.type! {
        case .Followers:
            APIWrapper.instance().getFollowers(username: baseUsername!, page: page, successHandler: { (users, count, pagination) in
                    self.users += users
                    self.pagination = pagination
                    self.tableView.reloadSections(IndexSet.init(integer: 0),with: .none)
                })
        case .Followings:
            APIWrapper.instance().getFollowing(username: baseUsername!, page: page, successHandler: { (users, count, pagination) in
                self.users += users
                self.pagination = pagination
                self.tableView.reloadSections(IndexSet.init(integer: 0),with: .none)
            })
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row==users.count-1){
            // load more
            if(pagination?.next != nil){
                loadUsersList(page: (pagination?.next!)!)
            }
        }
        let cellIdentifier = "UserInfoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserInfoCell
        
        cell.delegate = self
        cell.user = users[indexPath.row]
        switch self.type! {
        case .Followers:
            cell.followed = Auth.followingList()?.contains(username: (cell.user?.username)!)
            break
        case .Followings:
            cell.followed = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showUser", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: - ViewPresentable
    func presentView(_ view:UIViewController,animated: Bool,completion: (()->Void)?) {
        self.present(view, animated: animated, completion: completion)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUser"{
            let userHomeViewController = segue.destination as! UserHomeViewController
            if let selectedUser = sender as? UserInfoCell {
                let indexPath = tableView.indexPath(for: selectedUser)!
                let selectedUser = users[indexPath.row]
                userHomeViewController.username = selectedUser.username
            }
        }
    }
 

}
