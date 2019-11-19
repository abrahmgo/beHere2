//
//  MisEventos.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 31/01/18.
//  Copyright © 2018 beHere. All rights reserved.
//  AQUI DEBE IR PUBLCIDAD

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds

class MisEventos: UITableViewController, GADBannerViewDelegate{
    @IBOutlet weak var botonAjustes: UIBarButtonItem!
    @IBOutlet weak var botonNuevoEvento: UIBarButtonItem!
    
    var titulosEventos = [String]()
    var idEvento = [String]()
    var refDB: DatabaseReference!
    var tipo_usuario = 1
    var userID: String = ""
    var eventoID: String = ""
    var adBannerView: GADBannerView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Mis eventos"
        refDB = Database.database().reference()
        userID = Auth.auth().currentUser?.uid ?? ""
        self.tipo_usuario = UserDefaults.standard.integer(forKey: "tipousuario")
        self.refreshControl?.addTarget(self, action: #selector(recargar), for: UIControlEvents.valueChanged)
        initBanner()
//        self.tipoUsuario(tipo_user: tipo_usuario) { (tipeUser) in
//            self.tipo_usuario = tipeUser
        if self.tipo_usuario == 1
        {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
            self.buscarEventosUsuarios(completion: { (keyevento) in
                self.idEvento.append(keyevento)
                self.verDatosDeEvento(idEvento: keyevento)
            })
        }
        else
        {
            self.buscarEventos { (keyevento) in
                self.refDB.child("eventos").child(keyevento).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    self.idEvento.append(keyevento)
                    self.titulosEventos.removeAll()
                    let value = snapshot.value as? NSDictionary
                    let titulo_evento = value?["titulo_evento"] as? String ?? ""
                    
                    self.titulosEventos.append(titulo_evento)
                    self.tableView.reloadData()
                    
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titulosEventos.count
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return adBannerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return adBannerView!.frame.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        cell.textLabel?.text = titulosEventos[indexPath.item]
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if self.tipo_usuario == 1
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            
            if titulosEventos.isEmpty == false
            {
                self.eliminarEvento(id_evento: idEvento[indexPath.item])
                titulosEventos.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Eliminar"
    }
    
    
    @IBAction func nuevoEvento(_ sender: Any)
    {
        //nuevo evento
        if titulosEventos.count != 0
        {
            let alertEvento = UIAlertController(title: "Ya hay evento", message: "Si creas uno nuevo, eliminaras los datos de tu evento antiguo. Pronto planes de pago", preferredStyle: UIAlertControllerStyle.alert)
            //let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
            let entendido = UIAlertAction(title: "Ok", style: .default) { (alertAction2) in
                
                self.nuevoEventoAlerAction()
            }
            let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alertEvento.addAction(entendido)
            alertEvento.addAction(cancelar)
            self.present(alertEvento, animated: true, completion: nil)
        }
        else
        {
            nuevoEventoAlerAction()
        }
    }
    
    func nuevoEventoAlerAction()
    {
        let alertNuevoEvento = UIAlertController(title: "Nuevo Evento", message: "Escribe el titulo de tu Evento", preferredStyle: UIAlertControllerStyle.alert)
        let anadir = UIAlertAction(title: "Nuevo", style: .default) { (alertAction) in
            let textField = alertNuevoEvento.textFields![0] as UITextField
            
            if self.idEvento.isEmpty == false
            {
                print("borrare tu evento anterior \(self.idEvento[0])")
                self.eliminarEvento(id_evento: self.idEvento[0])
            }
            self.refDB.child("eventos/\(Auth.auth().currentUser!.uid+"_\(self.tipo_usuario)")/id_creador").setValue(Auth.auth().currentUser!.uid)
            self.refDB.child("eventos/\(Auth.auth().currentUser!.uid+"_\(self.tipo_usuario)")/titulo_evento").setValue(textField.text)
            self.refDB.child("eventos/\(Auth.auth().currentUser!.uid+"_\(self.tipo_usuario)")/fecha_evento").setValue(self.fechaEvento())
            
            self.eventoID = "\(Auth.auth().currentUser!.uid)_\(self.tipo_usuario)"
            self.titulosEventos.append(textField.text!)
            //self.tableView.reloadData()
            
        }
        alertNuevoEvento.addTextField { (textField) in
            textField.placeholder = "Titulo de Evento"
            
        }
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertNuevoEvento.addAction(anadir)
        alertNuevoEvento.addAction(cancelar)
        self.present(alertNuevoEvento, animated: true) {
            self.titulosEventos.removeAll()
        }
    }
    
    
    @objc func recargar()
    {
        print("Recargando DATA")
        self.titulosEventos.removeAll()
        self.idEvento.removeAll()
        //self.tableView.reloadData()
        if self.tipo_usuario == 1
        {
            self.buscarEventosUsuarios(completion: { (keyevento) in
                self.idEvento.append(keyevento)
                self.verDatosDeEvento(idEvento: keyevento)
            })
        }
        else
        {
            self.buscarEventos { (keyevento) in
                self.refDB.child("eventos").child(keyevento).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    self.idEvento.append(keyevento)
                    self.titulosEventos.removeAll()
                    let value = snapshot.value as? NSDictionary
                    let titulo_evento = value?["titulo_evento"] as? String ?? ""
                    
                    self.titulosEventos.append(titulo_evento)
                    self.tableView.reloadData()
                    
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
        self.refreshControl?.endRefreshing()
    }
    
    func eliminarEvento(id_evento: String)
    {
        let ref = self.refDB.child("eventos/\(id_evento)")
        let ref1 = self.refDB.child("documento/\(id_evento)")
        let ref2 = self.refDB.child("programa/\(id_evento)")
        let ref3 = self.refDB.child("video/\(id_evento)")
        ref.removeValue { error, _ in
            print(error as Any)
        }
        ref1.removeValue { error, _ in
            print(error as Any)
        }
        ref2.removeValue { error, _ in
            print(error as Any)
        }
        ref3.removeValue { error, _ in
            print(error as Any)
        }
    }
    
    func buscarEventos(completion: @escaping (String) -> ())
    {
        let buscarEvento = refDB.child("eventos").queryOrdered(byChild: "id_creador").queryEqual(toValue: userID)
        buscarEvento.observe(.value, with: { (snapshot) in
            for snap in snapshot.children
            {
                let keyUser = (snap as! DataSnapshot).key
                completion(keyUser)
            }
        }) { (error) in
            print("hubo algun error \(error.localizedDescription)")
        }
    }
    func buscarEventosUsuarios(completion: @escaping (String) -> ())
    {
        //let buscarEvento = refDB.child("eventos").queryOrdered(byChild: "asistentes/id_usuario").queryEqual(toValue: userID)
        let buscarEvento = refDB.child("eventos")
        
        buscarEvento.observe(.value, with: { (snapshot) in
            if let dicEventos = snapshot.value as? NSDictionary
            {
                for (key,_) in dicEventos
                {
                    let llave = key as! String
                    let dicAsistentes2 = dicEventos[key] as! NSDictionary
                    for(key2,_) in dicAsistentes2
                    {
                        if let dicAsistentes3 = dicAsistentes2[key2] as? NSDictionary
                        {
                            for(key3,_) in dicAsistentes3
                            {
                                let dicAsistentes4 = dicAsistentes3[key3] as! NSDictionary
                                let id_user = dicAsistentes4["id_usuario"] as? String ?? ""
                                print(llave)
                                if id_user == self.userID
                                {
                                    completion(llave)
                                }
                                
                            }
//                            let id_user = dicAsistentes3["id_usuario"] as? String ?? ""
//                            print(id_user+"PUTO ID")
//                            if id_user == self.userID
//                            {
//                                completion(llave)
//                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
//
//        buscarEvento.observe(.value, with: { (snapshot) in
//            for snap in snapshot.children
//            {
//                let keyUser = (snap as! DataSnapshot).key
//                //let tituloEvento = keyUser["titulo_evento"] as? String ?? ""
//                completion(keyUser)
//            }
//        }) { (error) in
//            print("hubo algun error \(error.localizedDescription)")
//        }
    }
    
    func verDatosDeEvento(idEvento: String)
    {
        refDB.child("eventos").child(idEvento).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let nombreEvento = value?["titulo_evento"] as? String ?? ""
            self.titulosEventos.append(nombreEvento)
            self.tableView.reloadData()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    func tipoUsuario(tipo_user:Int , completion: @escaping (Int) -> ())
//    {
//        self.refDB.child("users").child(userID).observe(.value) { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let tipo = value?["tipo_usuario"] as? Int ?? 1
//            completion(tipo)
//        }
//    }
    
    func initBanner()
    {
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView?.adUnitID = "ca-app-pub-2812877004932156/1566948601"
        adBannerView?.delegate = self
        adBannerView?.rootViewController = self
        adBannerView?.load(GADRequest())
    }
    
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Determine what the segue destination is
        if let cell = sender as? UITableViewCell
        {
            let i = tableView.indexPath(for: cell)!.row
            if segue.identifier == "segueDVP"
            {
                let vc = segue.destination as! ControladorDVP
                vc.idEvento = self.idEvento[i] as String
            }
        }
    }
    
    //Google Admob
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView.tableHeaderView?.frame = bannerView.frame
        tableView.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
}
