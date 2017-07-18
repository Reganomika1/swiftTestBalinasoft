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

class MapViewController: UIViewController, SWRevealViewControllerDelegate {

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
        
        let locationManager = CLLocationManager()
        let marker = GMSMarker()
    
        marker.map = mapView
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        
        loadImagesFromPage(page: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: Location
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("authorizedWhenInUse, authorizedAlways")
            locationManager.startUpdatingLocation()
        case .denied:
            print("denied")
            statusDeniedAlert()
        case .restricted:
            print("restricted")
            showAlert(title: "Доступ к геопозиции запрещен", message: "")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func statusDeniedAlert() {
        let alertController = UIAlertController(title: "Доступ к геопозиции запрещен", message: "Необходимо разрешить приложению доступ к геопозиции в настройках", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Настройки", style: .default, handler: { action in
            if #available(iOS 10.0, *) {
                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            } else {
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil)
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
    

}


extension MapViewController: CLLocationManagerDelegate {
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            print("My coordinates are: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
            
            marker.position = currentLocation.coordinate
            mapView.camera = GMSCameraPosition(target: marker.position, zoom: 17, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Ошибка доступа к геопозиции", message: "")
    }
}

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
