//
//  ViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 31/01/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController
{
   
   
    @IBOutlet weak var vistaGrafica: BarChartView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //vistaGrafica.noDataText = "No hay datos aún"
//        tablaUsuarios.delegate = self
//        tablaUsuarios.dataSource = self
        //vistaGrafica.noDataText = "No hay nada que mostrar"
        //self.title = "Estadisticas"
        //navigationItem.prompt = "Estadisticas"
       //navigationItem.title = "Estadisticas"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return 1
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "usuarios", for: indexPath)
//        cell.textLabel?.text = "a1865617@correo.uia.mx"
//        return cell
//    }

//    override func viewWillAppear(_ animated: Bool) {
//        tablaUsuarios.reloadData()
//    }
    

}

