//
//  VerDocumentoViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 07/04/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import WebKit

class VerDocumentoViewController: UIViewController,WKNavigationDelegate
{

    
    @IBOutlet weak var verDocumento: WKWebView!
    
    var url_documento: String = ""
    var titulo_documento: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = titulo_documento
        print(url_documento)
        // Do any additional setup after loading the view.
        verDocumento.frame = self.view.bounds
        let url = URL(string: "https://"+url_documento)!
        verDocumento.load(URLRequest(url: url))
        verDocumento.allowsBackForwardNavigationGestures = true
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
