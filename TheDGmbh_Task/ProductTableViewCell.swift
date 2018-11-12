//
//  ProductTableViewCell.swift
//  TheDGmbh_Task
//
//  Created by Yasmine on 11/11/18.
//  Copyright © 2018 Yasmine. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    
    //MARK:@IBOutlets
    
    @IBOutlet weak var ProductNameCellLbl: UILabel!
    @IBOutlet weak var ProductPriceCellLbl: UILabel!  
    @IBOutlet weak var ProductImageCellImageView: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
