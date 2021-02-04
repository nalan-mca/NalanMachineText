//
//  AddViewController.swift
//  NalanMachineText
//
//  Created by NalaN on 2/3/21.
//

import UIKit
import CoreData

class AddViewController: UIViewController {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarView: UIView!

    @IBOutlet weak var avatarTxtFld: UITextField!
    @IBOutlet weak var userIdTxtFld: UITextField!
    @IBOutlet weak var firstNameTxtFld: UITextField!
    @IBOutlet weak var lastNameTxtFld: UITextField!
    @IBOutlet weak var emailAddressTxtFld: UITextField!
    
    var editUser : Users?
    
    private var completionRefresh: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let _ = self.editUser {
            self.avatarView.isHidden = false
            self.avatarTxtFld.isHidden = true
            self.title = ""
        } else  {
            self.avatarView.isHidden = true
            self.avatarTxtFld.isHidden = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.actionSave(_:)))
        }
        
        if let userId = self.editUser?.userId {
            self.userIdTxtFld.text = "\(userId)"
        }

        if let firstName = self.editUser?.firstName {
            self.firstNameTxtFld.text = firstName
        }
        
        if let lastName = self.editUser?.lastName {
            self.lastNameTxtFld.text = lastName
        }

        if let email = self.editUser?.email {
            self.emailAddressTxtFld.text = email
        }

        if let avatar = self.editUser?.avatarUrl, let url = URL.init(string: avatar) {
            self.avatarImageView.startAvatarThumImage(url)
        }
    }
    
    func didRefreshUserList(_ completionHandler: (() -> ())?) {
        self.completionRefresh = completionHandler
    }
    
    @IBAction func actionSave(_ sender: Any) {
        _ = self.insertUser()
        _ = try? CoredataStack.sharedInstance.persistentContainer.viewContext.save()
        self.completionRefresh?() ?? ()

        self.navigationController?.popViewController(animated: true)
    }
    
    private func insertUser() -> NSManagedObject? {
        let context = CoredataStack.sharedInstance.persistentContainer.viewContext
        if let user = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context) as? Users {
            
            user.userId = 11
            user.firstName = self.firstNameTxtFld.text
            user.lastName = self.lastNameTxtFld.text

            
            user.email = self.emailAddressTxtFld.text
            user.avatarUrl = self.avatarTxtFld.text
            
            return user
        }
        return nil
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        textField.resignFirstResponder()
        return true
    }
}

