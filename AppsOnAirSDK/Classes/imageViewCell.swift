//
//  imageViewCell.swift
//  appsonair
//
//  Created by vishal-zaveri-us on 25/04/24.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgImageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        btnRemove.setTitle("", for: .normal)
    }

}
