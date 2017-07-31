//
//  WelcomeViewController.swift
//  Flash Chat
//
//  This is the welcome view controller - the first thing the user sees
//

import UIKit
import GoogleSignIn
import SVProgressHUD
import Firebase
import FBSDKLoginKit
//import FBSDKCoreKit

class WelcomeViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
 //FBSDKLoginButtonDelegate
    
    private let dataURL = "https://databasename.firebaseio.com"
    
    @IBOutlet weak var googleButton: GIDSignInButton!
   
    
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        //facebookButton.delegate = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Google Sign -in
    
    
    
    @IBAction func googleSignInPressed(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
        print("Signing in")
        
    }
    
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
       
        SVProgressHUD.show()
        
        if let error = error {
            print(error.localizedDescription)
            SVProgressHUD.dismiss()
            return
        }
        
        
        print("success logged into Google" , user)
        
        guard let idToken = user.authentication.idToken else {return}
        
        guard let accessToken = user.authentication.accessToken else {return}
        
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account:", err)
                return
            }
            
            guard let uid = user?.uid else {return}
            
                    
            print("Successfully logged into Firebase with Google" , user?.uid)
            
  
            
            SVProgressHUD.dismiss()
            
            self.performSegue(withIdentifier: "goToChat", sender: self)
            
        })
        
    }
    

    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    

    @IBAction func facebookLoginPressed(_ sender: Any) {
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error{
                print("Failed to login: \(error.localizedDescription)" )
                return
            }
            
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            SVProgressHUD.show()
            
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                /*if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }*/
                
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToChat", sender: self)
            })
            
        }
        
        
   
        
    }
    
    
    /*func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
        }
        
        print ("Sucessfully logged in of facebook")
        
    }*/
    
    
    
    
}
