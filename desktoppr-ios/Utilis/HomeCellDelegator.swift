//
//  HomeCellDelegator.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 19/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

protocol HomeCellDelegator {
    func callSegueFromCell(cell: HomeViewCell, identifier: String)
}
