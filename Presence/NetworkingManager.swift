//
//  NetworkingManager.swift
//  Presence
//
//  Created by Michael Selsky on 10/4/14.
//  Copyright (c) 2014 Michael Selsky. All rights reserved.
//

import UIKit

class NetworkingManager: NSObject {
    let baseURL = "http://api.presenceapp.net"
    let updateLocationExtension = "/location/update"
    let getPlaylistExtension = "/playlist"
    let sendPreferenceExtension = "/preference/update"
    var oAuthToken: String?
    
    func updateLocation(latitude:String, longitude:String){
        let jsonDict = ["latitude": latitude, "longitude": longitude, "userid": self.oAuthToken!]
//        println("JSON Request: \(jsonDict)")
        let jsonData = (NSJSONSerialization.dataWithJSONObject(jsonDict, options: nil, error: nil))!
//        println("\(jsonData)")
        let url = NSURL(string: "\(self.baseURL)\(self.updateLocationExtension)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if data != nil {
                let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    let successOptional = json["success"] as AnyObject? as Bool?
                    if let success = successOptional {
                        if !success {
                            //TODO: error handling
                        } else {
                            //Success
                        }
                    } else {
                        //TODO: error handling
                    }
                
                } else {
                    //TODO: Json reading error
                }
                
            } else {
                //Data never came back
            }
        }).resume()
    }
    
    func getNextPlaylist(callback:(String)->()){
        let token = self.oAuthToken!;
        let urlString = "\(self.baseURL)\(self.getPlaylistExtension)?userid=\(token)"
        println(urlString)
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil{
            
            } else {
                let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
                    println(json)
                    let foo = json["success"] as AnyObject?
                    let successOptional = foo as? Bool
                    if let success = successOptional {
                        if !success {
                            //TODO: error handling
                        } else {
                            //Success
                            let trackStringOptional = json["track"] as AnyObject? as String?
                            if let trackString = trackStringOptional{
                                println("\(trackString)")
                                callback(trackString)
                            }
                        }
                    } else {
                        //TODO: error handling
                    }
                    
                } else {
                    //TODO: Json reading error
                }
                
            } 
        }).resume()
    }
    
    func uploadPreferences(preferenceData: [String:AnyObject]){
        let jsonDict = ["userid":self.oAuthToken!, "preferences":preferenceData]
        let jsonData = NSJSONSerialization.dataWithJSONObject(jsonDict, options: nil, error: nil)!
        println("\(jsonData)")
        let url = NSURL(string: "\(self.baseURL)\(self.sendPreferenceExtension)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if data != nil {
//                println("\(data)")
                let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                if let json = jsonOptional as? Dictionary<String, AnyObject> {
//                    println("\(json)")
                    let successOptional = json["success"] as AnyObject? as Bool?
                    if let success = successOptional {
                        if !success {
                            //TODO: error handling
                        } else {
                            //Success
                        }
                    } else {
                        //TODO: error handling
                    }
                    
                } else {
                    let i = 1
                    //TODO: Json reading error
                }
                
            } else {
                //Data never came back
            }
        }).resume()
    }
}
