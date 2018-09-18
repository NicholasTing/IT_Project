//
//  UsersViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 25/8/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController {
    
    let ref = Database.database().reference(withPath: "users")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
