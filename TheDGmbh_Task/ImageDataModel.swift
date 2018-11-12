//
//  ImageDataModel.swift
//  TheDGmbh_Task
//
//  Created by Yasmine on 11/11/18.
//  Copyright © 2018 Yasmine. All rights reserved.
//

import Foundation

class ImageDataModel
{
    var ImagePath : String?
    var ImageHeight : Int?
    var ImageWidth: Int?
    
    init(link: String , height:Int ,width: Int) {
        
        ImagePath = CheckIf_URL_Is_Http_ConvertTo_Https(str:link)
        ImageHeight = height
        ImageWidth = width
    }
    
    // This method convert url from http to https cause emulator doesn't download http urls
    
    private func CheckIf_URL_Is_Http_ConvertTo_Https(str:String)-> String?
    {
        if str.contains("http")
        {
            if str.contains("https"){
                return nil
            }
            else{
                let OldString = str
                let NewString = OldString.replacingOccurrences(of: "http", with: "https")
                return NewString
            }
        }
        return nil
    }
    
    
    
}
