//
//  Wallpaper.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 15/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation
import ObjectMapper
import SKPhotoBrowser
class Wallpaper: Mappable{
    enum Size {
        case origin
        case thumb
        case preview
    }
    enum ReviewState{
        case safe
        case pending
        case not_safe
    }
    var id:UInt?
    var bytes:UInt?
    var created_at:Date?
    var image_url:String?
    var thumb:SmallImage?
    var preview:SmallImage?
    var height:UInt?
    var width:UInt?
    var review_state:ReviewState?
    var uploader:String?
    var user_count:Int?
    var likes_count:Int?
    var palette:[String]?
    var url:String?
    
    required init?(map: Map){
    }
    
    func mapping(map: Map){
        id <- map["id"]
        bytes <- map["bytes"]
        created_at <- (map["created_at"],DateTransform())
        image_url <- map["image.url"]
        thumb <- map["image.thumb"]
        preview <- map["image.preview"]
        height <- map["height"]
        width <- map["width"]
        let reviewStateTransform = TransformOf<ReviewState, String>(
            fromJSON: { (value: String?) -> ReviewState? in
                if let value = value {
                    return Wallpaper.getReviewState(value)
                }
                return nil
            }, toJSON: { (value: ReviewState?) -> String? in
                // transform value from Int? to String?
                if let value = value {
                    return Wallpaper.getReviewState(value)
                }
                return nil
            })
        review_state <- (map["review_state"],reviewStateTransform)
        uploader <- map["uploader"]
        user_count <- map["user_count"]
        likes_count <- map["likes_count"]
        palette <- map["palette"]
        url <- map["url"]
    }
    
    func loadImageTo(_ view:UIImageView,size:Size = .origin){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var urlstring:String?
        switch size {
        case .origin:
            urlstring=self.image_url
        case .thumb:
            urlstring=self.thumb?.url
        case .preview:
            urlstring=self.preview?.url
        }
        let url = URL(string: urlstring!)
        session.dataTask(with: url!,
                         completionHandler: {(data, response, error) in
                            if error == nil {
                                DispatchQueue.main.async {
                                    view.image = UIImage(data: data!)
                                }
                            }
        }).resume()
        
    }
    
    
    class SmallImage: Mappable{
        var url:String?
        var width:UInt?
        var height:UInt?
        
        required init?(map: Map) {}
        
        func mapping(map: Map) {
            url <- map["url"]
            height <- map["height"]
            width <- map["width"]
        }
    }
    
    static func getReviewState(_ flag:ReviewState) -> String{
        switch flag {
        case .safe:
            return "safe"
        case .pending:
            return "pending"
        case .not_safe:
            return "not_safe"
        }
    }
    static func getReviewState(_ string:String) -> ReviewState?{
        switch string {
        case "safe":
            return .safe
        case "pending":
            return .pending
        case "not_safe":
            return .not_safe
        default:
            return nil
        }
    }
    
    func SKPhotoImageUrl() -> String {
        return (self.preview?.url)!
    }
}

