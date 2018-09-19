//
//  HomeViewController.swift
//  SWEDEN_iCare
//
//  Created by Nicholas on 5/9/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet var Help: UIButton!
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func helpCall(_ sender: UIButton) {
        //        [[UIApplication, sharedApplication] openURL:[NSURL URLWithString:@"tel://1115550123"]];
        //        let url: NSURL = NSURL(string: "tel://0478821628")!
        //        UIApplication.shared.open(url as URL)
        //
        let numString = "0478821628"
        let url = URL(string:"telprompt://\(numString)")
        UIApplication.shared.open(url!)
    }

}
