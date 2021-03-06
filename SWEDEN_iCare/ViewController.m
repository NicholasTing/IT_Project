//
//  ViewController.m
//  SWEDEN_iCare
//
//  Created by Jing Kun Ting on 1/10/18.
//  Copyright © 2018 Nicholas. All rights reserved.
//

#import "ViewController.h"
@import GruveoSDK;

@interface ViewController () <GruveoCallManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.activityIndicator stopAnimating];
    [GruveoCallManager setDelegate:self];
    
    // Add gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
  
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
    
    
}

#pragma mark - Private

// Function to make a call if the text field is not empty
- (void)makeCall {
    if (self.textField.text.length == 0) {
        return;
    }
    self.button.hidden = YES;
    [self.activityIndicator startAnimating];
    
    [self.textField resignFirstResponder];

    [GruveoCallManager callCode:self.textField.text videoCall:YES textChat:YES onViewController:self callCreationCompletion:^(CallInitError creationError) {
        self.button.hidden = NO;
        [self.activityIndicator stopAnimating];
        if (creationError != CallInitErrorNone) {
            [self.textField becomeFirstResponder];
            // show error here
            NSLog(@"callCreationCompletion error: %li", creationError);
        }
    }];
}

- (IBAction)callAction:(id)sender {
    [self makeCall];
}

#pragma mark - GruveoCallManagerDelegate

// Function to request the server to sign the API token.
- (void)requestToSignApiAuthToken:(NSString *)token {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api-demo.gruveo.com/signer"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[token dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (!self.session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    }
    
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([data isKindOfClass:[NSData class]]) {
            NSString *signedToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [GruveoCallManager authorize:signedToken];
        } else {
            [GruveoCallManager authorize:nil];
        }
    }] resume];
}

- (void)callEstablished {
    NSLog(@"callEstablished");
}

- (void)callEnd:(GruveoCallEndReason)reason {
    NSLog(@"callEnd with reason: %li", reason);
}

- (void)recordingStateChanged {
    NSLog(@"recordingStateChanged");
}

#pragma mark - UITextFieldDelegate

// To hide the text field when not in use.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self makeCall];
    
    return NO;
}


@end
