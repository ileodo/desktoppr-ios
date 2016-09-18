//
//  DateTransform.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 15/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import Foundation
import ObjectMapper

class DateTransform : TransformType {
    
    public typealias Object = Date
    public typealias JSON = String
    
    let dateFormatter:DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }
    
    func transformFromJSON(_ value: Any?) -> Object?{
        if let str = value as? String {
            return dateFormatter.date(from: str)
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON?{
        return dateFormatter.string(from: value!)
    }
    
    static func getStringFor(_ date:Date) -> String{
        let df = DateFormatter.init()
        df.dateFormat="yyyy-MM-dd HH:mm"
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }
}
