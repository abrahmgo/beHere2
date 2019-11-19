//
//  FinalTutorialViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 28/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit

class FinalTutorialViewController: UIViewController {

    
    @IBOutlet weak var entendidoTutorial: UIButton!
    @IBOutlet weak var imagenGif: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entendidoTutorial.layer.cornerRadius = 22
        self.imagenGif.loadGif(name: "estadisticas")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func entendidoTutorialIncia(_ sender: Any)
    {
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
    

}
