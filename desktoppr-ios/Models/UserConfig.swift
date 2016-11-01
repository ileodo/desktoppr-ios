//
//  UserConfig.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 30/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//
// config stored in iCloud

import Foundation

class UserConfig {
   
    var defaultFilter : APIWrapper.Filter!
    
    init() {
        defaultFilter = .safe
    }
    
    func getFilter() -> APIWrapper.Filter{
        return defaultFilter
    }
}
