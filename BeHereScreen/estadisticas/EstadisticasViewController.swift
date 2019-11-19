//
//  EstadisticasViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 24/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import GoogleMobileAds

class EstadisticasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let nomGrafica = ["Genero"]
    var adBannerView: GADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView?.adUnitID = "ca-app-pub-2812877004932156/1566948601"
        adBannerView?.delegate = self
        adBannerView?.rootViewController = self
        adBannerView?.load(GADRequest())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nomGrafica.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return adBannerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return adBannerView!.frame.height
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Graficas"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celdaGrafica", for: indexPath)
        cell.textLabel?.text = nomGrafica[indexPath.item]
        return cell
    }
    
    // Google Admob
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView.tableHeaderView?.frame = bannerView.frame
        tableView.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    @IBAction func enviarDatos(_ sender: Any)
    {
        let alertEvento = UIAlertController(title: "Enviando Datos", message: "Lo sentimos aún no puedes enviarte los datos. Pronto planes de pago", preferredStyle: UIAlertControllerStyle.alert)
        //let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let entendido = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertEvento.addAction(entendido)
        self.present(alertEvento, animated: true, completion: nil)
    }
    
    
}
