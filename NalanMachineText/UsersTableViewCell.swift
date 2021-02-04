//
//  UsersTableViewCell.swift
//  NalanMachineText
//
//  Created by NalaN on 2/3/21.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserData(_ user : Users) {
        
        if let firstName = user.firstName, let lastName = user.lastName {
            self.nameLabel.text = firstName + " " + lastName
        }
        
        if let email = user.email {
            self.emailLabel.text = email
        }

        if let avatar = user.avatarUrl, let url = URL.init(string: avatar) {
            self.avatarImageView.startAvatarThumImage(url)
        }
    }
}


extension UIImageView {
    func startAvatarThumImage(_ imageURL: URL) {
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {
                self.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
