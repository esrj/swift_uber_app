//
//  RegisterViewController.swift
//  proj1
//
//  Created by sam on 2023/9/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {


    @IBOutlet var userMode: UISwitch!
    @IBOutlet var email: UITextField!
    @IBOutlet var password2: UITextField!
    @IBOutlet var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.tintColor = UIColor.black
        email.layer.borderColor = UIColor.lightGray.cgColor
        email.layer.cornerRadius = 0
        email.layer.borderWidth = 0.5
        email.leftViewMode = .always
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: email.frame.size.height))
        
        password.tintColor = UIColor.black
        password.leftViewMode = .always
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: password.frame.size.height))
        let leftBorderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: password.frame.size.height))
        leftBorderView.backgroundColor = UIColor.gray
        let rightBorderView = UIView(frame: CGRect(x: password.frame.size.width-0.5, y: 0, width: 0.5, height: password.frame.size.height))
        rightBorderView.backgroundColor = UIColor.lightGray
        password.addSubview(leftBorderView)
        password.addSubview(rightBorderView)
        
        
        
        password2.tintColor = UIColor.black
        password2.layer.borderColor = UIColor.lightGray.cgColor
        password2.layer.cornerRadius = 0
        password2.layer.borderWidth = 0.5
        password2.leftViewMode = .always
        password2.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: email.frame.size.height))
    }
    
    
    
    
    @IBAction func register(_ sender: Any) {
        
        
        if let email = self.email.text {
            if let password = self.password.text{
                if let password2 = self.password2.text{
                    if password == password2{
                        if password.count < 8{
                            let alertController = UIAlertController(title: "提醒", message: "密碼不得少於 8 個字", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "確定", style: .default,handler: nil)
                            alertController.addAction(alertAction)
                            self.present(alertController, animated: true)

                        }else{
                            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                                if error != nil{
                                    if String(describing: (error! as NSError).userInfo["FIRAuthErrorUserInfoNameKey"]!) ==  "ERROR_INVALID_EMAIL" {
                                        let alertController = UIAlertController(title: "提醒", message: "email 格式不正確", preferredStyle: .alert)
                                        let alertAction = UIAlertAction(title: "確定", style: .default,handler: nil)
                                        alertController.addAction(alertAction)
                                        self.present(alertController, animated: true)
                                    }
                                }else{
                                    // 註冊成功 設定 displayname
                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    if self.userMode.isOn{
                                        changeRequest?.displayName = "driver"
                                        changeRequest?.commitChanges(completion: nil)
                                        self.dismiss(animated: true)
                                    }else{
                                        changeRequest?.displayName = "rider"
                                        changeRequest?.commitChanges(completion: nil)
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                        }
                    }else{
                        let alertController = UIAlertController(title: "提醒", message: "密碼不相符", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "確定", style: .default,handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true)
                    }
                }
            }
        }else{
            let alertController = UIAlertController(title: "提醒", message: "表單未寫完整", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "確定", style: .default,handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }

        
    }

    
    @IBAction func backToLoginView(_ sender: Any) {
        dismiss(animated: true)
        
    }


}
