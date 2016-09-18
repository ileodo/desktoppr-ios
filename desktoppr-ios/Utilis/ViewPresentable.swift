//
//  ViewPresentable.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 23/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

protocol ViewPresentable {
    func presentView(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}
