//
//  InicioSesionViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 17/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FacebookCore
import FacebookLogin
import FBSDKLoginKit


class InicioSesionViewController: UIViewController {

    @IBOutlet weak var CorreoUsuario: UITextField!
    @IBOutlet weak var PasswordUsuario: UITextField!
    @IBOutlet weak var inicioSesion: UIButton!
    @IBOutlet weak var inicioSesionFacebook: UIButton!
    @IBOutlet weak var esperaSesion: UIActivityIndicatorView!
    
    var refDB: DatabaseReference!
    
    override func viewDidLoad()
    {
        esperaSesion.isHidden = true
        super.viewDidLoad()
        navigationItem.title = "Iniciar Sesón"
        refDB = Database.database().reference()
        inicioSesion.layer.cornerRadius = 22
        inicioSesionFacebook.layer.cornerRadius = 22
        // Do any additional setup after loading the view.
        
        // ocultar teclado
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @IBAction func InicioSesionFacebook(_ sender: Any)
    {
        FBSDKLoginManager().logOut()
        esperaSesion.isHidden = false
        esperaSesion.startAnimating()
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult) in
            switch loginResult
            {
                case .failed(let error):
                    print("\(error.localizedDescription)")
                case .cancelled:
                    print("usuario cancelo")
                    self.esperaSesion.stopAnimating()
                    self.esperaSesion.isHidden = true
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print(grantedPermissions)
                    print(declinedPermissions)
                    
                    let accessTokenF = AccessToken.current
                    guard let accessTokenString =  accessTokenF?.authenticationToken else { return }
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
                    //let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error {
                            self.esperaSesion.stopAnimating()
                            print("Login error: \(error.localizedDescription)")
                            let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(okayAction)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                       
                        
                        if Auth.auth().currentUser != nil
                        {
                            
                            self.obtenerDatos()
                            
                        }
                }
            }
        }
//        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
//            if let error = error {
//                print("Failed to login: \(error.localizedDescription)")
//                self.esperaSesion.stopAnimating()
//                return
//            }
//
//            guard let accessToken = FBSDKAccessToken.current() else {
//                print("Failed to get access token")
//                self.esperaSesion.stopAnimating()
//                return
//            }
//
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//
//            // Perform login by calling Firebase APIs
//            Auth.auth().signIn(with: credential, completion: { (user, error) in
//                if let error = error
//                {
//
//                    self.esperaSesion.stopAnimating()
//                    print("Login error: \(error.localizedDescription)")
//                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(okayAction)
//                    self.present(alertController, animated: true, completion: nil)
//                    return
//                }
//
//                else
//                {
//                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                    if (result?.isCancelled)!
//                    {
//                        return
//                    }
//                    else
//                    {
//                        // Present the main view
//                        self.esperaSesion.stopAnimating()
//                        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
//                        {
//                            UIApplication.shared.keyWindow?.rootViewController = viewController
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                    }
//                }
//
//
//            })
//
//        }
    }
    
    
    
    @IBAction func InicioSesion(_ sender: Any)
    {
        esperaSesion.startAnimating()
        let correo = CorreoUsuario.text
        let password = PasswordUsuario.text
        if (correo?.isEmpty)! || (password?.isEmpty)!
        {
            esperaSesion.stopAnimating()
            let alertController = UIAlertController(title: "Campos Vacios", message: "Introduce tus datos", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            
            Auth.auth().signIn(withEmail: correo!, password: password!, completion: { (user, error) in
                if error == nil
                {
                    self.esperaSesion.stopAnimating()
                    if (Auth.auth().currentUser?.isEmailVerified)!
                    {
                        self.obtenerDatos()
                        self.esperaSesion.stopAnimating()
                        self.esperaSesion.isHidden = true
                    }
                    else
                    {
                        self.esperaSesion.stopAnimating()
                        self.esperaSesion.isHidden = true
                        let alertController = UIAlertController(title: "Error", message: "Verifica tu correo", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                else
                {
                    self.esperaSesion.stopAnimating()
                    let alertController = UIAlertController(title: "Error", message: "Correo y/o contraseña incorrectos", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    func obtenerDatos ()
    {
        let userID = Auth.auth().currentUser?.uid
        refDB.child("users").child(userID!).observeSingleEvent(of: .value, with:
            { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let nombre = value?["nombre"] as? String ?? ""
                let apellido = value?["apellido"] as? String ?? ""
                let uuid = value?["UUID"] as? String ?? ""
                let tipo_usuario = value?["tipo_usuario"] as? Int ?? 1
                let url_foto = value?["imageURL"] as? String ?? ""
                self.saveUserDefaults(nombre: nombre, apellido: apellido, uuid: uuid, tipo_usuario: tipo_usuario, url_foto: url_foto)
                // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func saveUserDefaults(nombre:String,apellido:String,uuid:String,tipo_usuario:Int, url_foto: String)
    {
        
        let defaults = UserDefaults.standard
        defaults.set(nombre, forKey: "Nombre")
        defaults.set(apellido, forKey: "Apellido")
        defaults.set(uuid, forKey: "UUID")
        defaults.set(tipo_usuario, forKey: "tipousuario")
        defaults.set(url_foto, forKey: "url_foto")
        defaults.synchronize()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
        self.present(vc!, animated: true, completion: nil)
        self.esperaSesion.stopAnimating()
        self.esperaSesion.isHidden = true
    }
    
}
