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
UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate{

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let picker = UIImagePickerController()
    let locationManager = CLLocationManager()
    var longTap: UILongPressGestureRecognizer!
    var entityDescript :NSEntityDescription!
    
    var fetchedControl: NSFetchedResultsController<NSFetchRequestResult>!
    
    var lat: Double = 0, lng: Double = 0
    var page: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        entityDescript = NSEntityDescription.entity(forEntityName: "Item", in: CoreDataManager.shared.managedObjectContext)
        
        longTap = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longTap.minimumPressDuration = 0.5
        longTap.delegate = self
        longTap.delaysTouchesBegan = true
        self.photoCollectionView.addGestureRecognizer(longTap)
        
        loadItemsFromPage(page: self.page)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        fetchedControl = CoreDataManager.shared.getFetchedResultController(entityName: "Item", sortDescriptor: "date", ascending: false)
        fetchedControl.delegate = self
        
        do {
            try fetchedControl.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        picker.delegate = self
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let cordinate = (manager.location?.coordinate)!
        
        self.lat = cordinate.latitude
        self.lng = cordinate.longitude
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "", message: "didFailWithError", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    //MARK: - Pagination images
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (fetchedControl.fetchedObjects?.count)!-1 == indexPath.row && (fetchedControl.fetchedObjects?.count)!%10 == 0{
            self.page += 1
            loadItemsFromPage(page: self.page)
        }
    }
    
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchedControl.fetchedObjects?.count) != nil {
            return (fetchedControl.fetchedObjects?.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let fetchedItem = fetchedControl.object(at: indexPath) as! Item
        
        cell.imageView.sd_setImage(with: URL(string: fetchedItem.imageUrl!), placeholderImage: #imageLiteral(resourceName: "person"))
        
        let date = Date(timeIntervalSince1970: TimeInterval(fetchedItem.date))
        let fomatter = DateFormatter()
        fomatter.dateFormat = "dd.MM.yyyy"
        cell.dateLabel.text = fomatter.string(from: date)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "PhotoViewer", bundle: nil)
        let photoViewer = storyboard.instantiateViewController(withIdentifier: "photoViewer")  as! PhotoViewerViewController
        photoViewer.fetchedItem = fetchedControl.object(at: indexPath) as! Item
        self.navigationController?.pushViewController(photoViewer, animated: true)
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    
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
    
    //MARK : - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.photoCollectionView.reloadData()
    }
    
    //MARK: - Actions
    
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
    
    func longPressAction(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if (gestureRecognizer.state != UIGestureRecognizerState.ended){
            return
        }
        
        let point = gestureRecognizer.location(in: self.photoCollectionView)
        
        if let indexPath = (self.photoCollectionView.indexPathForItem(at: point)) {
            
            let fetchedItem = fetchedControl.object(at: indexPath) as! Item
            
            let alert = UIAlertController(title: "", message: "Do you want to delete this photo?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                
                ServerManager.shared.removePhoto(itemId: Int(fetchedItem.itemId), complition: { success, response, error in
                    if success == true {
                        if error == "removePhotoError" {
                            let alert = UIAlertController(title: "", message: "Internal Server Error", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            SDImageCache.shared().removeImage(forKey: fetchedItem.imageUrl)
                            
                            CoreDataManager.shared.managedObjectContext.delete(fetchedItem)
                            CoreDataManager.shared.saveContext()
                        }
                    }
                })
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Custom methods
    
    func addPickedImage(image :UIImage) {
        
        let imageData = UIImageJPEGRepresentation(compressImage(image), 0.1)
        let timeInterval: Int = Int(Date().timeIntervalSince1970)
        
        locationManager.startUpdatingLocation()
        
        ServerManager.shared.postPhoto(imageData: imageData!.base64EncodedString(), date: timeInterval, lat: lat, lng: lng, complition: { success, response, error in
            
            if success == true{
                let item = Item(entity: self.entityDescript, insertInto: CoreDataManager.shared.managedObjectContext)
                item.itemId = (response?["data"]["id"].int32!)!
                item.date = (response?["data"]["date"].int32!)!
                item.imageUrl = response?["data"]["url"].stringValue
                item.comment = nil
                item.lat = (response?["data"]["lat"].doubleValue)!
                item.lng = (response?["data"]["lng"].doubleValue)!
                CoreDataManager.shared.saveContext()
            }
        })
    }
    
    func compressImage (_ image: UIImage) -> UIImage {
        
        let actualHeight:CGFloat = image.size.height
        let actualWidth:CGFloat = image.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 500.0
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
    
    func loadItemsFromPage(page: Int) {
        ServerManager.shared.getPhotos(page: page, complition: { success, response, error in
            if success == true {
                let itemsArray = response?["data"].arrayValue
                
                flag: for element in itemsArray! {
                    
                    let fetchedItems = self.fetchedControl.fetchedObjects as! [Item]
                    for object in fetchedItems {
                        if object.itemId == element["id"].int32! {
                            continue flag
                        }
                    }
                    
                    let item = Item(entity: self.entityDescript, insertInto: CoreDataManager.shared.managedObjectContext)
                    item.itemId = element["id"].int32!
                    item.date = element["date"].int32!
                    item.imageUrl = element["url"].stringValue
                    item.comment = nil
                    item.lat = element["lat"].doubleValue
                    item.lng = element["lng"].doubleValue
                    CoreDataManager.shared.saveContext()
                    
                }
            }
        })
    }
}

