//
//  LoginViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit
import KeychainAccess
class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties:UI
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let signupNC = UINavigationController()
    // MARK: - Logic:View
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        passwordText.delegate = self
        
        loginButton.isEnabled = true
        loginButton.setBackgroundImage(UIImage().makeImageWithColorAndSize(color: UIColor.gray, size: loginButton.frame.size), for: .disabled)
        
        if let remember = Auth.getRemember() {
            loginButton.isEnabled = false
            let processPopup = progressBarDisplayer("Loging...",true)
            APIWrapper.instance().tokenAuth(remember.apiToken, { (user) in
                Auth.login(user: user, apiToken: remember.apiToken)
                self.performSegue(withIdentifier: "entry", sender: nil)
                processPopup.removeFromSuperview()
                }, { (error) in
                    self.loginFailedAlert(message: error)
                    self.loginButton.isEnabled = true
                    processPopup.removeFromSuperview()
            })
        }
        if let username = UserDefaults.standard.string(forKey: "username"){
            usernameText.text = username
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField==usernameText){
            textField.resignFirstResponder()
            passwordText.becomeFirstResponder()
            return true
        }else if(textField == passwordText){
            textField.resignFirstResponder()
            loginAction(loginButton)
            return true
        }
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    // MARK: - Logic:Actions

    @IBAction func loginAction(_ sender: AnyObject) {
        loginButton.isEnabled = false
        Auth.deleteRemember()
        
        if (usernameText.text == "" || passwordText.text == "") {
            self.loginFailedAlert(message: "Please Fill username and password fields")
            loginButton.isEnabled = true
            return;
        }
        
        usernameText.resignFirstResponder()
        passwordText.resignFirstResponder()
        let processPopup = progressBarDisplayer("Loging...",true)
        APIWrapper.instance().basicAuth((usernameText.text!,passwordText.text!), { (user, apiToken) in
            Auth.login(user: user, apiToken: apiToken, remember:true)
            self.performSegue(withIdentifier: "entry", sender: sender)
            processPopup.removeFromSuperview()
        }) { (error) in
            self.loginFailedAlert(message: error)
            self.loginButton.isEnabled = true
            processPopup.removeFromSuperview()
        }
    }
    
    @IBAction func signUpClick(_ sender: UIButton) {
        if(signupNC.viewControllers.count==0){
            
            let webViewController = UIViewController()
            let webView = UIWebView(frame: webViewController.view.frame)
            webView.loadRequest(URLRequest(url: URL(string: "https://www.desktoppr.co/register")!))
            webView.scalesPageToFit = true
            
            
            webViewController.view.addSubview(webView)
            webViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSignup))
            webViewController.navigationItem.title = "Sign Up"
            signupNC.popToRootViewController(animated: false)
            signupNC.pushViewController(webViewController, animated: true)
        }
        
        signupNC.modalPresentationStyle = .currentContext
        signupNC.modalTransitionStyle = .coverVertical

        
        present(signupNC, animated: true, completion: nil)
        //UIApplication.shared.openURL(URL(string: "https://www.desktoppr.co/register")!)
    }
    
    func dismissSignup() {
        signupNC.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helpers
    func loginFailedAlert(message:String?){
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    
    
    func progressBarDisplayer(_ msg:String, _ indicator:Bool ) -> UIView {
        var messageFrame = UIView()
        var strLabel = UILabel()
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            var activityIndicator = UIActivityIndicatorView()
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
        return messageFrame
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
 

}
