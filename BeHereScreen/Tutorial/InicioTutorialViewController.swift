//
//  InicioTutorialViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 28/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit

class InicioTutorialViewController: UIViewController {

    @IBOutlet weak var omitirTutorial: UIButton!
    @IBOutlet weak var behereGif: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        omitirTutorial.layer.cornerRadius = 16
        self.behereGif.loadGif(name: "behere")
        omitirTutorial.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.omitirTutorial.isHidden = false
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func omitirTurotialIncio(_ sender: Any)
    {
        
        let alertEvento = UIAlertController(title: "Omitir", message: "¿Quieres omitir el tutorial que te ayudará a usar Be Here?", preferredStyle: UIAlertControllerStyle.alert)
        //let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let entendido = UIAlertAction(title: "Ok", style: .default) { (alertAction2) in
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            if launchedBefore
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
                self.present(vc!, animated: true, completion: nil)
            }
            else
            {
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
                self.present(vc!, animated: true, completion: nil)
            }
        }
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alertEvento.addAction(entendido)
        alertEvento.addAction(cancelar)
        self.present(alertEvento, animated: true, completion: nil)
    }
    

}
