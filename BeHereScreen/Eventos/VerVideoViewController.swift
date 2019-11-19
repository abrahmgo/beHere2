//
//  VideoViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 01/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import WebKit

class VerVideoViewController: ViewController, WKNavigationDelegate
{

    @IBOutlet weak var videoWeb: WKWebView!
    
    var url_video: String = ""
    var titulo_video: String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        videoWeb.navigationDelegate = self
        navigationItem.title = titulo_video
        // Do any additional setup after loading the view.
        videoWeb.frame = self.view.bounds
       
        
        let url = URL(string: "https://"+url_video)!
        videoWeb.load(URLRequest(url: url))
        videoWeb.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
