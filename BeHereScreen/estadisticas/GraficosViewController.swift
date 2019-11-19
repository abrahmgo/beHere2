//
//  GraficosViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 16/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//  

import UIKit
import Charts
import FirebaseAuth
import FirebaseDatabase

class GraficosViewController: UIViewController {

    @IBOutlet weak var barChartView: PieChartView!
    
    var iosDataEntry = PieChartDataEntry(value: 0)
    var macDataEntry = PieChartDataEntry(value: 0)
    var idUsers = [String]()
    var refDB: DatabaseReference!
    var numberOfDownloadsDataEntries = [PieChartDataEntry]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.refDB = Database.database().reference()
        self.view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: generarGrafico(), action: nil)
        barChartView.noDataText = "No hay datos que mostrar"
        generarGrafico()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generarGrafico()
    {
        self.buscarIDs{ (key) in
            //self.idUsers.append(key)
            var hombres: Int = 0
            var mujeres: Int = 0
            dump(self.idUsers)
            for a in self.idUsers
            {
                self.buscarGenero(id_user: a, completion: { (genero) in
                    if genero == "male" || genero == "Masculino"
                    {
                        hombres = hombres + 1
                        print("\(hombres)")
                    }
                    else
                    {
                        mujeres = mujeres + 1
                        print("\(mujeres)")
                    }
                    self.barChartView.chartDescription?.text = ""
                    
                    self.iosDataEntry.value = Double(hombres)
                    self.iosDataEntry.label = "Hombres"
                    
                    self.macDataEntry.value = Double(mujeres)
                    self.macDataEntry.label = "Mujeres"
                    
                    self.numberOfDownloadsDataEntries = [self.iosDataEntry, self.macDataEntry]
                    
                    self.updateChartData()
                })
            }
        }
        
    }
    
    func updateChartData()
    {
        
        let chartDataSet = PieChartDataSet(values: numberOfDownloadsDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        let hombresColor = UIColor(hex: "0CE8A7")
        let mujeresColor = UIColor(hex: "E294FF")
        
        let colors = [hombresColor,mujeresColor]
        chartDataSet.colors = colors
        
        barChartView.data = chartData
        
        
    }
    
    func buscarGenero(id_user: String, completion: @escaping (String) -> ())
    {
        refDB.child("users").child(id_user).observeSingleEvent(of: .value, with:
            { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let genero = value?["Genero"] as? String ?? ""
                completion(genero)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func buscarIDs(completion: @escaping (Int) -> ())
    {
        let userID = Auth.auth().currentUser?.uid
        
        self.refDB.child("eventos").child(userID!+"_0/asistentes").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary
            {
                for (key,_) in value
                {
                    let dicID = value[key] as! NSDictionary
                    let id_user = dicID["id_usuario"] as? String ?? ""
                    let a = self.agregar(key_user: id_user)
                    if a == 0
                    {
                        self.idUsers.append(id_user)
                    }
                    completion(value.count)
                }
            }
        }
    }
    
    func agregar(key_user: String) -> Int
    {
        for i in 0..<(self.idUsers.count)
        {
            let keyUser = self.idUsers[i]
            if keyUser.contains(key_user)
            {
                return 1
            }
        }
        return 0
    }
}
