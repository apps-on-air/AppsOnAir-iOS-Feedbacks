//
//  AddImageCVCell.swift
//  AppsOnAir
//
//  Created by vishal-zaveri-us on 30/05/24.
//

import UIKit

class AddImageCVCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
    }

}
