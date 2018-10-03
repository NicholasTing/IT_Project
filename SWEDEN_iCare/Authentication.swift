//
//  Authentication.swift
//  SWEDEN_iCare
//
//  Created by Nicholas on 3/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation

class Authentication {
    
    init(){
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}
