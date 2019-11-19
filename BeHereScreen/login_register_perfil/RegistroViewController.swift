//
//  RegistroViewController.swift
//  
//
//  Created by Andres Abraham Bonilla Gòmez on 17/02/18.
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import FirebaseDatabase


class RegistroViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var CorreoInput: UITextField!
    @IBOutlet weak var EdadInput: UITextField!
    @IBOutlet weak var PasswordInput: UITextField!
    @IBOutlet weak var Password2Input: UITextField!
    @IBOutlet weak var NombreInput: UITextField!
    @IBOutlet weak var ApellidoInput: UITextField!
    @IBOutlet weak var GeneroInput: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var botonRegistro: UIButton!
    @IBOutlet weak var botonRegistroFB: UIButton!
    @IBOutlet weak var esperaRegistro: UIActivityIndicatorView!
    
    
    var refDB: DatabaseReference!
    var flag:Int = 0
    let genero = ["Masculino","Femenino"]
    var dict : [String : AnyObject]!
    var tipoGenero: String = ""
    var imgURLDB: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        esperaRegistro.isHidden = true
        GeneroInput.delegate = self
        GeneroInput.dataSource = self
        botonRegistro.layer.cornerRadius = 22
        botonRegistroFB.layer.cornerRadius = 22
        refDB = Database.database().reference()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+150)
        //CGSizeMake(self.view.frame.width, self.view.frame.height+100))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genero.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genero[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 14)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = genero[row]
        pickerLabel?.textColor = UIColor.white
        return pickerLabel!
    }
    
    @IBAction func registroFacebook(_ sender: Any)
    {
        FBSDKLoginManager().logOut()
        esperaRegistro.isHidden = false
        esperaRegistro.startAnimating()
        let fbLoginManager = FBSDKLoginManager()
        //fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                self.esperaRegistro.stopAnimating()
                print("Failed to login: \(error.localizedDescription)")
                
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error
                {
                    self.esperaRegistro.stopAnimating()
                    //print(user as Any)
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                    
                }
                    if Auth.auth().currentUser != nil
                    {
                        self.esperaRegistro.stopAnimating()
                        self.esperaRegistro.isHidden = true
                        //self.registrarDataFacebook()
                        self.registrarDataFacebook()
                        
                    }
            })
            
        }   
    }
    
    
    @IBAction func registro(_ sender: Any)
    {
        esperaRegistro.isHidden = false
        esperaRegistro.startAnimating()
        let currentTopVC: UIViewController? = self.currentTopViewController()
        if (CorreoInput.text?.isEmpty)! || (PasswordInput.text?.isEmpty)! || (Password2Input.text?.isEmpty)! || (EdadInput.text?.isEmpty)! || (NombreInput.text?.isEmpty)! || (ApellidoInput.text?.isEmpty)!
        {
            esperaRegistro.stopAnimating()
            esperaRegistro.isHidden = true
            let alertController = UIAlertController(title: "Compos", message: "Los campos no estan llenos", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            currentTopVC?.present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            let row = GeneroInput.selectedRow(inComponent: 0)
            tipoGenero = genero[row] as String
            let correo = CorreoInput.text!
            let pass = PasswordInput.text!
            let pass2 = Password2Input.text!
            let nombre = NombreInput.text!
            let apellido = ApellidoInput.text!
            let edad = EdadInput.text!
            
            
            if pass == pass2
            {
                if pass.count < 8
                {
                    esperaRegistro.stopAnimating()
                    esperaRegistro.isHidden = true
                    let alertController = UIAlertController(title: "Contraseña Corta", message: "La contraseña debe tener al menos 8 caracteres", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    currentTopVC?.present(alertController, animated: true, completion: nil)
                    print("contraseñas cortas")
                }
                else
                {
                    
                    Auth.auth().createUser(withEmail: correo, password: pass, completion: { (user, error) in
                        let currentTopVC2: UIViewController? = self.currentTopViewController()
                        if error == nil
                        {
                            self.esperaRegistro.stopAnimating()
                            self.flag = 1
                            self.refDB.child("users/\(user!.uid)/nombre").setValue(nombre)
                            self.refDB.child("users/\(user!.uid)/apellido").setValue(apellido)
                            self.refDB.child("users/\(user!.uid)/tipo_usuario").setValue(1)
                            self.refDB.child("users/\(user!.uid)/UUID").setValue("782F6BEB-E745-4481-9D9C-61A9C44CBA0E")
                            self.refDB.child("users/\(user!.uid)/major").setValue(1)
                            self.refDB.child("users/\(user!.uid)/minor").setValue(1)
                            self.refDB.child("users/\(user!.uid)/Edad").setValue(Int(edad))
                            self.refDB.child("users/\(user!.uid)/Genero").setValue(self.tipoGenero)
                            self.refDB.child("users/\(user!.uid)/imageURL").setValue("https://cdn.pixabay.com/photo/2015/03/26/21/33/hot-air-balloon-693452_960_720.jpg")
                            
                            let alertController = UIAlertController(title: "Listo", message: "Se ha enviado un correo de verificación", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { UIAlertAction in
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
                                currentTopVC2?.present(vc!, animated: true, completion: nil)
                            })
                            alertController.addAction(defaultAction)
                            currentTopVC2?.present(alertController, animated: true, completion: nil)
                        }
                        else
                        {
                            self.esperaRegistro.stopAnimating()
                            self.esperaRegistro.isHidden = true
                            let alertController = UIAlertController(title: "Error", message: "Error al registrarte, intentalo mas tarde", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { UIAlertAction in
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
                                currentTopVC2?.present(vc!, animated: true, completion: nil)
                            })
                            alertController.addAction(defaultAction)
                            currentTopVC2?.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
            }
            else
            {
                self.esperaRegistro.stopAnimating()
                self.esperaRegistro.isHidden = true
                let alertController = UIAlertController(title: "Contraseñas", message: "Las contraseñas no coinciden", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                currentTopVC?.present(alertController, animated: true, completion: nil)
                print("contraseña no coinciden")
            }
        }
    }
    
    @IBAction func verPolitica(_ sender: Any)
    {
        if let url = URL(string: "https://a1865617.wixsite.com/behere/aviso-de-privacidad")
        {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    func registroDatosDB(keyUser: Any)
    {
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/nombre").setValue(self.NombreInput.text)
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/apellido").setValue(self.ApellidoInput.text)
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/tipo_usuario").setValue(1)
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/UUID").setValue("782F6BEB-E745-4481-9D9C-61A9C44CBA0E")
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/major").setValue(1)
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/minor").setValue(1)
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/Edad").setValue(self.EdadInput.text)
        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/Genero").setValue(self.tipoGenero)
    }
    
    func currentTopViewController() -> UIViewController {
        var topVC: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
        while ((topVC?.presentedViewController) != nil) {
            topVC = topVC?.presentedViewController
        }
        return topVC!
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if flag == 1
        {
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                if error == nil
                {
                    print("se envio correo de verificacion")
                }
                else
                {
                    print("algo fallo")
                }
                
            })

        }
        flag = 0
    }
    
    func registrarDataFacebook ()
    {
        if((FBSDKAccessToken.current()) != nil)
        {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    let nombre = self.dict["name"] as! String
                    let genero = self.dict["gender"] as! String
                    if let picture = self.dict["picture"] as? [String : AnyObject]
                    {
                        let imgData = picture["data"] as? [String : AnyObject]
                        let imgUrl = imgData!["url"] as? String ?? ""
                        self.imgURLDB = imgUrl
                        self.refDB.child("users/\(Auth.auth().currentUser!.uid)/imageURL").setValue(imgUrl)
                    }
                    let nombre1 = nombre.components(separatedBy: " ")
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/nombre").setValue(nombre1[0])
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/apellido").setValue("")
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/tipo_usuario").setValue(1)
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/UUID").setValue("782F6BEB-E745-4481-9D9C-61A9C44CBA0E")
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/major").setValue(1)
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/minor").setValue(1)
                    //self.refDB.child("users/\(Auth.auth().currentUser!.uid)/Edad").setValue(Int(edad))
                    self.refDB.child("users/\(Auth.auth().currentUser!.uid)/Genero").setValue(genero)
                    self.saveUserDefaults(nombre: nombre, apellido: "", uuid: "782F6BEB-E745-4481-9D9C-61A9C44CBA0E", tipo_usuario: 1, url_foto: self.imgURLDB)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
                    self.present(vc!, animated: true, completion: nil)
                }
                else
                {
                    print("error")
                }
            })
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
    }
}
