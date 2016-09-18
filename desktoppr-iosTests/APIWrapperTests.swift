//
//  UserTest.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 15/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import XCTest
import ObjectMapper
import SwiftyJSON
@testable import desktoppr_ios

class APIWrapperTests: XCTestCase {
    var api : APIWrapper = APIWrapper.instance()
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: user
    func testLoadExitUser() {
        let exp = expectation(description: "testLoadExitUser")
        api.userInfo(username: "ileodo",
                     successHandler: {(user:User) -> Void in
                        XCTAssertEqual(user.username, "ileodo")
                        XCTAssertEqual(user.name, "iLeoDo")
                        XCTAssertEqual(user.avatar_url, "https://secure.gravatar.com/avatar/235cbb700eefef898c227c427ad41993.png?r=PG")
                        XCTAssert(user.wallpapers_count!>=0)
                        XCTAssert(user.uploaded_count!>=0)
                        XCTAssert(user.followers_count!>=0)
                        XCTAssert(user.following_count!>=0)
                        XCTAssertNotNil(user.created_at)
                        XCTAssertFalse(user.lifetime_member!)
                        exp.fulfill()
                    },
                     failedHandler: {(error:String?,errorDescription:String?)->Void in
                        XCTAssert(false)
                        exp.fulfill()
                    }
        )
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadNonExitUser() {
        let exp = expectation(description: "testLoadNonExitUser")
        api.userInfo(username: "IDIOT",
                     successHandler: {(user:User) -> Void in
                        XCTAssert(false)
                        exp.fulfill()
            },
                     failedHandler: {(error:String?,errorDescription:String?)->Void in
                        XCTAssertEqual(error, "not_found")
                        XCTAssertEqual(errorDescription, "The requested resource could not be found.")
                        exp.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testLoadWallpapersForExitUser(){
        let exp = expectation(description: "testLoadWallpapersForExitUser")
        
        api.getWallpapers(username: "ileodo",
                          successHandler: {(wallpapers:[Wallpaper],count:UInt,pagination:Pagination) -> Void in
                            XCTAssert(UInt(wallpapers.count)==count)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadRandomWallpaperForExitUser(){
        let exp = expectation(description: "testLoadRandomWallpaperForExitUser")
        
        api.getRandomWallpaper(username: "ileodo",
                          successHandler: {(wallpaper:Wallpaper) -> Void in
                            XCTAssert(wallpaper.id!>0)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUserLikedWallpaperForExitUser(){
        let exp = expectation(description: "testLoadWallpapersForExitUser")
        
        api.getLikesWallpaper(username: "ileodo",
                               successHandler: {(wallpapers:[Wallpaper],count:UInt,pagination:Pagination) -> Void in
                                XCTAssert(UInt(wallpapers.count)==count)
                                exp.fulfill()
                            }
                            ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                                XCTAssert(false)
                                exp.fulfill()
                            }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDoesUserLike(){
        let exp = expectation(description: "testDoesUserLike")
        
        api.doesUserLike(username: "ileodo", wallpaperId: 142364,
                              successHandler: {(like:Bool) -> Void in
                                XCTAssert(like)
                            }
                            ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                                XCTAssert(false)
                                exp.fulfill()
                            }
        );
        api.doesUserLike(username: "ileodo", wallpaperId: 142363,
                         successHandler: {(like:Bool) -> Void in
                            XCTAssert(!like)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDoesUserSync(){
        let exp = expectation(description: "testDoesUserSync")
        
        api.doesUserSync(username: "ileodo", wallpaperId: 597573,
                         successHandler: {(sync:Bool) -> Void in
                            XCTAssert(sync)
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        api.doesUserSync(username: "ileodo", wallpaperId: 142363,
                         successHandler: {(sync:Bool) -> Void in
                            XCTAssert(!sync)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadFollowersForExitUser(){
        let exp = expectation(description: "testLoadFollowersForExitUser")
        
        api.getFollowers(username: "ileodo",
                         successHandler: {(followers:[User],count:UInt,pagination:Pagination) -> Void in
                            XCTAssert(UInt(followers.count)==count)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLoadFollowingsForExitUser(){
        let exp = expectation(description: "testLoadFollowingsForExitUser")
        
        api.getFollowing(username: "ileodo",
                         successHandler: {(followings:[User],count:UInt,pagination:Pagination) -> Void in
                            XCTAssert(UInt(followings.count)==count)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: wallpaper
    
    func testListWallpapers(){
        let exp = expectation(description: "testListWallpapers")
        
        api.getWallpapers(successHandler: {(wallpapers:[Wallpaper],count:UInt,pagination:Pagination) -> Void in
                            XCTAssert(UInt(wallpapers.count)==count)
                            exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRandomWallpapers(){
        let exp = expectation(description: "testRandomWallpapers")
        
        api.getRandomWallpaper(successHandler: {(wallpaper:Wallpaper) -> Void in
                        XCTAssert(wallpaper.id!>0)
                        exp.fulfill()
                        }
                        ,failedHandler: {(error:String?,errorDescription:String?)->Void in
                            XCTAssert(false)
                            exp.fulfill()
                        }
        );
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
