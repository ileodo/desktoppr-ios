//
//  LoginViewController.swift
//  desktoppr-ios
//
//  Created by Tianwei Dong on 18/10/2016.
//  Copyright © 2016 Tianwei Dong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties:UI
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    // MARK: - Logic:View
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        passwordText.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField==usernameText){
            textField.resignFirstResponder()
            passwordText.becomeFirstResponder()
            return true
        }else if(textField == passwordText){
            textField.resignFirstResponder()
            loginClicked(nil)
            return true
        }
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    // MARK: - Logic:Actions
    func login(){
    
    }
    @IBAction func loginClicked(_ sender: Any?) {
        let username = usernameText.text ?? ""
        let password = passwordText.text ?? ""
        
        APIWrapper.instance().basicAuth((username,password), { (user, apiToken) in
            Auth.login(user: user)
            Auth.setApiToken(token: apiToken)
            self.performSegue(withIdentifier: "entry", sender: sender)

            
        }) { (error) in
            let alert = UIAlertController(title: "Login Failed", message: error, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpClick(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://www.desktoppr.co/register")!)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
 

}
