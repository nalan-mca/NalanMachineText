//
//  UsersServiceRequest.swift
//  NalanMachineText
//
//  Created by NalaN on 2/3/21.
//

import UIKit

class UsersServiceRequest: WebServiceRequest {
    func getUserLists() {
        
        self.serviceType = .Login
        
        let payLoad: Data = Data()
        
        self.invokeDynamicService(method: kHTTP_GET, data: payLoad)
    }
}
