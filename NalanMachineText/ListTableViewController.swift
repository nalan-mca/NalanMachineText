//
//  ListTableViewController.swift
//  NalanMachineText
//
//  Created by NalaN on 2/3/21.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {
    
    var userData = [Users]()
    
    let kReuseIdentifier = "UsersTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.tableView.tableFooterView = UIView()
                
        let serviceRequest = UsersServiceRequest(delegate: self as WebServiceDelegate)
        serviceRequest.getUserLists()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.userData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifier, for: indexPath) as!  UsersTableViewCell
        let dic =  self.userData[indexPath.row]
        cell.setUserData(dic)
        return cell
    }
        
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      let contextItem = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in

      }
      let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
      return swipeActions
  }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EditUserController", let viewController = segue.destination as? AddViewController, let cell = sender as? UsersTableViewCell {
            
            if let indexPath = self.tableView.indexPath(for: cell) {
                let user =  self.userData[indexPath.row]
                viewController.editUser = user
            }
        }
        else if segue.identifier == "AddUserController", let viewController = segue.destination as? AddViewController {
            viewController.didRefreshUserList {
                self.fetchUserLists()
            }
        }
    }

    func  fetchUserLists() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        if let result = try? CoredataStack.sharedInstance.persistentContainer.viewContext.fetch(request) as? [Users] {
            self.userData = result
            self.tableView.reloadData()
        }
    }

}

extension ListTableViewController : WebServiceDelegate {
    func serviceResponse(serviceInfo: [AnyHashable : Any], urlResponse: URLResponse, serviceType: ServiceType) {
        if let data = serviceInfo["data"] as? [[String: Any]] {
            self.userData = data.map{self.insertUser($0)!}
            _ = try? CoredataStack.sharedInstance.persistentContainer.viewContext.save()
            self.tableView.reloadData()
        }
    }
    
    func serviceFailedWithError(error: Any!, urlResponse: URLResponse?, serviceType: ServiceType) {
        
    }
    
    private func insertUser(_ dic: [String: Any]) -> Users? {
        let context = CoredataStack.sharedInstance.persistentContainer.viewContext
        if let user = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context) as? Users {
            
            if let firstName = dic["first_name"] as? String {
                user.firstName = firstName
            }
            
            if let lastName = dic["last_name"] as? String {
                user.lastName = lastName
            }

            
            if let email = dic["email"] as? String {
                user.email = email
            }

            if let avatar = dic["avatar"] as? String {
                user.avatarUrl = avatar
            }
            
            if let userId = dic["id"] as? NSNumber {
                user.userId = userId.int16Value
            }
                        
            return user
        }
        return nil
    }


}
