//
//  ViewController.swift
//  ContactListProj
//
//  Created by Manpreet Narang on 23/12/17.
//  Copyright © 2017 Netmente. All rights reserved.
//

import UIKit
import APAddressBook

fileprivate let cellIdentifier = String(describing: TableViewCell.self)

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    // MARK:- Outlets and Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    let addressBook = APAddressBook()
    var contacts = [APContact]()
    var boolRefresh = Bool()
    
    // MARK: - life cycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder);
        addressBook.fieldsMask = [APContactField.default, APContactField.thumbnail]
        addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
                                       NSSortDescriptor(key: "name.lastName", ascending: true)]
        addressBook.filterBlock =
            {
                (contact: APContact) -> Bool in
                if let phones = contact.phones
                {
                    return phones.count > 0
                }
                return false
        }
        addressBook.startObserveChanges
            {
                [unowned self] in
                self.loadContacts()
        }
    }
    
    // MARK:- View life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        loadContacts()
    }
    
    // MARK:- Reload Action
    
    @IBAction func reloadButtonPressed(_ sender: AnyObject)
    {
        boolRefresh = true
        loadContacts()
    }
    
    // MARK:- Method for load contact data
    
    func loadContacts()
    {
        activity.startAnimating()
        addressBook.loadContacts
            {
                [unowned self] (contacts: [APContact]?, error: Error?) in
                self.activity.stopAnimating()
                self.contacts = [APContact]()
                if let contacts = contacts
                {
                    self.contacts = contacts
                    
                    self.tableView.reloadData()
                }
                else if error != nil
                {
                    if self.boolRefresh
                    {
                        let alert = UIAlertController(title: "Message", message: "Please allow contact permission from app settings", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                            self.boolRefresh = false
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            NSLog("The \"OK\" alert occured.")
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        }
    }
    
    // MARK:- TableView Datasource Method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)
        if let cell = cell as? TableViewCell
        {
            cell.update(with: contacts[indexPath.row])
        }
        return cell
    }
    
   // MARK:- TableView Delegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
