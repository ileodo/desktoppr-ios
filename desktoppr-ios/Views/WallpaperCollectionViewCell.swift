//
//  GalleryCollectionViewCell.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 12/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

class WallpaperCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    var delegate:WallpaperCellDelegator!
    
    @IBOutlet weak var image: UIImageView!
    
    var wallpaper:Wallpaper?{
        didSet{
            wallpaper?.loadImageTo(image,size:.thumb)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image=nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(WallpaperCollectionViewCell.showWallpaperDetails(_:))))
    }
    
    func showWallpaperDetails(_ sender: UITapGestureRecognizer) {
        self.delegate.showWallpaperView(cell: self, data: nil)
    }
}
