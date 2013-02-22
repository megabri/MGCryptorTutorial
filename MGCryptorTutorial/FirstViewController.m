//
//  FirstViewController.m
//  MGCryptorTutorial
//
//  Created by Gabriele Merlonghi on 16/01/13.
//  Copyright (c) 2013 Gabriele Merlonghi. All rights reserved.
//

#import "FirstViewController.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

#define HEX2STRING  1

NSString *const kGoodPassword = @"Passw0rd!";

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self resetButtonAction:nil];
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

/* Action for encrypt the text source */
- (IBAction)encryptButtonAction:(id)sender {
    
    //test if the text to ecrypt is empty
    if (textToCrypt.text == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error:"
                                                        message:@"I have no text to encrypt. Please set text first!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSLog(@"sourceText:%@",textToCrypt.text);
    
    //test if the ecrypt password is empty, otherwise fill with default password
    if (password2crypt.text == nil) password2crypt.text = kGoodPassword;
    
    //convert the NSString in NSData
    NSData *data = [textToCrypt.text dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"sourceData:%@", data);
    NSLog(@"sourcePassword:%@", [password2crypt.text dataUsingEncoding:NSUTF8StringEncoding]);
    
    NSError *error = nil;
    
    //encrypt!
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES128Settings
                                            password:password2crypt.text
                                               error:&error];
    
    NSLog(@"encryptedData:%@",encryptedData);

    if (error != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Encryption error:"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    //convert the NSData in a NSString
#if HEX2STRING
    cryptedString = [FirstViewController hexStringFromData:(NSData *)encryptedData];
#else
    cryptedString = [[NSString alloc] initWithData:encryptedData
                                          encoding:[NSString defaultCStringEncoding]];
#endif
    NSLog(@"encryptedText:%@",cryptedString);

    //show the encrypted text
    textCrypted.text = cryptedString;
    textToDecrypt.text = cryptedString;
    textDecrypted.text = nil;
}


/* Action for decrypt to the text destination */
- (IBAction)decryptButtonAction:(id)sender {
    
    //NSString *cryptedString = @"—,º3‰ ZQúwΩ°àõJgC{l¿{•Z¡Î∑8L˛˝f≈¥eÛ";
    //NSString *cryptedString = @"0201793390C291CE012F793390C291CE012F793390C291CE012F77211FB052E1DAFA626E6C336D855365C024D3F1132EFC5BCEF116AE50CAF09EB196FB8F35F51122BEDA8813";
    
    //test if the text to decrypt is empty
    if (textToDecrypt.text == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error:"
                                                        message:@"I have no text to decrypt. Please encrypt first!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    //test if the decryption password is empty, otherwise fill with default password
    if (password2decrypt.text == nil) password2decrypt.text = kGoodPassword;
    
    //convert the NSString in a NSData
#if HEX2STRING
    NSData *data = [FirstViewController dataFromHexString:textToDecrypt.text];
#else
    NSData *data = [textToDecrypt.text dataUsingEncoding:[NSString defaultCStringEncoding]];
#endif
    NSLog(@"encryptedData2:%@",data);
    
    //decrypt!
    NSError *error = nil;
    
    NSData *decryptedData = [RNDecryptor decryptData:data
                                        withPassword:password2decrypt.text
                                               error:&error];
    
    if (error != nil)
    {
        stateLabel.text = @"KO";
        stateLabel.textColor = [UIColor redColor];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error:"
                                                        message:error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        stateLabel.text = @"OK";
        stateLabel.textColor = [UIColor greenColor];
    }

    //convert NSData to NSString
    NSString *newStr = [[NSString alloc] initWithData:decryptedData
                                              encoding:NSUTF8StringEncoding];
    
    //show the decrypted text
    textDecrypted.text = newStr;
    NSLog(@"destinationText:%@",newStr);
}

- (IBAction)resetButtonAction:(id)sender {
    textToCrypt.text = nil;
    textCrypted.text = @"Text Encrypted";
    textDecrypted.text = @"Text Decrypted";
    password2crypt.text = nil;
    password2decrypt.text = nil;
    stateLabel.text = nil;
}


#pragma mark- UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark- hex2string Methods

unsigned charTo4Bits(char c){
    unsigned bits = 0;
    if (c > '/' && c<':'){
        bits = c - '0';
    } else if (c > '@' && c < 'G'){
        bits = (c- 'A') + 10;
    } else if (c > '`' && c < 'g'){
        bits = (c- 'a') + 10;
    } else {
        bits = 255;
    }
    return bits;
}

+ (NSString *)hexStringFromData:(NSData*) dataValue
{
    UInt32 byteLength = [dataValue length], byteCounter = 0;
    UInt32 stringLength = (byteLength*2) + 1, stringCounter = 0;
    unsigned char dstBuffer[stringLength];
    unsigned char srcBuffer[byteLength];
    unsigned char *srcPtr = srcBuffer;
    [dataValue getBytes:srcBuffer];
    const unsigned char t[16] = "0123456789ABCDEF";
    
    for (;byteCounter < byteLength; byteCounter++){
        unsigned src = *srcPtr;
        dstBuffer[stringCounter++] = t[src>>4];
        dstBuffer[stringCounter++] = t[src & 15];
        srcPtr++;
    }
    dstBuffer[stringCounter] = '\0';
    
    return [NSString stringWithUTF8String:(char*)dstBuffer];
}

+ (NSData *)dataFromHexString:(NSString*) dataValue
{
    UInt32 stringLength = [dataValue length];
    UInt32 byteLength = stringLength/2;
    UInt32 byteCounter = 0;
    unsigned char srcBuffer[stringLength];
    [dataValue getCString:(char *)srcBuffer maxLength:stringLength /*encoding:NSUTF16BigEndianStringEncoding*/];
    unsigned char *srcPtr = srcBuffer;
    Byte dstBuffer[byteLength];
    Byte *dst = dstBuffer;
    for(;byteCounter < byteLength;){
        unsigned char c = *srcPtr++;
        unsigned char d = *srcPtr++;
        unsigned hi = 0, lo = 0;
        hi = charTo4Bits(c);
        lo = charTo4Bits(d);
        if (hi== 255 || lo == 255){
            //errorCase
            return nil;
        }
        dstBuffer[byteCounter++] = ((hi << 4) | lo);
    }
    
    return [NSData dataWithBytes:dst length:byteLength];
}



@end
