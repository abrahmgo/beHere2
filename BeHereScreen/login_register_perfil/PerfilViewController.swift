//
//  PerfilViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 19/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FacebookCore
import FacebookLogin

class PerfilViewController: UIViewController {

    @IBOutlet weak var correoUsuario: UITextField!
    @IBOutlet weak var nombreUsuario: UITextField!
    @IBOutlet weak var apellidoUsuario: UITextField!
    @IBOutlet weak var passwordUsuario: UITextField!
    @IBOutlet weak var password2Usuario: UITextField!
    @IBOutlet weak var imagenPerfil: UIImageView!
    @IBOutlet weak var CerrarSesion: UIButton!
    //@IBOutlet weak var scrollView: UIScrollView!
    
    let TransmitirClass = RecibirViewController()
    var refDB: DatabaseReference!
    var urlfotoUsuario: String = ""
    var tipo_usuario = 1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        refDB = Database.database().reference()
        self.urlfotoUsuario = UserDefaults.standard.string(forKey: "url_foto") ?? "https://cdn.pixabay.com/photo/2015/03/26/21/33/hot-air-balloon-693452_960_720.jpg"
        CerrarSesion.layer.cornerRadius = 22
        imagenPerfil.layer.cornerRadius = imagenPerfil.frame.height/2
        imagenPerfil.clipsToBounds = true
        //scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+50)
        
        do {
            let url = URL(string: urlfotoUsuario)
            let data = try Data(contentsOf: url!)
            self.imagenPerfil.image = UIImage(data: data)
        }
        catch{
            print(error)
        }
        
        //verDatos()
        
        self.tipo_usuario = UserDefaults.standard.integer(forKey: "tipousuario")
        if tipo_usuario == 0
        {
            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "people.png"), style: .plain, target:self, action: #selector(PerfilViewController.cambiaStandard))
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func cambiaStandard()
    {
        
        let currentTopVC: UIViewController? = self.currentTopViewController()
        let alertController = UIAlertController(title: "Ser Be Here", message: "¿Seguro que quieres pasar a modo Be Here? Saldras de la aplicacion y entraras de nuevo.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            let userID = Auth.auth().currentUser?.uid
            let update = self.refDB.child("users").child(userID!)
            //update.updateChildValues(["tipo_usuario" : 0])
            
            update.updateChildValues(["tipo_usuario" : 1]) { (error, nada) in
                if error != nil
                {
                    print(error?.localizedDescription as Any)
                }
                DispatchQueue.main.async {
                    self.actualizarCerrarSesion()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        currentTopVC?.present(alertController, animated: true, completion: nil)
        
    }
    
    func currentTopViewController() -> UIViewController {
        var topVC: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController
        while ((topVC?.presentedViewController) != nil) {
            topVC = topVC?.presentedViewController
        }
        return topVC!
    }
    
    func verDatos()
    {
//        let userID = Auth.auth().currentUser?.uid
//        refDB.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let nombre = value?["nombre"] as? String ?? ""
//            let apellido = value?["apellido"] as? String ?? ""
//            self.nombreUsuario.text = nombre
//            self.apellidoUsuario.text = apellido
//
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        let nombre = UserDefaults.standard.string(forKey: "Nombre")
        let apellido = UserDefaults.standard.string(forKey: "Apellido")
        
        self.nombreUsuario.text = nombre
        self.apellidoUsuario.text = apellido
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.verDatos()
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        correoUsuario.text = Auth.auth().currentUser?.email
        //refDB = Database.database().reference()
        
    }
    @IBAction func CerrarSesion(_ sender: Any)
    {
        do
        {
            
            try Auth.auth().signOut()
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
            //self.dismiss(animated: true, completion: nil)
            //self.navigationController?.viewControllers = [vc] as! [UIViewController]
            //self.present(vc!, animated: true, completion: self.borrarUserDefaults)
            //UIApplication.shared.keyWindow?.rootViewController = vc
            //self.view.window?.rootViewController?.dismiss(animated: true, completion: borrarUserDefaults)
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CargandoVistas")
            self.present(vc!, animated: true, completion: borrarUserDefaults)
            
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
        }
    }
    func actualizarCerrarSesion ()
    {
        do
        {
            try Auth.auth().signOut()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
            self.present(vc!, animated: true, completion: borrarUserDefaults)
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
        }
    }
  
    func borrarUserDefaults()
    {
        let datosUsusario = UserDefaults.standard
        datosUsusario.removeObject(forKey: "Nombre")
        datosUsusario.removeObject(forKey: "UUID")
        datosUsusario.removeObject(forKey: "Apellido")
        datosUsusario.removeObject(forKey: "tipousuario")
        datosUsusario.removeObject(forKey: "url_foto")
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        datosUsusario.synchronize()
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func vermanual(_ sender: Any)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TutorialBeHere")
        self.present(vc!, animated: true, completion: nil)
    }
}
