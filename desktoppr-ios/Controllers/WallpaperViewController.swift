//
//  WallpaperViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 27/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class WallpaperViewController: SKPhotoBrowser {

    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        btn.text = "ssss"
        btn.textColor = UIColor.white
        self.view.addSubview(btn)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
