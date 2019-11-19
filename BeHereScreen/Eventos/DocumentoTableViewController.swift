//
//  DocumentoViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 07/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DocumentoTableViewController: UITableViewController {

    
    var refDB: DatabaseReference!
    var tipo_usuario: Int = 0
    var idEvento: String = ""
    var mostrarDocumentos = [[String]] ()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Documentos"
        //self.navigationItem.rightBarButtonItem = nil
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refDB = Database.database().reference()
        self.refreshControl?.addTarget(self, action: #selector(recargar), for: UIControlEvents.valueChanged)
        self.tipo_usuario = UserDefaults.standard.integer(forKey: "tipousuario")
        if tipo_usuario == 1
        {
            navigationItem.rightBarButtonItem = nil
        }
        buscarDocumentos()
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
        return mostrarDocumentos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaDocumento", for: indexPath)
        cell.textLabel?.text = mostrarDocumentos[indexPath.item][0]
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
            self.eliminarDocumento(id_documento: mostrarDocumentos[indexPath.item][2])
            mostrarDocumentos.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Eliminar"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Determine what the segue destination is
        if let cell = sender as? UITableViewCell
        {
            let i = tableView.indexPath(for: cell)!.row
            if segue.identifier == "segueDocumento"
            {
                let vc = segue.destination as! VerDocumentoViewController
                vc.titulo_documento = self.mostrarDocumentos[i][0]
                vc.url_documento = self.mostrarDocumentos[i][1]
                
            }
        }
    }

    @objc func recargar()
    {
        print("Recargando DATA")
        self.mostrarDocumentos.removeAll()
        self.buscarDocumentos()
        //self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func buscarDocumentos()
    {
        self.mostrarDocumentos.removeAll()
        let buscarDoc = refDB.child("documento/"+idEvento)
        buscarDoc.observe(.value, with: { (snapshot) in
            if let dicDocumento = snapshot.value as? NSDictionary
            {
                for (key,_) in dicDocumento
                {
                    let llave = key as! String
                    let dicDocumentos2 = dicDocumento[key] as! NSDictionary
                    let tituloDocumento = dicDocumentos2["titulo_documento"] as? String ?? ""
                    let indicaURL = dicDocumentos2["url_documento"] as? String ?? ""
                    //self.mostrarDocumentos.removeAll()
                    if tituloDocumento != "" && indicaURL != ""
                    {
                        if self.duplicados(id_actividad: llave) == false
                        {
                            self.mostrarDocumentos.append([tituloDocumento,indicaURL,llave])
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
        for a in mostrarDocumentos
        {
            if id_actividad == a[2]
            {
                return true
            }
        }
        return false
    }
    
    func eliminarDocumento(id_documento: String) {
        
        let ref = self.refDB.child("documento/\(idEvento)/\(id_documento)")
        ref.removeValue { error, _ in
            print(error as Any)
        }
    }
    
    @IBAction func nuevoDocumento(_ sender: Any)
    {
        let nuevoDocumento = self.refDB.child("documento/\(idEvento)").childByAutoId()
        let idnuevoDocumento = nuevoDocumento.key
        
        let alertNuevoDocumento = UIAlertController(title: "Nuevo Documento", message: "Escribe el titulo de tu Documento", preferredStyle: UIAlertControllerStyle.alert)
        let anadir = UIAlertAction(title: "Nuevo", style: .default) { (alertAction) in
            let textField = alertNuevoDocumento.textFields![0] as UITextField
            let textField2 = alertNuevoDocumento.textFields![1] as UITextField
            
            self.refDB.child("documento/\(self.idEvento)/\(idnuevoDocumento)/titulo_documento").setValue(textField.text)
            self.refDB.child("documento/\(self.idEvento)/\(idnuevoDocumento)/url_documento").setValue(textField2.text)
            
            //self.tableView.reloadData()
            
        }
        alertNuevoDocumento.addTextField { (textField) in
            textField.placeholder = "Titulo de Documento"
        }
        alertNuevoDocumento.addTextField { (textField) in
            textField.placeholder = "URL de Documento"
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertNuevoDocumento.addAction(anadir)
        alertNuevoDocumento.addAction(cancelar)
        self.present(alertNuevoDocumento, animated: true, completion: nil)
    }
    
    

}
