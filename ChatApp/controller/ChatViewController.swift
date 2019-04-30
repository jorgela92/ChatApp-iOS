//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import UIKit
import MMProgressHUD
import MaterialComponents

protocol ChatViewControllerDelegate: AnyObject {
    func buttonClicked(userReceiver: String, message: String, image: UIImage?)
    func updateMessage(userReceiver: String)
    func done(userReciver: String)
}

class ChatViewController: GenericViewController {
    
    @IBOutlet weak var buttonCamera: UIButton!
    @IBOutlet weak var imageCamera: UIImageView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var imageSend: UIImageView!
    @IBOutlet weak var texBoxtHeight: NSLayoutConstraint!
    @IBOutlet weak var constrainTextView: NSLayoutConstraint!
    @IBOutlet weak var textMessage: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewSend: UIView!
    
    var chatViewModel: ChatViewModel!
    
    private var initialConstraintTextViewHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        chatViewModel?.firebaseChatViewModelDelegate = self
        chatViewModel?.chatViewControllerDelegate?.updateMessage(userReceiver: chatViewModel.getUserReceiver())
        
        textMessage.backgroundColor = UIColor.white
        textMessage.textColor = UIColor.black
        textMessage.layer.cornerRadius = 10
        textMessage.delegate = chatViewModel
        initialConstraintTextViewHeight = self.textMessage.frame.height
        viewSend.backgroundColor = MDCPalette.blueGrey.tint400
        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(messageTableViewTapped))
        viewSend.addGestureRecognizer(tabGesture)
        view.addGestureRecognizer(tabGesture)
        tableView.addGestureRecognizer(tabGesture)
        tableView.register(UINib(nibName: String(describing: ChatSendTableViewCell.self) ,bundle:nil), forCellReuseIdentifier: String(describing: ChatSendTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ChatReceiveTableViewCell.self) ,bundle:nil), forCellReuseIdentifier: String(describing: ChatReceiveTableViewCell.self))
        tableView.register(UINib(nibName:String(describing: ImageSendTableViewCell.self) ,bundle:nil), forCellReuseIdentifier: String(describing: ImageSendTableViewCell.self))
        tableView.register(UINib(nibName:String(describing: ImageReceiveTableViewCell.self) ,bundle:nil), forCellReuseIdentifier: String(describing: ImageReceiveTableViewCell.self))
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    @objc private func messageTableViewTapped(){
        UIView.animate(withDuration: 0.5) {
            if self.texBoxtHeight.constant > 250{
                self.texBoxtHeight.constant -= self.detectIphone() ? 310 : 260
                self.constrainTextView.constant -= self.detectIphone() ? 310 : 260
                self.view.layoutIfNeeded()
                self.view.endEditing(true)
                self.scrollToBottom()
            }
        }
    }
    
    private func detectIphone() -> Bool{
        if #available(iOS 11.0, *) {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.tableView.numberOfRows(inSection:  0) - 1,
                section: 0)
            if self.tableView.numberOfRows(inSection:  0) > 1 {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    @IBAction func sendMesage(_ sender: UIButton) {
        chatViewModel.chatViewControllerDelegate?.buttonClicked(userReceiver: chatViewModel.getUserReceiver(), message: textMessage.text ?? "", image: nil)
        textMessage.text = ""
    }
    
    @IBAction func sendImage(_ sender: UIButton) {
        imagePicker.delegate = chatViewModel
        selectImage(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        chatViewModel.chatViewControllerDelegate?.done(userReciver: chatViewModel.getUserReceiver())
        dismiss(animated: true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.getConversationMessagesNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return UITableViewCell()
        } else{
            var cell: UITableViewCell = UITableViewCell()
            if chatViewModel.getConversationMessageMessage(index: indexPath.row).contains("image-") {
                cell = configureCellImage(tableView: tableView, indexPath: indexPath)
            } else {
                cell = configureCellChat(tableView: tableView, indexPath: indexPath)
            }
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets.zero
            return cell
        }
    }
    
    private func configureCellImage(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if chatViewModel.getConversationMessageUser(index: indexPath.row).elementsEqual(chatViewModel.getCurrentUser()) {
            let cell: ImageSendTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageSendTableViewCell.self), for: indexPath) as! ImageSendTableViewCell
            cell.titleLabel.text = chatViewModel.getConversationMessageUser(index: indexPath.row)
            cell.labelHour.text = chatViewModel.getConversationMessageHour(index: indexPath.row)
            chatViewModel.downloadImagenFirebase(image: cell.imageSend, index: indexPath.row, placeholder: "camera")
            chatViewModel.downloadImagenFirebaseProfileUser(image: cell.imageCell, index: indexPath.row, placeholder: "speech")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageReceiveTableViewCell.self), for: indexPath) as! ImageReceiveTableViewCell
            cell.titleLabel.text = chatViewModel.getConversationMessageUser(index: indexPath.row)
            cell.labelHour.text = chatViewModel.getConversationMessageHour(index: indexPath.row)
            chatViewModel.downloadImagenFirebase(image: cell.imageSend, index: indexPath.row, placeholder: "camera")
            chatViewModel.downloadImagenFirebaseProfileUser(image: cell.imageCell, index: indexPath.row, placeholder: "speechblack")
            return cell
        }
    }
    
    private func configureCellChat(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if chatViewModel.getConversationMessageUser(index: indexPath.row).elementsEqual(chatViewModel.getCurrentUser()) {
            let cell: ChatSendTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChatSendTableViewCell.self), for: indexPath) as! ChatSendTableViewCell
            cell.titleLabel.text = chatViewModel.getConversationMessageUser(index: indexPath.row)
            cell.labelHour.text = chatViewModel.getConversationMessageHour(index: indexPath.row)
            cell.descriptionLabel.text = chatViewModel.getConversationMessageMessage(index: indexPath.row)
            chatViewModel.downloadImagenFirebaseProfileUser(image: cell.imageCell, index: indexPath.row, placeholder: "speech")
            return cell
        } else {
            let cell: ChatReceiveTableViewCell =  tableView.dequeueReusableCell(withIdentifier: String(describing: ChatReceiveTableViewCell.self), for: indexPath) as! ChatReceiveTableViewCell
            cell.titleLabel.text = chatViewModel.getConversationMessageUser(index: indexPath.row)
            cell.labelHour.text = chatViewModel.getConversationMessageHour(index: indexPath.row)
            cell.descriptionLabel.text = chatViewModel.getConversationMessageMessage(index: indexPath.row)
            chatViewModel.downloadImagenFirebaseProfileUser(image: cell.imageCell, index: indexPath.row, placeholder: "speechblack")
            cell.viewText.backgroundColor = MDCPalette.lime.tint50
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 0 : UITableView.automaticDimension
    }
}

