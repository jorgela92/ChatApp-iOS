//
//  UsersViewController.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import UIKit
import MMProgressHUD

protocol UsersViewControllerDelegate: AnyObject {
    func logaut()
    func updateUser()
    func uploadImage(image: UIImage)
}

class UsersViewController: GenericViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var usersViewModel: UsersViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        usersViewModel.firebaseUsersViewModelDelegate = self
        tableView.register(UINib(nibName: String(describing: ChatReceiveTableViewCell.self) ,bundle:nil), forCellReuseIdentifier: String(describing: ChatReceiveTableViewCell.self))
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        getData()
    }
    
    private func getData(){
        usersViewModel.usersViewControllerDelegate?.updateUser()
    }
    
    @IBAction func backBUtton(_ sender: UIBarButtonItem) {
        self.usersViewModel?.usersViewControllerDelegate?.logaut()
        self.dismiss(animated: true)
    }
    
    @IBAction func changeImageUser(_ sender: UIBarButtonItem) {
        self.imagePicker.delegate = self.usersViewModel
        self.selectImage(sender)
    }
}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersViewModel.getUserArrayNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatReceiveTableViewCell.self), for: indexPath) as! ChatReceiveTableViewCell
        cell.descriptionLabel.isHidden = true
        cell.descriptionLabel.text = ""
        cell.labelHour.isHidden = true
        cell.labelHour.text = ""
        cell.titleLabel.text = SwiftUtils().shortUser(user: usersViewModel.getUser(index: indexPath.row))
        usersViewModel.downloadImagenFirebaseProfileUser(image: cell.imageCell, index: indexPath.row)
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MMProgressHUD.show()
        if let chatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatController") as? ChatViewController, let userViewModel = usersViewModel, let firebaseViewModel = userViewModel.firebaseViewModel{
            chatViewController.chatViewModel = ChatViewModel(firebaseViewModel: firebaseViewModel, userReceiver: SwiftUtils().shortUser(user: usersViewModel.getUser(index: indexPath.row)))
            let navController = UINavigationController(rootViewController: chatViewController)
            self.present(navController, animated:true, completion: nil)
        } else {
            MMProgressHUD.dismiss()
        }
    }
}

extension UsersViewController: FirebaseUsersViewModelDelegate {
    func imagePickerControllerDidCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
        MMProgressHUD.dismiss()
    }
    
    func insertElementTableView(index: Int) {
        self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.automatic)
    }
    
    func error(error: String) {
        MMProgressHUD.dismissWithError(error)
    }
}

