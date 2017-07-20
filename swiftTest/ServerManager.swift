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
    
    //MARK: - Photos
    
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
                if status == 500 {
                    complition(true, nil, "removePhotoError")
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
    }
    
    //MARK: - Comments
    
    func postComment(imageId: Int, text: String, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let token = UserDefaults.standard.value(forKey: "token") as? String
        let params: Parameters = [ "text" : text]
        let headers: HTTPHeaders = [ "Access-Token": token!]
        
         Alamofire.request("http://213.184.248.43:9099/api/image/\(imageId)/comment", method:.post, parameters: params, encoding:JSONEncoding.default, headers : headers).responseJSON {
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
    
    func removeComment(commentId: Int, imageId: Int, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let token = UserDefaults.standard.value(forKey: "token") as? String
        
        let params: Parameters = ["imageId" : imageId, "commentId" : commentId]
        
        
        Alamofire.request("http://213.184.248.43:9099/api/image/\(imageId)/comment/\(commentId)", method: .delete, parameters: params, encoding: JSONEncoding.default, headers: ["Access-Token": token!]).responseJSON {
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
    
    func getComments(page: Int, imageId: Int, complition: @escaping (Bool, JSON?, String?) -> ()) {
        
        let token = UserDefaults.standard.value(forKey: "token") as? String
        
        let params: Parameters = ["imageId" : imageId, "page": page]
        
        Alamofire.request("http://213.184.248.43:9099/api/image/\(imageId)/comment", method: .get, parameters: params, encoding: URLEncoding.default, headers: ["Access-Token": token!]).responseJSON {
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
}
