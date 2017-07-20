//
//  AuthorizationViewController.swift
//  TestForBalinaSoft(Swift)
//
//  Created by Zakhar on 7/18/17.
//  Copyright © 2017 BalinaSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var loginLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmLabel: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var loginPageSelectedView: UIView!
    @IBOutlet weak var registrationPageSelectionView: UIView!
    @IBOutlet weak var viewUnderConfirmPassword: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginPageSelectedView.isHidden = true
        registrationPageSelectionView.isHidden = false
        actionButton.titleLabel?.text = "SIGN IN"
        viewUnderConfirmPassword.isHidden = false
        confirmLabel.isHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.value(forKey: "token") != nil {
            let storyboard = UIStoryboard(name: "Reveal", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Actions
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "LOG IN" {
            ServerManager.shared.signIn(login: loginLabel.text!, password: passwordLabel.text!, complition: { success, response, error in
                if success == true {
                    DispatchQueue.main.async {

                        let storyboard = UIStoryboard(name: "Reveal", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
                        self.present(vc, animated: true, completion: nil)
                        
                        let token = response?["data"]["token"].stringValue
                        UserDefaults.standard.setValue(token, forKey: "token")
                        let login = response?["data"]["login"].stringValue
                        UserDefaults.standard.setValue(login, forKey: "login")
                    }
                } else {
                    let alertController = UIAlertController(title: "Ой", message: error, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            if confirmLabel.text == passwordLabel.text {
                ServerManager.shared.signUp(login: loginLabel.text!, password: passwordLabel.text!, complition: { success, response, error in
                    if success == true {
                        DispatchQueue.main.async {
                            
                            let storyboard = UIStoryboard(name: "Reveal", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
                            self.present(vc, animated: true, completion: nil)

                            let token = response?["data"]["token"].stringValue
                            UserDefaults.standard.setValue(token, forKey: "token")
                            let login = response?["data"]["login"].stringValue
                            UserDefaults.standard.setValue(login, forKey: "login")
                        }
                    } else {
                        let alertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            } else {
                let alertController = UIAlertController(title: "Ошибка", message: "Пароли не совпадают", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginPageButtonPressed(_ sender: UIButton) {
        loginPageSelectedView.isHidden = false
        registrationPageSelectionView.isHidden = true
        actionButton.titleLabel?.text = "LOG IN"
        viewUnderConfirmPassword.isHidden = true
        confirmLabel.isHidden = true
        loginLabel?.text = nil
        loginLabel?.placeholder = "Login"
        passwordLabel?.text = nil
        passwordLabel?.placeholder = "********"
    }
    
    @IBAction func registrationPageButtonPressed(_ sender: UIButton) {
        loginPageSelectedView.isHidden = true
        registrationPageSelectionView.isHidden = false
        actionButton.titleLabel?.text = "SIGN IN"
        viewUnderConfirmPassword.isHidden = false
        confirmLabel.isHidden = false
        loginLabel?.text = nil
        loginLabel?.placeholder = "Login"
        passwordLabel?.text = nil
        passwordLabel?.placeholder = "********"
        confirmLabel?.text = nil
        confirmLabel?.placeholder = "********"
    }
    
    
}
