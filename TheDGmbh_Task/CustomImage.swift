//
//  CustomImage.swift
//  TheDGmbh_Task
//
//  Created by Yasmine on 11/11/18.
//  Copyright © 2018 Yasmine. All rights reserved.
//

import Foundation
import UIKit


class CustomImage: UIImageView
    
{
        
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func loadImageWithStringUrl(urlString: String , photoView :UIImageView )
    {
        
        let url = NSURL(string:urlString)
        
        
        if let ImageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage
        {
            
            photoView.image = ImageFromCache
            return
        }
        
        URLSession.shared.dataTask(with:url as! URL) { (data, response, err) in
            if err != nil
            {
                print(err)
                return
            }
            
            DispatchQueue.main.async {
                
                let imageToCache = UIImage(data: data! )
                photoView.image = imageToCache
                self.imageCache.setObject(imageToCache!, forKey: urlString as AnyObject )
                //photoView.contentMode = .scaleAspectFit
                
            }
            
            
            }.resume()
        
    }
    
    
    
}
