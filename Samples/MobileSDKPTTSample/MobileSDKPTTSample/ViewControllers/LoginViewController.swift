//
//  LoginViewController.swift
//  MobileSDKPTTSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit
import MIPSDKMobile

class LoginViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    //MARK: IBActions
    @IBAction func login(_ sender: Any) {
        guard let address = address.text, let port = port.text, let portInt = Int(port) else {
            return
        }
        
        activityIndicator.startAnimating()
        
        let serverInfo = XPSDKServerInfo(host: address, port: NSNumber(value: portInt))
        
        XPMobileSDK.connectAndLoginForServerInfo(serverInfo,
                                                 username: username?.text ?? Constants.emptyString,
                                                 password: password?.text ?? Constants.emptyString,
                                                 shouldSave: false,
                                                 successHandler: { [weak self] (response) in
            guard let weakSelf = self else { return }
            weakSelf.activityIndicator.stopAnimating()
            XPMobileSDK.removeDelegate(weakSelf)
            weakSelf.performSegue(withIdentifier: Constants.Login.camerasSegueIdentifier, sender: sender)
        }, failureHandler: { [weak self] (error) in
            self?.activityIndicator.stopAnimating()
            self?.alert(withTitle: Constants.errorTitle, message: Constants.Login.loginErrorMessage)
        })
    }
    
    @IBAction func about(_ sender: Any) {
        alert(withTitle: Constants.Login.loginAboutTitle, message: Constants.Login.loginAboutMessage)
    }
    
    //MARK: Helper methods
    private func setup() {
        title = Constants.Login.loginScreenTitle
        port.text = Constants.Login.loginDefaultPort
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        
        XPMobileSDK.addDelegate(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(note:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(note:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func alert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: Constants.аlertOK,
                                          style: .default,
                                          handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: XPMobileSDKConnectionDelegate methods
extension LoginViewController: XPMobileSDKConnectionDelegate {
    func connectionDidFailConnectWithError(_ error: NSError) {
        alert(withTitle: Constants.errorTitle,
              message: Constants.Login.loginConnectionErrorMessage)
    }

    func connectionCodeError(_ connection: XPSDKConnection) {
        alert(withTitle: Constants.errorTitle,
              message: Constants.Login.loginConnectionErrorMessage)
    }
}

//MARK: UITextFieldDelegate methods
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: Keyboard notifications
extension LoginViewController {
    @objc func keyboardWillShow(note: Notification) {
        guard let userInfo = note.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width,
                                        height: scrollView.frame.size.height + keyboardFrame.height)
    }
    
    @objc func keyboardWillHide(note: Notification) {
        guard let userInfo = note.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width,
                                        height: scrollView.frame.size.height - keyboardFrame.height)
    }
}