extension ChatViewController: FirebaseChatViewModelDelegate {
    func textViewDidChange(textView: UITextView) {
        if initialConstraintTextViewHeight != textView.frame.height {
            texBoxtHeight.constant += textView.frame.height - initialConstraintTextViewHeight
            constrainTextView.constant += textView.frame.height - initialConstraintTextViewHeight
            initialConstraintTextViewHeight = textView.frame.height
            viewSend.setNeedsUpdateConstraints()
            textMessage.setNeedsUpdateConstraints()
            buttonSend.setNeedsUpdateConstraints()
            buttonCamera.setNeedsUpdateConstraints()
        }
    }
    
    func textViewDidBeginEditing() {
        if texBoxtHeight.constant < 250{
            texBoxtHeight.constant += detectIphone() ? 310 : 260
            constrainTextView.constant += detectIphone() ? 310 : 260
            view.layoutIfNeeded()
            scrollToBottom()
            viewSend.setNeedsUpdateConstraints()
            textMessage.setNeedsUpdateConstraints()
            buttonSend.setNeedsUpdateConstraints()
            buttonCamera.setNeedsUpdateConstraints()
        }
    }
    
    func showHUD() {
        MMProgressHUD.show()
    }
    
    func dismiss() {
        MMProgressHUD.dismiss()
    }
    
    func imagePickerControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func reloadTableView() {
        tableView.reloadData()
        MMProgressHUD.dismiss()
        scrollToBottom()
    }
    
    func error(error: String) {
        MMProgressHUD.dismissWithError(error)
    }
}
