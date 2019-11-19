//
//  CargadonVistaViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 22/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth

class CargadonVistaViewController: UIViewController {

    @IBOutlet weak var fondo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
            Auth.auth().addStateDidChangeListener { (auth, user) in
                if user != nil
                {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationMasterController")
                    self.present(vc!, animated: true, completion: nil)
                }
                else
                {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MasterInicioSesion")
                    self.present(vc!, animated: true, completion: nil)
                }
                
            }
        }
        else {
            print("First launch, setting NSUserDefault.")
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            // instantiate neew PageVC via storyboard
            if let pageViewController = storyboard.instantiateViewController(withIdentifier: "TutorialBeHere") as? TutorialViewController {
                self.present(pageViewController, animated: true, completion: nil)
                print("tried")
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fondo.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fondo.isHidden = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
