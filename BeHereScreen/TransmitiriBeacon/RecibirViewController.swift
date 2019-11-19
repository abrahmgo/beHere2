//
//  RecibirViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 24/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import FirebaseAuth
import FirebaseDatabase

class RecibirViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {

    //VARIABLES PARA LOCALIZAR
    
    @IBOutlet weak var BubblesView: CSBubblesView!
    var locationManager : CLLocationManager!
    var manager:CBCentralManager!
    var beaconPeripheralData : NSDictionary!
    let PopupManager = BUSimplePopupManager()
    var refDB: DatabaseReference!
    
    var idUser: String = ""
    var datosUsuario = [String]()
    var datosDeUsuarios = [[String]]()
    var tipo_usuario = 1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
      
        //
        
        initPopup()
        refDB = Database.database().reference()
        self.tipo_usuario = UserDefaults.standard.integer(forKey: "tipousuario")
        //bluetooh
        manager = CBCentralManager()
        manager.delegate = self
        //localizar
        locationManager = CLLocationManager.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        startScanningForBeaconRegion(beaconRegion: getBeaconRegion())
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecibirViewController.bubbleWasSelected), name: NSNotification.Name(rawValue: "BubbleWasSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RecibirViewController.bubbleWasDeselected), name: NSNotification.Name(rawValue: "BubbleWasDeselected"), object: nil)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "BackgroundImage")?.draw(in: self.view.bounds)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
       
        
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundImage")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Inicializar la region de busqueda
    ///
    /// - Returns: Region
    func getBeaconRegion() -> CLBeaconRegion
    {
        let beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "782F6BEB-E745-4481-9D9C-61A9C44CBA0E")!,
                                               identifier: "com.BeHere")
        return beaconRegion
    }
    
    /// Inicializar la busqueda
    ///
    /// - Parameter beaconRegion: Region a buscar
    func startScanningForBeaconRegion(beaconRegion: CLBeaconRegion)
    {
        print(beaconRegion)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    func stoptScanningForBeaconRegion(beaconRegion: CLBeaconRegion)
    {
        print(beaconRegion)
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    
    /// Busca beacons
    ///
    /// - Parameters:
    ///   - manager: Parametros del delgado bluetooth
    ///   - beacons: Inicializacion del beacon en modo busqueda
    ///   - region: Region de beacon a escanear
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        var banderaAnadir: Int = 2
        let beacon = beacons.last
        let minorBeacon: Int
        if beacons.count > 0
        {
            //print(beacon?.minor.stringValue ?? 1)
            minorBeacon = Int((beacon?.minor.stringValue)!)!
            if beacon?.proximity == CLProximity.unknown
            {
                print("Unknown Proximity")
            }
            else if beacon?.proximity == CLProximity.immediate || beacon?.proximity == CLProximity.near || beacon?.proximity == CLProximity.far
            {
                print("Immediate Proximity")
                self.buscarUsuario(minor_user: minorBeacon) { (keyUser) in
                    self.idUser = keyUser
                    self.buscarDatosUsuario(key_user: self.idUser) { (dataUser) in
                        
                        self.datosUsuario = dataUser
                        banderaAnadir = self.agregarDatosdeUsuarios(elementoNuevo: self.datosUsuario)
                        if banderaAnadir == 0
                        {
                            self.datosDeUsuarios.append(dataUser)
//                            print("ESTOS SON DATOS DE USUARIO")
//                            dump(self.datosUsuario)
                            self.agregarUsuariosEvento(id_usuario: self.datosUsuario[3])
                            self.BubblesView.dataArray = NSMutableArray(array: [self.datosUsuario[0]])
                        }
                        self.datosUsuario.removeAll()
                    }
                }
            }
        }
//        for i in 0..<(datosDeUsuarios.count)
//        {
//            print(datosDeUsuarios[i][0])
//            print(datosDeUsuarios[i][1])
//        }
        print("Ranging")
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        //locationManager.stopMonitoring(for: getBeaconRegion())
        //locationManager.stopRangingBeacons(in: getBeaconRegion())
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
//        if datosUsuario.isEmpty
//        {
//
//        }
//        else
//        {
//            self.BubblesView.dataArray = NSMutableArray(array: [datosUsuario[0]])
//        }
    }
    
    func initPopup ()
    {
        PopupManager.PopupsBackgroundColor = .white
        PopupManager.PopupsTitleTextColor  = .black
        PopupManager.PopupsBodyTextColor   = .darkGray
        PopupManager.PopupBackgroundAlpha  = 1.0
        PopupManager.PopupsTitleFont       = UIFont.init(name: "Futura", size: 20)!
    }
    
    /// Indica si la burbuja fue presionada, al ser presionada con los datos de adentro ira a buscar los datos del usuario
    ///
    /// - Parameter notification: String dentro de la burbuja
    @objc func bubbleWasSelected(notification: NSNotification)
    {
        if datosDeUsuarios.isEmpty
        {
            
        }
        else
        {
            let nombreBuscar = notification.object as! String
            let i = buscarDatosUsuario(minor: nombreBuscar) 
            PopupManager.showPopup(Popup: BUSimplePopup.init(_title: datosDeUsuarios[i][0],
                                                             _body: datosDeUsuarios[i][1],
                                                             _image: UIImage.init(named: "hombre.jpg")))
            
        }

    }
    
    /// Indica si la burbuja ha dejado de ser presionada
    ///
    /// - Parameter notification: El string que tiene dentro la burbuja
    @objc func bubbleWasDeselected(notification: NSNotification)
    {
        print(notification.object as! String)
    }
    
    /// Indica si el bluetooth esta encendido (delegate)
    ///
    /// - Parameter central: delegado del bluetooth
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
       if central.state == .poweredOff
       {
        print("Bluetooth is not Connected.Please Enable it")
        }
    }
    
    /// Busca en la DB el id unico del usuario por su minor
    ///
    /// - Parameters:
    ///   - minor_user: minor a buscar
    ///   - completion: id del usuario
    func buscarUsuario(minor_user:Int , completion: @escaping (String) -> ())
    {
        let buscarUsuario = refDB.child("users").queryOrdered(byChild: "minor").queryEqual(toValue: minor_user)
        buscarUsuario.observe(.value, with: { (snapshot) in
            for snap in snapshot.children
            {
                let keyUser = (snap as! DataSnapshot).key
                completion(keyUser)
            }
        }) { (error) in
            print("hubo algun error \(error.localizedDescription)")
        }
    }
    
    /// Busca en la DB los datos especificos del usuario
    ///
    /// - Parameters:
    ///   - key_user: id unico del usuario
    ///   - completion: arreglo con los datos del usuario
    func buscarDatosUsuario(key_user:String , completion: @escaping ([String]) -> ())
    {
        refDB.child("users").child(key_user).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var datosUser = [String]()
            let nombreID = value?["nombre"] as? String ?? ""
            let minorID =  value?["minor"] as? Int ?? 1
            let nombreMinorID = nombreID+"-"+String(minorID)
            datosUser.append(nombreMinorID)
            datosUser.append(value?["apellido"] as? String ?? "")
            datosUser.append(String(value?["minor"] as? Int ?? 1))
            datosUser.append(snapshot.key)
            print(datosUser)
            completion(datosUser)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /// Busca los datos del usuario en el arreglo general
    ///
    /// - Parameter minor: minor unico del usuario
    /// - Returns: la posicion en el arreglo del usuario
    func buscarDatosUsuario(minor: String) -> Int
    {
        
        let idMinor = minor.components(separatedBy: "-")
        for i in 0..<(self.datosDeUsuarios.count)
        {
            let dato = self.datosDeUsuarios[i][2]
            if dato.contains(idMinor[1])
            {
                return i
            }
        }
        return 0
    }
    
    /// Valida si el usuario encontrado ya esta en el evento
    ///
    /// - Parameter elementoNuevo: datos de nuevo usuario a registrar
    /// - Returns: bool 2 si ya esta en el evento 0 si no esta en el evento
    func agregarDatosdeUsuarios (elementoNuevo: [String]) -> Int
    {
        for i in 0..<(datosDeUsuarios.count)
        {
            let dato2 = datosDeUsuarios[i][0]
            if dato2.contains(elementoNuevo[0])
            {
                return 2
            }
        }
        return 0
    }
    
    /// Obten la fecha en formato dd-MMM-yyyy HH:mm:ss
    ///
    /// - Returns: fecha como cadena
    func fechaEvento () -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        let myStringafd = formatter.string(from: yourDate!)
        
        return myStringafd
    }
    
    /// Registra usuarios en tu evento, si no tienes creado uno, la funcion lo indicara
    ///
    /// - Parameter id_usuario: id unico para cada usuario
    func agregarUsuariosEvento (id_usuario: String)
    {
        let id_evento = Auth.auth().currentUser?.uid ?? ""
        refDB.child("eventos").observeSingleEvent(of: .value) { (datasnap) in
            if datasnap.hasChild("\(id_evento)_\(self.tipo_usuario)")
            {
                self.refDB.child("eventos/\(id_evento)_\(self.tipo_usuario)/asistentes").observeSingleEvent(of: .value, with: { (datasnap) in
                    if datasnap.childrenCount < 30
                    {
                        let nuevaAsistente = self.refDB.child("eventos/\(id_evento)_\(self.tipo_usuario)/asistentes").childByAutoId()
                        let idnuevaAsistente = nuevaAsistente.key
                        
                        self.refDB.child("eventos/\(id_evento)_\(self.tipo_usuario)/asistentes/\(idnuevaAsistente)/id_usuario").setValue(id_usuario)
                        self.refDB.child("eventos/\(id_evento)_\(self.tipo_usuario)/asistentes/\(idnuevaAsistente)/fecha_registro").setValue(self.fechaEvento())
                    }
                    else
                    {
                        let alertEvento = UIAlertController(title: "Limite de Registros", message: "Lo sentimos. Haz alcanzado el limite de Registros. Pronto planes de pago", preferredStyle: UIAlertControllerStyle.alert)
                        //let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertEvento.addAction(entendido)
                        self.present(alertEvento, animated: true, completion: nil)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }

            }
            else
            {
                let alertEvento = UIAlertController(title: "No hay evento", message: "Te sugerimos primero crear un evento, antes de registrar personas.", preferredStyle: UIAlertControllerStyle.alert)
                let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertEvento.addAction(entendido)
                self.present(alertEvento, animated: true, completion: nil)
            }
        }
    }
}
