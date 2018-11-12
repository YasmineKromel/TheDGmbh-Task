//
//  DetailsOfProductViewController.swift
//  TheDGmbh_Task
//
//  Created by Yasmine on 11/11/18.
//  Copyright © 2018 Yasmine. All rights reserved.
//

import UIKit

class DetailsOfProductViewController: UIViewController {
    
    //MARK: @IBOutlets
    
    @IBOutlet weak var ProductDetailImageView: UIImageView!
    @IBOutlet weak var ProductDetailNameLbl: UILabel!
    @IBOutlet weak var ProductDetailPricTxtLbl: UILabel!
    @IBOutlet weak var ProductDetailPriceValueLbl: UILabel!
    @IBOutlet weak var ProductDetailDescLbl: UILabel!
    
    
    //Mark: Segue Prpperties
    
    var productName :String?
    var productImagePath :String?
    var productDescrib :String?
    var productPrice: String?

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load view with data 
         ProductDetailDescLbl.sizeToFit()
        
        if productName != nil && productDescrib != nil && productPrice != nil
        {
            // ProductDetailImageView
            ProductDetailNameLbl.text = productName
            ProductDetailPriceValueLbl.text = productPrice
            ProductDetailDescLbl.text = productDescrib
            
            let CustomImageObj = CustomImage()            
            CustomImageObj.loadImageWithStringUrl(urlString:productImagePath! ,photoView:ProductDetailImageView)
        }
        
       
    }

   
    
}
