//
//  UsernameViewController.swift
//  XOXGame
//
//  Created by Berk on 12/11/17.
//  Copyright © 2017 Berk. All rights reserved.
//

import UIKit

protocol UsernameDelegate {
    func onUsernameSet()
}

class UsernameViewController: UIViewController, GameDataSourceDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let minUsernameLimit = 3
    let maxUsernameLimit = 12
    
    let gameDataSource = GameDataSource()
    var type = ""
    var delegate: UsernameDelegate?
    
    var keyboardHeight: CGFloat = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameDataSource.delegate = self
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.text = ""
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let info = sender.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardHeight = keyboardFrame.size.height
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.confirmButton.transform = self.confirmButton.transform.translatedBy(x: 0, y: -keyboardFrame.size.height)
            self.cancelButton.transform = self.confirmButton.transform.translatedBy(x: 0, y: 0)
            self.usernameTextField.transform = self.usernameTextField.transform.translatedBy(x: 0, y: -40)
            self.errorLabel.transform = self.errorLabel.transform.translatedBy(x: 0, y: -40)
        })
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.confirmButton.transform = self.confirmButton.transform.translatedBy(x: 0, y: self.keyboardHeight)
            self.cancelButton.transform = self.confirmButton.transform.translatedBy(x: 0, y: 0)
            self.usernameTextField.transform = self.usernameTextField.transform.translatedBy(x: 0, y: 40)
            self.errorLabel.transform = self.errorLabel.transform.translatedBy(x: 0, y: 40)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardDismiss() {
        usernameTextField.resignFirstResponder()
    }

    func checkUsername() -> Bool {
        let usernameLength = (usernameTextField.text?.count)!
        
        if (usernameLength < minUsernameLimit) {
            errorLabel.text = "Username can't be shorter than \(minUsernameLimit) characters."
            return false
        } else if(usernameLength > maxUsernameLimit) {
            errorLabel.text = "Username can't be longer than \(maxUsernameLimit) characters."
            return false
        } else if(usernameTextField.text == "Bot") {
            errorLabel.text = "Username can't be \"Bot\"."
            return false
        } else {
            errorLabel.text = ""
            return true
        }
    }
    
    func onSuccess() {
        self.dismiss(animated: true) {
            self.delegate?.onUsernameSet()
        }
    }
    
    func onError(action: ErrorAction, error: String) {
        errorLabel.text = error
        activityIndicator.isHidden = true
        confirmButton.isEnabled = true
        cancelButton.isEnabled = true
    }
    
    @IBAction func onConfirmClick(_ sender: Any) {
        keyboardDismiss()
        if(checkUsername()) {
            activityIndicator.isHidden = false
            confirmButton.isEnabled = false
            cancelButton.isEnabled = false
            gameDataSource.updateUsername(username: usernameTextField.text!)
        }
    }
    
    @IBAction func onCancelClick(_ sender: Any) {
        keyboardDismiss()
        self.dismiss(animated: true) {
            if(self.type == "Loading") {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
