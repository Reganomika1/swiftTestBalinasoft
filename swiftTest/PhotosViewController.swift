//
//  PhotosViewController.swift
//  TestForBalinaSoft(Swift)
//
//  Created by Zakhar on 7/18/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage
import CoreData

class PhotosViewController: UIViewController, SWRevealViewControllerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let picker = UIImagePickerController()
    let locationManager = CLLocationManager()
    var longTap: UILongPressGestureRecognizer!
    
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var context : NSManagedObjectContext!
    
    var items = [Item]()
    
    var lat: Double = 0, lng: Double = 0
    var page: Int = 0
//    var items = [Item]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        longTap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longTap.minimumPressDuration = 0.3
        longTap.delegate = self
        longTap.delaysTouchesBegan = true
        self.photoCollectionView.addGestureRecognizer(longTap)
        
        loadImagesFromPage(page: self.page)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        context = appDelegate.persistentContainer.viewContext
//        do {
//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
//            let sort = NSSortDescriptor(key: "date", ascending: false)
//            request.sortDescriptors = [sort]
//            
//            let result = try  context.fetch(request)
//            items = result as! [Item]
//        } catch {}
        
        picker.delegate = self
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:NSNotification.Name(rawValue: "saveContext"), object:nil, queue:nil, using:catchNotification)
    
    }

    func catchNotification(notification:Notification) -> Void {
        photoCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Did update locations
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let cordinate = (manager.location?.coordinate)!
        
        self.lat = cordinate.latitude
        self.lng = cordinate.longitude
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }

    //MARK: - Number of items in section collection view
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            let result = try  context.fetch(request)
            items.removeAll()
            items = result as! [Item]
            print(items.count)
            return items.count
        } catch {
            return 0
        }
    }
    
    //MARK: - Pagination images
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if (items.count - indexPath.row - 4)  == 0 {
//            
//            page += 1
//            
//            loadImagesFromPage(page: self.page)
//        }
    }
    
    func loadImagesFromPage(page: Int) {
        ServerManager.shared.getPhotos(page: page, complition: { success, response, error in
            if success == true {
                let imagesArray = response?["data"].arrayValue
                label : for image in imagesArray! {
                    for object in self.items {
                        if object.itemId == image["id"].int32! {
                            continue label
                        }
                    }
                    let item = Item(context : self.context)
                    item.comment = nil
                    item.imageUrl = image["url"].stringValue
                    item.date = image["date"].int32Value
                    item.lng = image["lng"].doubleValue
                    item.lat = image["lat"].doubleValue
                    item.itemId = image["id"].int32Value
                    self.appDelegate.saveContext()
                }
            }
        })
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if (gestureRecognizer.state != UIGestureRecognizerState.ended){
            return
        }
        
        let point = gestureRecognizer.location(in: self.photoCollectionView)
        
        if let indexPath = (self.photoCollectionView.indexPathForItem(at: point)) {
            
            let objectEntityImage = items[indexPath.item]
            
            let alert = UIAlertController(title: "", message: "Do you want to delete this photo?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                
                ServerManager.shared.removePhoto(itemId: Int(objectEntityImage.itemId), complition: { success, response, error in
                    SDImageCache.shared().removeImage(forKey: objectEntityImage.imageUrl)
                    
                    self.context.delete(objectEntityImage)
                    self.appDelegate.saveContext()
                    self.loadImagesFromPage(page: 0)
                })

            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    
    //MARK: - Cell for item at indexPath
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let objectEntityImage = items[indexPath.item]
        
        cell.imageView.sd_setImage(with: URL(string: objectEntityImage.imageUrl!))
        
        let date = Date(timeIntervalSince1970: TimeInterval(objectEntityImage.date))
        let fomatter = DateFormatter()
        fomatter.dateFormat = "dd.MM.yyyy"
        cell.dateLabel.text = fomatter.string(from: date)
        
        return cell
    }

    
    //MARK: - Did select item in collection view
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PhotoViewer", bundle: nil)
        let photoViewer = storyboard.instantiateViewController(withIdentifier: "photoViewer")  as! PhotoViewerViewController
        photoViewer.objectImageEntity = items[indexPath.item]
        self.navigationController?.pushViewController(photoViewer, animated: true)
    }
    

    
    
    func compressImage (_ image: UIImage) -> UIImage {
        
        let actualHeight:CGFloat = image.size.height
        let actualWidth:CGFloat = image.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 800.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.5
        
        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
        
    }
    
    //MARK: - Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addPickedImage(image: image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addPickedImage(image: image)
        } else {
            print("Something went wrong")
        }
        dismiss(animated:true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getPhotoFromLibrary(_ sender: UIButton) {
        
        picker.delegate = self
        
        let actionSheetController = UIAlertController(title: "Please select", message: nil, preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelActionButton)
        
        let photoActionButton = UIAlertAction(title: "Make photo", style: .default) {[unowned self] action -> Void in
            
            self.picker.allowsEditing = false
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(photoActionButton)
        
        let cameraRollActionButton = UIAlertAction(title: "Take photo", style: .default) {[unowned self] action -> Void in
            
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(self.picker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(cameraRollActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func addPickedImage(image :UIImage) {
        
        let imageData = UIImageJPEGRepresentation(compressImage(image), 0.1)
        let timeInterval: Int = Int(Date().timeIntervalSince1970)
        
        locationManager.startUpdatingLocation()
        
        ServerManager.shared.postPhoto(imageData: imageData!.base64EncodedString(), date: timeInterval, lat: lat, lng: lng, complition: { success, response, error in

            if success == true{
                let item = Item(context: self.context)
                item.comment = nil
                item.imageUrl = response?["data"]["url"].stringValue
                item.date = (response?["data"]["date"].int32Value)!
                item.lng = (response?["data"]["lng"].doubleValue)!
                item.lat = (response?["data"]["lat"].doubleValue)!
                item.itemId = Int32((response?["id"].intValue)!)
                self.appDelegate.saveContext()
            }
        })
    }
}

