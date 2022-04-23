//
//  ContactViewModel.swift
//  EasyContactsApp
//
//  Created by Ege Sucu on 23.04.2022.
//

import Contacts
import UIKit
import Algorithms

protocol ContactViewModelDelegate: AnyObject{
    func reloadTable()
}

class ContactViewModel{
    
    static let shared = ContactViewModel()
    
    let contactStore = CNContactStore()
    let keysToFetch : [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName) as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor
    ]
    
    var contactList : [CNContact] = []
    var headers : [String] = []
    
    weak var delegate: ContactViewModelDelegate?
    
    func fetchContacts(){
        contactList.removeAll()
        do {
            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            try contactStore.enumerateContacts(with: request, usingBlock: { contact, stop in
                self.contactList.append(contact)
            })
            self.createHeaders()
            
        } catch let error {
            print(error)
        }
    }
    func createHeaders(){
        headers.removeAll()
        for contact in contactList{
            if contact.givenName.isEmpty{
                let header = String(contact.organizationName.prefix(1))
                headers.append(header)
            } else {
                let header = String(contact.givenName.prefix(1))
                headers.append(header)
            }
        }
        headers = headers.uniqued().sorted().filter({!$0.isEmpty && (Int($0) == nil)})
        delegate?.reloadTable()
    }
    
    func registerTableCell(_ tableView: UITableView){
        tableView.register(UINib(nibName: Constants.basicCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.basicCellIdentifier)
    }
    
}
