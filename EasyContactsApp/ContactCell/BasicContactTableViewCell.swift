//
//  BasicContactTableViewCell.swift
//  EasyContactsApp
//
//  Created by Ege Sucu on 23.04.2022.
//

import UIKit
import Contacts

protocol BasicContactTableViewCellDelegate : AnyObject{
    func nameTapped(name: String)
}

class BasicContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    weak var delegate: BasicContactTableViewCellDelegate?
    
    var contact: CNContact? {
        didSet{
            if let contact = contact {
                if contact.givenName.isEmpty{
                    self.nameLabel.text = contact.organizationName
                } else {
                    self.nameLabel.text = contact.givenName
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        nameLabel.addGestureRecognizer(tap)
    }
    
    @objc func nameTapped(){
        if let contact = contact {
            if contact.givenName.isEmpty{
                delegate?.nameTapped(name: contact.organizationName)
            } else {
                delegate?.nameTapped(name: contact.givenName)
            }
        }
    }

    
}
