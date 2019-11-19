//
//  VideoTableViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 07/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class VideoTableViewController: UITableViewController {

    var refDB: DatabaseReference!
    var tipo_usuario: Int = 0
    var idEvento: String = ""
    var mostrarVideos = [[String]] ()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Videos"

        refDB = Database.database().reference()
        self.refreshControl?.addTarget(self, action: #selector(recargar), for: UIControlEvents.valueChanged)
        self.tipo_usuario = UserDefaults.standard.integer(forKey: "tipousuario")
        if tipo_usuario == 1
        {
            navigationItem.rightBarButtonItem = nil
        }
        buscarVideos()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return mostrarVideos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaVideo", for: indexPath)
        cell.textLabel?.text = mostrarVideos[indexPath.item][0]
        return cell
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
            self.eliminarVideo(id_video: mostrarVideos[indexPath.item][2])
            mostrarVideos.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Eliminar"
    }
    
    @IBAction func nuevoVideo(_ sender: Any)
    {
        let nuevoVideo = self.refDB.child("video/\(idEvento)").childByAutoId()
        let idnuevoDocumento = nuevoVideo.key
        
        let alertNuevoVideo = UIAlertController(title: "Nuevo Video", message: "Escribe el titulo de tu Video", preferredStyle: UIAlertControllerStyle.alert)
        let anadir = UIAlertAction(title: "Nuevo", style: .default) { (alertAction) in
            let textField = alertNuevoVideo.textFields![0] as UITextField
            let textField2 = alertNuevoVideo.textFields![1] as UITextField
            
            self.refDB.child("video/\(self.idEvento)/\(idnuevoDocumento)/titulo_video").setValue(textField.text)
            self.refDB.child("video/\(self.idEvento)/\(idnuevoDocumento)/url_video").setValue(textField2.text)
            
            //self.tableView.reloadData()
            
        }
        alertNuevoVideo.addTextField { (textField) in
            textField.placeholder = "Titulo de Video"
        }
        alertNuevoVideo.addTextField { (textField) in
            textField.placeholder = "URL de Video"
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertNuevoVideo.addAction(anadir)
        alertNuevoVideo.addAction(cancelar)
        self.present(alertNuevoVideo, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Determine what the segue destination is
        if let cell = sender as? UITableViewCell
        {
            let i = tableView.indexPath(for: cell)!.row
            if segue.identifier == "segueVideo"
            {
                let vc = segue.destination as! VerVideoViewController
                vc.titulo_video = self.mostrarVideos[i][0]
                vc.url_video = self.mostrarVideos[i][1]
                
            }
        }
    }
    
    
    @objc func recargar()
    {
        print("Recargando DATA")
        self.mostrarVideos.removeAll()
        self.buscarVideos()
        //self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func buscarVideos()
    {
        self.mostrarVideos.removeAll()
        let buscarVid = refDB.child("video/"+idEvento)
        buscarVid.observe(.value, with: { (snapshot) in
            if let dicVideos = snapshot.value as? NSDictionary
            {
                for (key,_) in dicVideos
                {
                    let llave = key as! String
                    let dicVideos2 = dicVideos[key] as! NSDictionary
                    let tituloVideo = dicVideos2["titulo_video"] as? String ?? ""
                    let indicaURL = dicVideos2["url_video"] as? String ?? ""
                    //self.mostrarDocumentos.removeAll()
                    if tituloVideo != "" && indicaURL != ""
                    {
                        if self.duplicados(id_actividad: llave) == false
                        {
                            self.mostrarVideos.append([tituloVideo,indicaURL,llave])
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
        for a in mostrarVideos
        {
            if id_actividad == a[2]
            {
                return true
            }
        }
        return false
    }
    
    func eliminarVideo(id_video: String)
    {
        
        let ref = self.refDB.child("video/\(idEvento)/\(id_video)")
        ref.removeValue { error, _ in
            print(error as Any)
        }
    }
}
