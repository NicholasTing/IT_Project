//
//  UsersViewController.swift
//  SWEDEN_iCare
//
//  Created by Dimosthenis Goulas on 25/8/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFirstName: UILabel!
    @IBOutlet weak var userLastName: UILabel!
    @IBOutlet weak var userDOB: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    
<<<<<<< HEAD
//    //Sign out the user when the 'Sign out' button is pressed
//    @IBAction func signOutButton(_ sender: Any) {
//        try! Auth.auth().signOut()
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
//            self.present(vc, animated: false, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* The user Firebase reference */
        let databaseReference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        
        // retrieve a snapshot of your current database
        databaseReference.observeSingleEvent(of: .value) { (snapshot) in

            // loop through each user and their corresponding properties
            if let properties = snapshot.value as? [String: AnyObject] {
                
                self.userImage.downloadImage(from: properties["pathToImage"] as? String)
                self.userFirstName.text = properties["firstName"] as? String
                self.userLastName.text = properties["lastName"] as? String
                self.userDOB.text = properties["dob"] as? String
                self.userEmail.text = properties["address"] as? String
            }
        }
=======
    let list = ["Milk", "Honey", "Bread", "Tacos", "Tomatoes"]
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (list.count)
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row]
        
        return (cell)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
>>>>>>> 53c602af495073b876629432b7ce32c1d13cd237
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

//Retrieves the image from an image path
extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        
        let url = URLRequest(url: URL(string: imgURL)!)
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
