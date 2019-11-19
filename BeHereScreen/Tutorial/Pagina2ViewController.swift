//
//  Pagina2ViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 28/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit

class Pagina2ViewController: UIViewController {

    
    @IBOutlet weak var eventosGif: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventosGif.loadGif(name: "pulldown")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
