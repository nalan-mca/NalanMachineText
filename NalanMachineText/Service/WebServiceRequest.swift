//
//  WebServiceRequest.swift
//  NalanMachineText
//
//  Created by NalaN on 2/3/21.
//

import UIKit
import Foundation

protocol WebServiceDelegate {
    func serviceResponse(serviceInfo: [AnyHashable: Any], urlResponse:URLResponse, serviceType: ServiceType)
    func serviceFailedWithError(error: Any!, urlResponse:URLResponse?, serviceType: ServiceType)
}

enum ServiceType: String {
    case Default
    case Login

    func type() -> String {
        return self.rawValue
    }
}

let TIME_OUT_HTTP = 30.0
let BASE_URL = "https://reqres.in/api/users"
let kHTTP_GET      =     "GET"
let kHTTP_POST     =     "POST"

class WebServiceRequest: NSObject, URLSessionDelegate {

    var serviceType: ServiceType = .Default
            
    var urlRequest: URLRequest!
    
    private var currentSession: URLSession?

    private var delegate: WebServiceDelegate?
    
    convenience init(delegate: WebServiceDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    func serviceURLfor() -> URL {
        let unfilteredString = String(format:BASE_URL)
        let escapedString = unfilteredString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        let serverUrl = URL.init(string: escapedString!)
        print("NSString *webService URL  = %@", unfilteredString);
        return serverUrl!
    }

    func invokeDynamicService(method: String, data: Data) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TIME_OUT_HTTP
        config.timeoutIntervalForResource = TIME_OUT_HTTP
        
        let url = self.serviceURLfor()
        
        self.currentSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        self.urlRequest = URLRequest(url: url)

        if (!data.isEmpty) {
            self.urlRequest.httpBody = data
            let postLength = "\(UInt(data.count))"
            self.urlRequest.setValue(postLength, forHTTPHeaderField: "Content-Length")
        }
        
        if (!method.isEmpty) {
           self.urlRequest.httpMethod =  method
        }
        
        #if TARGET_IPHONE_SIMULATOR
            print("<\(NSStringFromClass(self.self)):\(NSStringFromSelector(#function)):\(#line)>")
            
            var serviceURL = urlRequest.url!
            print("URL SCHEME: \(serviceURL.scheme!)")
            print("URL HOST: \(serviceURL.host!)")
            print("URL PATH: \(serviceURL.path)")
            print("REQUEST METHOD: \(urlRequest.httpMethod)")
            print("REQUEST TIMEOUT: \(urlRequest.timeoutInterval)")
            print("REQUEST HTTP HEADERS: \(urlRequest.allHTTPHeaderFields())")
            var body = urlRequest.httpBody!
            if body != nil {
                print("HTTP BODY: \(String(body, encoding: String.Encoding.nonLossyASCII))")
            }
            else {
                print("This request does not have a body")
            }
        #endif
        
        let task = self.currentSession?.dataTask(with: self.urlRequest, completionHandler: { (data, response, error) -> Void in
            if( error == nil) {
                self.delegateResponseWithData(data: data!, urlResponse: response!)
            }
            else {
                self.delegateWithError(serviceError: error!, urlResponse: response)
            }
        })
        task?.resume()
    }
    
    private func delegateResponseWithData(data: Data, urlResponse: URLResponse) {
        let info = dictionarywith(data: data)
        if httpStatusOK(response: urlResponse) {
              self.delegate?.serviceResponse(serviceInfo: info, urlResponse: urlResponse, serviceType: serviceType)
        }
        else {
            self.operationFailed(result: info, urlResponse: urlResponse)
        }
    }
    
    private func dictionarywith(data: Data) -> [AnyHashable: Any] {
        #if TARGET_IPHONE_SIMULATOR
            print("<\(NSStringFromClass(self.self)):\(NSStringFromSelector(#function)):\(#line)>")
        #endif
        
        if let datastring = NSString(data:data, encoding:String.Encoding.utf8.rawValue) as String? {
            print(datastring)
        }
        
        var info = [AnyHashable: Any]()
        let resultArray = [Any]()
        
        var jsonResponse: Any? = nil
        
        do {
            jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
        }
        catch {}
                
        if let dic = jsonResponse as? [AnyHashable: Any], jsonResponse != nil {
            info = dic
        }
        
        if let list = jsonResponse as? [Any] {
            if list.count > 0 {
                info = [ "List" : resultArray,"Count" : list.count ]
            }
            else {
                info = [ "Count" : list.count ]
            }
        }
        return info
    }

    private func delegateWithError(serviceError: Error, urlResponse: URLResponse?) {
        self.delegate?.serviceFailedWithError(error: serviceError, urlResponse: urlResponse, serviceType: serviceType)
    }
    
    private func httpStatusOK(response: URLResponse) -> Bool {
        let httpResponse = (response as! HTTPURLResponse)

        var status: Bool = false
        
        switch httpResponse.statusCode {
            case 200, 201, 202, 204, 206:
                status = true
                break
            default:
                status = false
                break
        }
        return status
    }
    
    private func operationFailed(result: [AnyHashable: Any], urlResponse: URLResponse) {
        let httpResponse = (urlResponse as! HTTPURLResponse)
        let errCode = httpResponse.statusCode
        
        var userInfo = [String : Any]()
        
        let code = result["code"]
        
        if code != nil {
            userInfo["code"] = code
        }
        
        let message = result["message"]
        if message != nil {
            userInfo["message"] = message
        }
        
        let error = NSError(domain: "App", code: errCode, userInfo: userInfo)
        
        self.delegate?.serviceFailedWithError(error: error,
                                              urlResponse: urlResponse,
                                              serviceType: self.serviceType)
    }
}
