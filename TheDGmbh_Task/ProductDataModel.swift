//
//  ProductDataModel.swift
//  TheDGmbh_Task
//
//  Created by Yasmine on 11/11/18.
//  Copyright © 2018 Yasmine. All rights reserved.
//

import Foundation

class ProductDataModel
{
    var ProductID : Int?
    var ProductName : String?
    var ProductDesc : String?
    var ProductPrice : Int?
    var ProductImage : ImageDataModel?
    
    init(id:Int, name:String,desc:String, price: Int, image:ImageDataModel ) {
        ProductID = id
        ProductName = name
        ProductDesc = desc
        ProductPrice = price
        ProductImage = image
    }
}
