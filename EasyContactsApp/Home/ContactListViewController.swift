//
//  ContactListViewController.swift
//  EasyContactsApp
//
//  Created by Ege Sucu on 23.04.2022.
//

import UIKit
import Contacts
import Algorithms

class ContactListViewController: UIViewController {
    
    @IBOutlet weak var contactTableView : UITableView!
    
    let contactStore = CNContactStore()
    var contactList : [CNContact] = []
    var headers : [String] = []
    let keysToFetch : [CNKeyDescriptor] = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName) as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.fetchContacts()
        }
    }
    
    func registerCell(){
        contactTableView.register(UINib(nibName: Constants.basicCellIdentifier, bundle: nil), forCellReuseIdentifier: Constants.basicCellIdentifier)
    }
    
    
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
        self.contactTableView.reloadData()
    }
}

extension ContactListViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header = headers[section]
        return header.uppercased()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let header = headers[section]
        return giveNameList(section: header, list: contactList).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let header = headers[indexPath.section]
        let contact = giveNameList(section: header, list: contactList)[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.basicCellIdentifier) as? BasicContactTableViewCell else {
            return getDummyCell()
        }
        cell.contact = contact
        cell.delegate = self
        return cell
        
    }
    
    
}

extension ContactListViewController : BasicContactTableViewCellDelegate{
    
    fileprivate func presentAlert(name: String) {
        let alertController = UIAlertController(title: "Info", message: "\(name)'s Name is copied to the clipboard.", preferredStyle: .actionSheet)
        self.present(alertController, animated: true) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                self.dismiss(animated: true)
            }
        }
    }
    
    func nameTapped(name: String) {
        generateFeedback()
        UIPasteboard.general.string = name
        presentAlert(name: name)
    }
    
}

extension ContactListViewController{
    func giveNameList(section : String, list: [CNContact]) -> [CNContact] {
        return list.filter({ String($0.givenName.prefix(1)) == section })
    }
    
    func getDummyCell() -> UITableViewCell{
        return UITableViewCell()
    }
    
    func generateFeedback(){
        let feedback = UIImpactFeedbackGenerator()
        feedback.impactOccurred()
    }
}
