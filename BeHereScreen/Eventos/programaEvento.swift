//
//  programaEvento.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 27/03/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class programaEvento: UITableViewController, UNUserNotificationCenterDelegate {
    
    
    
    @IBOutlet weak var botonGuardarAnadir: UIBarButtonItem!
    
    var tipo_usuario: Int = 0
    var bandera: Int = 0
    var idEvento: String = ""
    var refDB: DatabaseReference!
    var mostrarActividades = [[String]] ()
    var notificacionActiviades = [[String]]()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        navigationItem.title = "Programa"
        refDB = Database.database().reference()
        UNUserNotificationCenter.current().delegate = self
        self.mostrarActividades.removeAll()
        self.refreshControl?.addTarget(self, action: #selector(recargar), for: UIControlEvents.valueChanged)
        self.tipo_usuario = UserDefaults.standard.integer(forKey: "tipousuario")
        if tipo_usuario == 1
        {
            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Guardar", style: .plain, target: self, action: #selector(programaEvento.guardar))
        }
        else
        {
            //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(programaEvento.nuevo))
            self.bandera = 1
            
        }
        buscarActividades()
    }

    @objc func recargar()
    {
        print("Recargando DATA")
        self.mostrarActividades.removeAll()
        self.buscarActividades()
        //self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    @objc fileprivate func guardar()
    {
        if notificacionActiviades.count != 0
        {
            for numero in notificacionActiviades
            {
                let nuevaNotificacion = UNMutableNotificationContent()
                nuevaNotificacion.title = numero[0]
                nuevaNotificacion.subtitle = numero[1]
                nuevaNotificacion.body = numero[1]
                nuevaNotificacion.badge = 1
                nuevaNotificacion.categoryIdentifier = "evento"
        
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.locale = NSLocale(localeIdentifier: "es_MX") as Locale?
                let dateH = dateFormatter.date(from: numero[2])!
                let fecha = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateH)
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: fecha, repeats: false)
                let request = UNNotificationRequest(identifier: "eventos", content: nuevaNotificacion, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { (error) in
                    print(error as Any)
                }
            }
            let alertController = UIAlertController(title: "Listo", message: "Te recordaremos tus actividades", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController(title: "No hay actividades", message: "Selecciona una actividad para recordarte", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning()
    {
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
        return mostrarActividades.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaPrograma", for: indexPath)
        cell.textLabel?.text = mostrarActividades[indexPath.item][0]
        cell.detailTextLabel?.text = mostrarActividades[indexPath.item][1]+" "+mostrarActividades[indexPath.item][2]
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if bandera == 0
        {
            if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark
            {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                self.mostrarActividades.remove(at: indexPath.item)
            }
            else
            {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                self.notificacionActiviades.append(mostrarActividades[indexPath.item])
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
            self.eliminarActividad(id_actividad: mostrarActividades[indexPath.item][3])
            mostrarActividades.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {

        if segue.identifier == "segueCrearActividad"
        {
            let vc = segue.destination as! CrearActvidadViewController
            vc.idEvento = self.idEvento as String
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //self.mostrarActividades.removeAll()
    }
    
    func buscarActividades()
    {
        self.mostrarActividades.removeAll()
        let buscarActvidad = refDB.child("programa/"+idEvento)
        buscarActvidad.observe(.value, with: { (snapshot) in
            if let dicActividades = snapshot.value as? NSDictionary
            {
                for (key,_) in dicActividades
                {
                    let llave = key as! String
                    let dicActvidades2 = dicActividades[key] as! NSDictionary
                    let tituloActividad = dicActvidades2["titulo_actividad"] as? String ?? ""
                    let indicaActividad = dicActvidades2["indica_actividad"] as? String ?? ""
                    let lugarActividad = dicActvidades2["lugar_actividad"] as? String ?? ""
                    let fechaActividad = dicActvidades2["fecha_actividad"] as? String ?? ""
                    //self.mostrarActividades.removeAll()
                    if fechaActividad != "" && lugarActividad != "" && indicaActividad != "" && tituloActividad != ""
                    {
                        if self.duplicados(id_actividad: llave) == false
                        {
                            self.mostrarActividades.append([indicaActividad+" "+tituloActividad,lugarActividad,fechaActividad,llave])
                        }
                    }
                }
                self.tableView.reloadData()
               
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func duplicados (id_actividad: String) -> Bool
    {
        for a in mostrarActividades
        {
            if id_actividad == a[3]
            {
                return true
            }
        }
        return false
    }
    func eliminarActividad(id_actividad: String) {
        
        let ref = self.refDB.child("programa/\(idEvento)/\(id_actividad)")
        ref.removeValue { error, _ in
            print(error as Any)
        }
    }
    
    //Delegados de Notificaciones
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}
