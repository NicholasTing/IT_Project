//
//  LoginTest.swift
//  SWEDEN_iCareTests
//
//  Created by Nicholas on 3/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

import Foundation
import XCTest

class LoginTest: XCTestCase {
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func testValidEmail(){
        
        let test = "test@gmail.com";
        XCTAssertTrue(self.isValidEmail(testStr: test));
        
    }
}

