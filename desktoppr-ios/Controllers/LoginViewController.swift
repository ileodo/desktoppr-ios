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

        if let remember = Auth.getRemember() {
            loginButton.isEnabled = false
            APIWrapper.instance().tokenAuth(remember.apiToken, { (user) in
                Auth.login(user: user, apiToken: remember.apiToken)
                self.performSegue(withIdentifier: "entry", sender: nil)
                
                }, { (error) in
                    self.loginFailedAlert(message: error)
                    self.loginButton.isEnabled = true
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

        APIWrapper.instance().basicAuth((usernameText.text!,passwordText.text!), { (user, apiToken) in
            Auth.login(user: user, apiToken: apiToken)
            Auth.remember(username: self.usernameText.text!, apiToken: apiToken)
            self.performSegue(withIdentifier: "entry", sender: sender)       
        }) { (error) in
            self.loginFailedAlert(message: error)
            self.loginButton.isEnabled = true
        }
    }
    
    @IBAction func signUpClick(_ sender: UIButton) {
        if(signupNC.viewControllers.count==0){
            
            let webViewController = UIViewController()
            let webView = UIWebView(frame: webViewController.view.frame);
            webView.loadRequest(URLRequest(url: URL(string: "https://www.desktoppr.co/register")!))
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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
 

}
