//
//  TransmitirViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 01/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import Spring
import FirebaseAuth
import FirebaseDatabase

class TransmitirViewController: UIViewController,  CBPeripheralManagerDelegate {

    @IBOutlet weak var ballView: SpringView!
    var beaconRegion : CLBeaconRegion!
    var beaconPeripheralData : NSDictionary!
    var peripheralManager : CBPeripheralManager!
    
    var urlfotoUsuario: String = ""
    var minor: Int = 1
    var refDB: DatabaseReference!
    
    
    var image =  UIImage(named: "")
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
       
        
        refDB = Database.database().reference()
        initBeaconRegion()
        changeBall()
        
        self.urlfotoUsuario = UserDefaults.standard.string(forKey: "url_foto") ?? "https://cdn.pixabay.com/photo/2015/03/26/21/33/hot-air-balloon-693452_960_720.jpg"
        
        //self.urlfotoUsuario = "https://cdn.pixabay.com/photo/2015/03/26/21/33/hot-air-balloon-693452_960_720.jpg"
        ponerImagendesdeURL()

       
//        ballView.backgroundColor = UIColor(patternImage: UIImage(named: "mujer.jpg")!)
//        ballView.contentMode = UIViewContentMode.scaleAspectFit
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("\(key) = \(value) \n")
//        }
        
        // Do any additional setup after loading the view.
        //tabBarController?.selectedIndex = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //traer datos
    
    func ponerImagendesdeURL()
    {
        
        do {
            let url = URL(string: self.urlfotoUsuario)
            let data = try Data(contentsOf: url!)
            self.image =  UIImage(data: data)
            self.ballView.layer.contents = image?.cgImage
            self.ballView.contentMode = UIViewContentMode.scaleAspectFill
        }
        catch{
            print(error)
        }
    }
    
    func userMinor(uminor:Int , completion: @escaping (Int) -> ())
    {
        let userID = Auth.auth().currentUser?.uid
        self.refDB.child("users").child(userID!).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let minor = value?["minor"] as? Int ?? 1
            completion(minor)
        }
    }

    //funciones para transmitir beacon
    func initBeaconRegion()
    {
        self.userMinor(uminor: minor) { (intMinor) -> () in
            self.minor = intMinor
            self.beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "782F6BEB-E745-4481-9D9C-61A9C44CBA0E")!,
                                               major: 1,
                                               minor: CLBeaconMinorValue(self.minor),
                                               identifier: "com.BeHere")
        }
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        if (peripheral.state == .poweredOn) {
            peripheralManager .startAdvertising(beaconPeripheralData as? [String : Any])
            print("Powered On")
        } else {
            peripheralManager .stopAdvertising()
            print("Not Powered On, or some other error")
        }
    }

    @IBAction func transmitir(_ sender: Any)
    {
        beaconPeripheralData = beaconRegion .peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil)
        UIView.animate(withDuration: 0.1, animations:
            {
                self.ballView.layer.contents = self.image?.cgImage
                self.ballView.contentMode = UIViewContentMode.scaleAspectFill
        }, completion: { finished in
            UIView.animate(withDuration: 0.5, animations: {
                self.ballView.layer.contents = self.image?.cgImage
                self.ballView.contentMode = UIViewContentMode.scaleAspectFill
            })
        })
        
        animateView()
        //print(uuid)
    }
    
    func setOptions() {
        ballView.force = 2
        ballView.duration = 1.8
        ballView.delay = 0
        
        ballView.damping = 0.7
        ballView.velocity = 0.7
        ballView.scaleX = 2
        ballView.scaleY = 2
        ballView.x = 0
        ballView.y = 0
        ballView.rotate = 0
        
        //ballView.animation = animations[selectedRow].rawValue
        ballView.animation = "pop"
        ballView.curve = "easeInOutCubic"
        
       
    }
    
    func animateView() {
        setOptions()
        ballView.animate()
    }
    
    var isBall = false
    func changeBall() {
        isBall = !isBall
        let animation = CABasicAnimation()
        let halfWidth = ballView.frame.width / 2
        let cornerRadius: CGFloat = isBall ? halfWidth : 10
        animation.keyPath = "cornerRadius"
        animation.fromValue = isBall ? 10 : halfWidth
        animation.toValue = cornerRadius
        animation.duration = 0.2
        ballView.layer.cornerRadius = cornerRadius
        ballView.layer.add(animation, forKey: "radius")
    }
    
    
    /// Crear un evento nuevo
    ///
    /// - Parameter sender: any
    @IBAction func crearEvento(_ sender: Any)
    {
        let currentTopVC: UIViewController? = self.currentTopViewController()
        let alertController = UIAlertController(title: "Crear Evento", message: "¿Seguro que quieres hacer un evento? Saldras de la aplicacion y entraras de nuevo.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            let userID = Auth.auth().currentUser?.uid
            let update = self.refDB.child("users").child(userID!)
            //update.updateChildValues(["tipo_usuario" : 0])
            
            update.updateChildValues(["tipo_usuario" : 0]) { (error, nada) in
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
    
    func buscarNuevosEventos ()
    {
        //si las fechas actuales y anteriores son menos de 5 min
        //notificar a usuario de nuevo evento, caso contrario, nada 
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
    
}
