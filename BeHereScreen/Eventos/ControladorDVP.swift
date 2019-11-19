//
//  DocumentoViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 01/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit

class  ControladorDVP: UITableViewController {

    var tipo_usuario: Int = 1
    var idEvento: String = ""
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = ""
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("Estas en contralador DVP el id es: "+idEvento)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaControlador", for: indexPath)
        if indexPath.section == 0
        {
            cell.textLabel?.text = "Programa"
        }
        else if indexPath.section == 1
        {
            cell.textLabel?.text = "Archivos"
        }
        else
        {
            cell.textLabel?.text = "Videos"
        }
        return cell
    }
 
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "Programa"
        }
        else if section == 1
        {
            return "Archivos"
        }
        else
        {
            return "Videos"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "programaEvento") as! programaEvento
            vc.idEvento = self.idEvento
            //self.present(vc!, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.section == 1
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vistaDocumento") as! DocumentoTableViewController
            vc.idEvento = self.idEvento
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "vistaVideo") as! VideoTableViewController
            vc.idEvento = self.idEvento
            //self.present(vc!, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let controller = segue.destination as! programaEvento
        controller.idEvento = self.idEvento as String
    }
}
