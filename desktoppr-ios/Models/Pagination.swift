//
//  Pagination.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 16/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation
import ObjectMapper

class Pagination: Mappable{
    var current:UInt?
    var previous:UInt?
    var next:UInt?
    var per_page:UInt?
    var pages:UInt?
    var count:UInt?
    
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map){
        current <- map["current"]
        previous <- map["previous"]
        next <- map["next"]
        per_page <- map["per_page"]
        pages <- map["pages"]
        count <- map["count"]
    }
}
