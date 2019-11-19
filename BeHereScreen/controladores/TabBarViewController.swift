//
//  TabBarViewController.swift
//  BeHereScreen
//
//  Created by Andres Abraham Bonilla Gòmez on 01/02/18.
//  Copyright © 2018 beHere. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FacebookCore
import FacebookLogin

class TabBarViewController: UITabBarController
{

    var tipo_usuario: Int! = 1
    var usuario_minor: Int! = 1
    var refDB: DatabaseReference!
    let accessToken = AccessToken.current
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.selectedIndex = 0
        refDB = Database.database().reference()
        navigationItem.hidesBackButton = true
        quitarViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Determine what the segue destination is
        if segue.destination is programaEvento
        {
            let vc = segue.destination as? programaEvento
            vc?.tipo_usuario = self.tipo_usuario
        }
        else if segue.destination is MisEventos
        {
            let vc = segue.destination as? MisEventos
            vc?.tipo_usuario = self.tipo_usuario
        }
    }
    
    func tipoUsuario(tipo_user:Int , completion: @escaping (Int) -> ())
    {
        let userID = Auth.auth().currentUser?.uid
        
        self.refDB.child("users").child(userID!).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let tipo = value?["tipo_usuario"] as? Int ?? 1
            completion(tipo)
        }
    }
    
    func minorUsuario(completion: @escaping (Int) -> ())
    {
        let userID = Auth.auth().currentUser?.uid
        self.refDB.child("users").child(userID!).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let minor = value?["minor"] as? Int ?? 1
            completion(minor)
        }
    }
    
    func quitarViews()
    {
        self.minorUsuario { (minorUser) in
            self.usuario_minor = minorUser
            if minorUser == 1
            {
                var minors = [Int]()
                self.refDB.child("users").queryOrdered(byChild: "minor").observeSingleEvent(of: .value, with: { snapshot in
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let minor = snap.childSnapshot(forPath: "minor")
                        minors.append(minor.value as! Int)
                    }
                    let userID = Auth.auth().currentUser?.uid
                    let ref = self.refDB.child("users").child(userID!)
                    let minornew = minors.last! + 1
                    let nuevoMinor = ["minor": minornew]
                    ref.updateChildValues(nuevoMinor, withCompletionBlock: { (error, value) in
                        if error != nil
                        {
                            print("erro no se actualizo el minor")
                        }
                        print("se actualizo el minor")
                    })
                }) { (error) in
                    print(error)
                }
            }
            self.tipoUsuario(tipo_user: self.tipo_usuario) { (tipeUser) in
                self.tipo_usuario = tipeUser
                if self.tipo_usuario! == 1
                {
                    if (self.viewControllers?.count)! >= 3
                    {
                        self.viewControllers?.removeLast()
                        self.viewControllers?.removeLast()
                    }
                }
                else
                {
                    if (self.viewControllers?.count)! >= 4
                    {
                        self.viewControllers?.removeFirst()
                    }
                }
            }
        }
        
    }
}
