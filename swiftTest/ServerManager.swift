//
//  ServerManager.swift
//  TaxiExpressClient
//
//  Created by Zakhar on 7/4/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ServerManager: NSObject {
    
    static let shared = ServerManager()
    
    //MARK: - Security
    
    func signIn(login: String, password: String, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let params: Parameters = ["login" : login, "password" : password]
        
        Alamofire.request("http://213.184.248.43:9099/api/account/signin", method:.post, parameters: params, encoding:JSONEncoding.default).response {
            response in
            let status = response.response?.statusCode
            print(status ?? "status error")
            let data = response.data
            if status == 200 {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    complition(true, json, nil)
                } else {
                    complition(true, nil, nil)
                }
            } else {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    let message = json["message"].string
                    complition(false, json, message)
                }
                complition(false, nil, nil)
            }
        }
    }
    
    func signUp(login: String, password: String, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let params: Parameters = ["login" : login, "password" : password]
        
        Alamofire.request("http://213.184.248.43:9099/api/account/signup", method:.post, parameters: params, encoding:JSONEncoding.default).response {
            response in
            let status = response.response?.statusCode
            print(status ?? "status error")
            let data = response.data
            if status == 200 {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    complition(true, json, nil)
                } else {
                    complition(true, nil, nil)
                }
            } else {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    let message = json["message"].string
                    complition(false, json, message)
                }
                complition(false, nil, nil)
            }
        }
    }
    
    func postPhoto(imageData: String, date: Int, lat: Double, lng: Double, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let token = UserDefaults.standard.value(forKey: "token") as? String
        let params: Parameters = ["base64Image" : imageData, "date" : date, "lat" : lat, "lng" : lng]
        let headers: HTTPHeaders = [ "Accept": "application/json;charset=UTF-8", "Access-Token": token!]
        
        Alamofire.request("http://213.184.248.43:9099/api/image", method:.post, parameters: params, encoding:JSONEncoding.default, headers : headers).response {
            response in
            let status = response.response?.statusCode
            print(status ?? "status error")
            let data = response.data
            if status == 200 {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    complition(true, json, nil)
                } else {
                    complition(true, nil, nil)
                }
            } else {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    let message = json["message"].string
                    complition(false, json, message)
                }
                complition(false, nil, nil)
            }
        }
    }
    
    func getPhotos(page: Int, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let token = UserDefaults.standard.value(forKey: "token") as? String
        
        Alamofire.request("http://213.184.248.43:9099/api/image", method: .get, parameters: ["page": page], encoding: URLEncoding.default, headers: ["Access-Token": token!]).responseJSON {
            response in
            let status = response.response?.statusCode
            print(status ?? "status error")
            let data = response.data
            if status == 200 {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    complition(true, json, nil)
                } else {
                    complition(true, nil, nil)
                }
            } else {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    let message = json["message"].string
                    complition(false, json, message)
                }
                complition(false, nil, nil)
            }
        }
    }
    
    func removePhoto(itemId: Int, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let token = UserDefaults.standard.value(forKey: "token") as? String
        
        Alamofire.request("http://213.184.248.43:9099/api/image/\(itemId)", method: .delete, parameters: ["id": itemId], encoding: JSONEncoding.default, headers: ["Access-Token": token!]).responseJSON {
            response in
            let status = response.response?.statusCode
            print(status ?? "status error")
            let data = response.data
            if status == 200 {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    complition(true, json, nil)
                } else {
                    complition(true, nil, nil)
                }
            } else {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    let message = json["message"].string
                    complition(false, json, message)
                }
                complition(false, nil, nil)
            }
        }
    }
    
    func getImage(imageUrl: String, complition: @escaping (Bool, Data?, String?) -> ()) {
        
        Alamofire.request(imageUrl).responseJSON {
            response in
            let status = response.response?.statusCode
            print(status ?? "status error")
            let data = response.data
            if status == 200 {
                if let data = data {
                    complition(true, data, nil)
                } else {
                    complition(true, nil, nil)
                }
            } else {
                if let data = data {
                    let json = JSON(data: data)
                    print(json)
                    let message = json["message"].string
                    complition(false, data, message)
                }
                complition(false, nil, nil)
            }
        }
    }

    
    

    
    
    func getAdressFromCoordinate(lat: Double, lng: Double, completion: @escaping (NSString) -> ()) {

        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=AIzaSyDb-UfnwILiDMS25zAZVapDXcamJSQMBzo", method: .post, parameters:nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                completion(json["results"][0]["formatted_address"].stringValue as NSString)
            }
        }
    }
}
