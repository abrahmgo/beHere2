//
//  Pagina3ViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 28/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit

class Pagina3ViewController: UIViewController {

    @IBOutlet weak var eventoNuevo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventoNuevo.loadGif(name: "evento")
        //self.eventosGif.loadGif(name: "4")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
