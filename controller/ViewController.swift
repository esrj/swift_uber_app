//
//  ViewController.swift
//  proj1
//
//  Created by sam on 2023/9/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

extension UIImage {
    // 缩放图像到指定大小，保持图像质量
    func scaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}


class ViewController: UIViewController {

    @IBOutlet var signInWithGoogle: UIButton!
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        email.tintColor = UIColor.black
        email.layer.borderColor = UIColor.lightGray.cgColor
        email.layer.cornerRadius = 0
        email.layer.borderWidth = 0.5
        email.leftViewMode = .always
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: email.frame.size.height))
        
        password.tintColor = UIColor.black
        password.layer.cornerRadius = 0
        password.leftViewMode = .always
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: email.frame.size.height))
        let leftBorderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: password.frame.size.height))
        leftBorderView.backgroundColor = UIColor.gray
        let rightBorderView = UIView(frame: CGRect(x: password.frame.size.width-0.5, y: 0, width: 0.5, height: password.frame.size.height))
        rightBorderView.backgroundColor = UIColor.lightGray
        let buttomBorderView = UIView(frame: CGRect(x: 0, y: password.frame.size.height-0.5, width: password.frame.size.width, height: 0.5))
        buttomBorderView.backgroundColor = UIColor.lightGray
        password.addSubview(leftBorderView)
        password.addSubview(rightBorderView)
        password.addSubview(buttomBorderView)
        
        signInWithGoogle.layer.borderWidth = 1
        signInWithGoogle.layer.borderColor = UIColor.darkGray.cgColor
        signInWithGoogle.layer.cornerRadius = 6
        
        
        let imageSize = CGSize(width: 35, height: 35)
        if let image = UIImage(named: "google-icon") {
            let scaledImage = image.scaleToSize(size: imageSize)
            signInWithGoogle.imageView?.contentMode = .scaleAspectFit
            signInWithGoogle.setImage(scaledImage, for: .normal)
        }
    }

    @IBAction func signInWithGoogleAction(_ sender: Any) {

        
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            guard let user = result?.user,let idToken = user.idToken?.tokenString else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                if error == nil {
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = "rider"
                    changeRequest?.commitChanges(completion: nil)
                    
                    UserDefaults.standard.set(true, forKey: "userLoggedIn")
                    self.performSegue(withIdentifier: "rider", sender: nil)
                }
            }
        }
    }
    
    @IBAction func register(_ sender: Any) {
        performSegue(withIdentifier: "register", sender: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        if let email = self.email.text{
            if let password = self.password.text{
                Auth.auth().signIn(withEmail: email, password: password) { user, error in
                    if error != nil{
                        let alertController = UIAlertController(title: "提醒", message: "您的帳號或密碼不正確", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "確定", style: .default,handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true)
                    }else{
                        // 保存登入狀態
                        
                        if let displayName = (Auth.auth().currentUser?.displayName){
                            if displayName == "driver"{
                                
                                UserDefaults.standard.set(true, forKey: "userLoggedIn")
                                self.performSegue(withIdentifier: "driver", sender: nil)
                                
                            }else if displayName == "rider"{
                                
                                UserDefaults.standard.set(true, forKey: "userLoggedIn")
                                self.performSegue(withIdentifier: "rider", sender: nil)

                            }
                        }
                    }
                }
            }
        }
    }
}

