//
//  main.m
//  SWEDEN_iCare
//
//  Created by Jing Kun Ting on 1/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@import Firebase;

int main(int argc, char * argv[]) {
    
    [FIRApp configure];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
    
    
}
