//
//  ResetearPasswordViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 15/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetearPasswordViewController: UIViewController {

    @IBOutlet weak var correoBuscar: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buscarCorreo: UIButton!
    
    
    override func viewDidLoad()
    {
        self.navigationItem.title = "Recuperando cuenta"
        buscarCorreo.layer.cornerRadius = 22
        //scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+150)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cambiarPassword(_ sender: Any)
    {
        if (correoBuscar.text?.isEmpty)!
        {
            let resetFailedAlert = UIAlertController(title: "Ups", message: "Pon un correo válido", preferredStyle: .alert)
            resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(resetFailedAlert, animated: true, completion: nil)
        }
        else
        {
            let correoUsuario = correoBuscar.text
            Auth.auth().sendPasswordReset(withEmail: correoUsuario!) { (error) in
                if error != nil
                {
                    let resetFailedAlert = UIAlertController(title: "Correo No Encontrado", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }
                else
                {
                    let resetEmailSentAlert = UIAlertController(title: "Cambio en proceso", message: "Revisa tu bandeja de no deseado", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                }
            }
        }
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }

}
