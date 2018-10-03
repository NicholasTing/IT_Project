//
//  AddReminderViewController.swift
//  SWEDEN_iCare
//
//  Created by Nicholas on 3/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import UIKit

class AddReminderViewController: UIViewController, UITextFieldDelegate {
    
    var reminder : Reminder!

    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var reminderTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.reminderTextField.delegate = self
        
        // set current date/time as minimum date
        timePicker.minimumDate = NSDate() as Date
        timePicker.locale = NSLocale.current
    }
    
    
    func checkName(){
        // Disable save button if text is empty
        let text = reminderTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func checkDate(){
        // Disable date if date has passed
        if NSDate().earlierDate(timePicker.date) == timePicker.date {
            saveButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkName()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        checkDate()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        
            let name = reminderTextField.text
            var time = timePicker.date
        
        let timeInterval = floor(time.timeIntervalSinceReferenceDate/60) * 60
        
        time = NSDate(timeIntervalSinceReferenceDate: timeInterval) as Date
        
            // build notification
            
            let notification = UILocalNotification()
            notification.alertTitle = "Reminder"
            notification.alertBody = "Don't forget to  \(name)"
            notification.soundName = UILocalNotificationDefaultSoundName
            
            UIApplication.shared.scheduleLocalNotification(notification)
        
        reminder = Reminder(name:name!, time:time as NSDate, notification:notification)
    }
 
    
    

}
