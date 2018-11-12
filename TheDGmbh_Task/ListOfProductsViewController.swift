//
//  ListOfProductsViewController.swift
//  TheDGmbh_Task
//
//  Created by Yasmine on 11/11/18.
//  Copyright © 2018 Yasmine. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ListOfProductsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
   // MARK: @IBOulets
    @IBOutlet weak var ProductsTableView: UITableView!
    
    
    //MARK: Properties
   var productsList = [ProductDataModel]()
    
    
    //Mark: Segue Properties
    var name : String?
    var price : String?
    var desc : String?
    var imagePath: String?
    
    
    
    
    //viewDidLod method it's called only once when view controller contents initialized and set
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProductsTableView.delegate = self
        ProductsTableView.dataSource = self
        
        checkIfAppConnectedToInternet()
        
        
        ProductsTableView.rowHeight = UITableViewAutomaticDimension
        ProductsTableView.estimatedRowHeight = 251
        
        //fetchDataFromJsonToAppendInToArray()
       
    }
    
    
    
    
    //MARK: @TableViewReimplementedMethod
    
    
    //This method reimplemented as part of UITableViewDelegate
    // Express the number of sections in TableView
    // Default is 1 if not implemented
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    

    // This Method must re-implemented
    // Control the number of rows in UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return productsList.count
    }
    
    
    // This Method must reimplemnted
    // called to fill UITableView cells with Data. It is only one cell and reused
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // reuse cell
        let cell = ProductsTableView.dequeueReusableCell(withIdentifier: "Cell" ,for:indexPath) as! ProductTableViewCell
        let product = productsList[indexPath.row] as ProductDataModel
 
            cell.ProductNameCellLbl.text = product.ProductName!
            
            //+ "this is a test for how this application deal with danmaic size of label in cell , we need to know "
      
            cell.ProductPriceCellLbl.text = String(describing:(product.ProductPrice!))
        
            CustomImage().loadImageWithStringUrl(urlString: (product.ProductImage?.ImagePath)!, photoView: cell.ProductImageCellImageView)
        
        return cell
    }
    
    
    // This Method used to get selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
              // Get selected cell data
                let currentCell = productsList[indexPath.row] as ProductDataModel
        
                name = String (describing: (currentCell.ProductName)!)
                price = String((currentCell.ProductPrice)!)
                desc = String (describing: (currentCell.ProductDesc)!)
                imagePath = String((currentCell.ProductImage?.ImagePath)!)
        
               performSegue(withIdentifier:"ShowProductDetails", sender: self)
        
    }
    
    
    
    //     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    //     {
    //        let currentImage = ""
    //        let cropImage = currentImage.GetCropRatio()
    //        return tableView.frame.width / cropImage
    //     }
    
    
    
    //Mark: Private Methods
    
    // Method to fetch products from json file and append the parsing objects in ProductList Array
    func fetchDataFromJsonToAppendInToArray()
    {
        // Json File String URL
        let JsonFileURL = "https://limitless-forest-98976.herokuapp.com/"
        
        // Convert String To Url
        guard let url = URL.init(string: JsonFileURL) else{return}
        
        // open url session and get data from url
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            // if you get data assign it to ProductsData Varaible else return
            guard let ProductsJsonData = data else{return}
            
            // since you get data parse json file data into
            
            do{
                // get data as NSDictionary
                guard let Json = try JSONSerialization.jsonObject(with: ProductsJsonData, options: .mutableContainers) as? NSDictionary else{return}
                
                // use key data to get it's value as NSDictionary
                let JsonData = Json["data"] as! [NSDictionary]
                
                self.deleteRecordsFromCoreData()
                
                let dataExist = self.CheckIfThereIsDataInCoreData()
                
                for dataRow in JsonData
                {
                    let DataOfImage = dataRow["image"] as! NSDictionary
                    let height = Int(DataOfImage["height"] as! String)!
                    let width = Int(DataOfImage["width"] as! String)!
                    
                    let image = ImageDataModel.init(link: DataOfImage["link"] as! String, height: height , width: width)
                    
                    let id = dataRow["id"] as! Int
                    let price = dataRow["price"] as! Int
                    let name = dataRow["name"] as! String
                    let desc = dataRow["productDescription"] as! String
                    let imagepath = image.ImagePath
                    
                    let product = ProductDataModel.init(id:id, name:name , desc:desc , price:price , image: image)
                    
                    self.productsList.append(product)
                    
                        DispatchQueue.main.async {
                            
                            if dataExist == false
                            {
                            // cache data in core data
                                let image = UIImageView()
                                image.image = self.loadImageFromURL(url:imagepath!)
                               // print(image)
                                let imagename = self.saveImageToAppDocumentDirectory(id: String(id), image: image.image!)
                                self.AddRecordToCoreData(imageName: imagename, imagePath: imagepath!, name: name, id: String(id), price: String(price), desc: desc)
                            }
                            else{
                                // check what is new and not saved in core data then save it.
                            }
                            
                      }
                }
                
                //if you reload data without dispatchQueue method
                // the compiler will explain that "This application is modifying the autolayout engine from a background thread after the engine was accessed from the main thread. This can lead to engine corruption and weird crashes."
                
                
                
                
            }catch let jsonerr{
                print("Error from parsing :",jsonerr)
            }
            
            DispatchQueue.main.async {
                self.ProductsTableView.reloadData()
            }
            
        }.resume()
        
    }
    
    
    
    // Method check if urlString is exist in core data if yes return image name in document directory path 
    // which contains all images that cached before
    func checkIfUrlStringIsExistInCoreData(urlString:String)-> String?
    {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        
     do{
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                if(data.value(forKey: "imagepath") as! String) == urlString
                {
                    let imageName = data.value(forKey: "imagename") as! String
                    return imageName
                }
            }
            
        }
        catch {
            
            print("Failed")
        }
       return nil
    }
    
    //Method that save image in document directory and it's name back
    func saveImageToAppDocumentDirectory(id:String , image: UIImage) -> String
    {
            // get the documents directory url
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // choose a name for your image
            let fileName = "image"+id+".png"
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            print (fileURL.path)
    
            // get your UIImage jpeg data representation and check if the destination file url already exists
            if let data = UIImagePNGRepresentation(image),
                !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                   // print(data)
                    // writes the image data to disk
                    try data.write(to: fileURL)
                    print("file saved")
                } catch {
                    print("error saving file:", error)
                }
            }
            
            return fileName
    }
    

    
    func retrieveImageFromDocumentDirectory(ImageName:String)->UIImage?
    {
        
        
        
        
        
        return nil
        
    }
    
    func AddRecordToCoreData(imageName:String , imagePath:String ,name:String, id:String ,price:String,desc:String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Products", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue(imagePath, forKey: "imagepath")
        newUser.setValue(imageName, forKey: "imagename")
        newUser.setValue(name, forKey: "name")
        newUser.setValue(desc, forKey: "desc")
        newUser.setValue(price, forKey: "price")
        newUser.setValue(id, forKey: "id")
        
        do {
            try context.save()
            print("Succeed")
        } catch {
            print("Failed saving")
        }
        
    }

    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: Delete Records
    func deleteRecordsFromCoreData() -> Void {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        
        for object in resultData {
            context.delete(object)
        }
        
        do {
            try context.save()
            print("deleted")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    func CheckIfThereIsDataInCoreData()->Bool
    {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if (result.count == 0)
            {
                
                print ("No data in core data")
                // get data return true
                return false
            }
            else{
                print("Coredata counted ",result.count)
                
                return true
            }
        } catch {
            
            print("Failed")
        }
       return true
    }
    
    func fetchDataFromCoreData() -> [NSManagedObject]?
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            return result as! [NSManagedObject]
            
        } catch {
            
            print("Failed")
        }
        
      return nil
        
    }
    
    func retriveFromCoreDataWrappedToProductModel(arr : [NSManagedObject]){
//        //var wrappedProducts = [NSDictionary(),String()] as [Any]
//         var wrappedProducts = [NSDictionary]()
//        for row in arr{
//           
//            let image = ImageDataModel.init(link: row.value(forKey: "imagepath") as! String, height: 0, width: 0)
//            let imgName = row.value(forKey: "imagename")
//            let productObj = ProductDataModel.init(id: Int(row.value(forKey: "id") as! String)!, name: row.value(forKey: "name") as! String, desc: row.value(forKey: "desc") as! String, price: Int(row.value(forKey: "price")as! String)!, image: image)
//            
//           var wrappedProductElement = [productObj,imgName]
//            wrappedProducts.append(wrappedProductElement)
           
//        }
//        
//        return wrappedProducts
    }

    func loadImageFromURL(url:String)-> UIImage?
    {
        var image = UIImage()
        let catPictureURL = URL(string:url)!
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    //print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        image = UIImage(data: imageData)!
                        
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        
        downloadTask.resume()
        return image
        
    }
    
    

   
    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if (segue.identifier == "ShowProductDetails") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! DetailsOfProductViewController
            // your new view controller should have property that will store passed value
            viewController.productName = name
            viewController.productPrice = price
            viewController.productDescrib = desc
            viewController.productImagePath = imagePath
           
       }
   
   }
}



extension ListOfProductsViewController{
    
    //function to check reachability
    func isConnectedToInternet() ->Bool {
       return NetworkReachabilityManager()!.isReachable
  }
    
    func checkIfAppConnectedToInternet()
    {
        let connected = isConnectedToInternet()
        if connected == true
        {
            do{
                
                
                fetchDataFromJsonToAppendInToArray()
                
               }
            catch{
                
                print ("can't fetch from internet ")
                
            }
        }
        else{
            // if there isn't internet load data from core 
            
            
        }
    }
    
}


