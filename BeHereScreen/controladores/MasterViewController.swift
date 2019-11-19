//
//  MasterViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 18/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth

class MasterViewController: UIViewController {

    
    
    @IBOutlet weak var ButtonIniciarSesion: UIButton!
    @IBOutlet weak var ButtonRegistro: UIButton!
    
    var fondoImagen = UIImageView ()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = ""
        
//        Auth.auth().addStateDidChangeListener { (auth, user) in
//            if user != nil
//            {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
//                self.present(vc!, animated: true, completion: nil)
//            }
//            else
//            {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
//                self.present(vc!, animated: true, completion: nil)
//            }
            
//        }

        
        
        ButtonIniciarSesion.layer.cornerRadius = 22
        ButtonRegistro.layer.cornerRadius = 22
        
        
        ponerFondo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func ponerFondo()
    {
        self.fondoImagen.loadGif(name: "4")
        self.fondoImagen.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.fondoImagen.contentMode = UIViewContentMode.scaleAspectFill
        self.fondoImagen.alpha = 0.5
        self.fondoImagen.layer.zPosition = -1.0
        self.view.addSubview(self.fondoImagen)

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.ponerFondo()
        
//        Auth.auth().addStateDidChangeListener
//            { auth, user in
//                if user != nil
//                {
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
//                    self.present(vc!, animated: true, completion: nil)
//                }
//        }
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.view.willRemoveSubview(self.fondoImagen)
        self.view.layer.removeAllAnimations()
        self.fondoImagen.removeFromSuperview()
    }
}
