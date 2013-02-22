//
//  FirstViewController.h
//  MGCryptorTutorial
//
//  Created by Gabriele Merlonghi on 16/01/13.
//  Copyright (c) 2013 Gabriele Merlonghi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstViewController : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UITextField *textToCrypt;          //text to be encrypted
    IBOutlet UITextField *textToDecrypt;        //text to be decrypted
    IBOutlet UITextView *textCrypted;           //container of encrypted data converted in text format
    IBOutlet UITextView *textDecrypted;         //container of the decrypted text that shoud be equal to the textToCrypt
    IBOutlet UITextField *password2crypt;       //text password with encrypt
    IBOutlet UITextField *password2decrypt;     //text password with decrypt
    IBOutlet UILabel *stateLabel;               //state of the conversion
    IBOutlet UIButton *encryptButton;           //button to trigger the encryption
    IBOutlet UIButton *decryptButton;           //button to trigger the decryption
    IBOutlet UIButton *resetButton;             //button to reset all field to the original contents

    NSString *cryptedString;                    //string to be transport from the source to destination, that contain the encrypted text

    
}

@end
