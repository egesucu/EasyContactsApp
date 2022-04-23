//
//  ContactListViewController.swift
//  EasyContactsApp
//
//  Created by Ege Sucu on 23.04.2022.
//

import UIKit
import Contacts

class ContactListViewController: UIViewController {
    
    @IBOutlet weak var contactTableView : UITableView!
    
    let viewModel = ContactViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.registerTableCell(contactTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.fetchContacts()
        }
    }
}

extension ContactListViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.headers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header = viewModel.headers[section]
        return header.uppercased()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let header = viewModel.headers[section]
        return giveNameList(section: header, list: viewModel.contactList).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let header = viewModel.headers[indexPath.section]
        let contact = giveNameList(section: header, list: viewModel.contactList)[indexPath.row]
        return createCell(tableView, header: header, contact: contact)
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

extension ContactListViewController : ContactViewModelDelegate{
    func reloadTable() {
        self.contactTableView.reloadData()
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
    
    func createCell(_ tableView: UITableView, header: String, contact: CNContact) -> UITableViewCell{
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.basicCellIdentifier) as? BasicContactTableViewCell else {
            return getDummyCell()
        }
        cell.contact = contact
        cell.delegate = self
        return cell
    }
}
