//
//  MapViewController.swift
//  TestForBalinaSoft(Swift)
//
//  Created by Zakhar on 7/18/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import CoreLocation

class MapViewController: UIViewController, SWRevealViewControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    let marker = GMSMarker()
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.revealViewController().delegate = self

        let marker = GMSMarker()
        marker.map = mapView
        
        mapView?.isMyLocationEnabled = true
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        
        blackView.isHidden = true
        
        loadImagesFromPage(page: 0)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Reveal controller delegate
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if (position == FrontViewPosition.right) {
            blackView.isHidden = false
        }
        if (position == FrontViewPosition.left) {
             blackView.isHidden = true
        }
    }
    

    // MARK: Location
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func loadImagesFromPage(page: Int) {
        ServerManager.shared.getPhotos(page: page, complition: { success, response, error in
            if success == true {
                let imagesArray = response?["data"].arrayValue
                for image in imagesArray! {
                    
                    let position = CLLocationCoordinate2D(latitude: image["lat"].doubleValue, longitude: image["lng"].doubleValue)
                    let marker = GMSMarker(position: position)
                    marker.title = "\(image["date"].int32Value)"
                    ServerManager.shared.getImage(imageUrl: image["url"].stringValue, complition: { (success, response, error) in
                        if success == true {
                            marker.icon = compressImage(UIImage(data: response!)!)
                            marker.map = self.mapView
                        }
                    })
                }
            }
        })
    }
    
    //MARK: - CLLocationManagerDelegate
    
    
    func locationManager(_ manager: CLLocationManager,      didUpdateLocations locations: [CLLocation]) {
        
        let location = locationManager.location?.coordinate
        
        cameraMoveToLocation(toLocation: location)
        
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Ошибка доступа к геопозиции", message: "")
    }
    

}


//extension MapViewController: CLLocationManagerDelegate {
//    
//    //MARK: - CLLocationManagerDelegate
//
//    
//    func locationManager(_ manager: CLLocationManager,      didUpdateLocations locations: [CLLocation]) {
//        
//        let location = locationManager.location?.coordinate
//        
//        cameraMoveToLocation(toLocation: location)
//        
//    }
//    
//    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
//        if toLocation != nil {
//            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
//            
//            
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        showAlert(title: "Ошибка доступа к геопозиции", message: "")
//    }
//}

func compressImage (_ image: UIImage) -> UIImage {
    
    let actualHeight:CGFloat = image.size.height
    let actualWidth:CGFloat = image.size.width
    let imgRatio:CGFloat = actualWidth/actualHeight
    let maxWidth:CGFloat = 20.0
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
