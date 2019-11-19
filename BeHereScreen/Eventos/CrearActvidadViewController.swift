//
//  CrearActvidadViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 11/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CrearActvidadViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var indicaActividad: UIPickerView!
    @IBOutlet weak var tituloActividad: UITextField!
    @IBOutlet weak var lugarActividad: UITextField!
    @IBOutlet weak var horaActividad: UIDatePicker!
    @IBOutlet weak var anadirActividad: UIButton!
    //@IBOutlet weak var scrollView: UIScrollView!
    
    let programa = ["Actividad","Exposicion","Stand"]
    var refDB: DatabaseReference!
    var idEvento: String = ""
    var tipoActividad: String = ""
    var myStringafd: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Actividad"
        anadirActividad.layer.cornerRadius = 22
        refDB = Database.database().reference()
        indicaActividad.delegate = self
        indicaActividad.dataSource = self
        //scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+150)
        
        let loc = Locale(identifier: "es_MX")
        self.horaActividad.locale = loc
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func anadirActividad(_ sender: Any)
    {
        let row = indicaActividad.selectedRow(inComponent: 0)
        tipoActividad = programa[row] as String
        
        if (tituloActividad.text?.isEmpty)!
        {
            let alertController = UIAlertController(title: "Ups", message: "Haz olvidado poner un titulo", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let nuevaActividad = self.refDB.child("programa/\(idEvento)").childByAutoId()
            let idnuevaActividad = nuevaActividad.key
            self.refDB.child("programa/\(idEvento)/\(idnuevaActividad)/indica_actividad").setValue(tipoActividad)
            self.refDB.child("programa/\(idEvento)/\(idnuevaActividad)/titulo_actividad").setValue(tituloActividad.text)
            self.refDB.child("programa/\(idEvento)/\(idnuevaActividad)/lugar_actividad").setValue(lugarActividad.text)
            self.refDB.child("programa/\(idEvento)/\(idnuevaActividad)/fecha_actividad").setValue(myStringafd)
            print("guarda")
            
            let alertController = UIAlertController(title: "Listo", message: "Se añadio correctamente la actividad", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Ok", style: .default)
            { (alert) in
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return programa.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return programa[row]
    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
//    {
//        let row = indicaActividad.selectedRow(inComponent: 0)
//        tipoActividad = programa[row] as String
//    }
    
    @IBAction func fechaPActividad(_ sender: Any)
    {
        horaActividad.minimumDate = NSDate() as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        myStringafd = dateFormatter.string(from: horaActividad.date)
        //self.view.endEditing(true)
    }
    
//    func horaActual()
//    {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy HH:mm"
//
//        let myString = formatter.string(from: Date())
//        let yourDate = formatter.date(from: myString)
//        formatter.dateFormat = "HH:mm"
//        //myStringafd = formatter.string(from: yourDate!)
//        self.horaActividad.date = yourDate!
//        self.horaActividad.minimumDate = yourDate!
//    }
}
