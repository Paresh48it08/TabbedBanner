//
//  ViewController.h
//  Simpsons Tapped Out Friends
//
//  Created by Paresh Kacha on 01/11/14.
//  Copyright (c) 2014 Universe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    AppDelegate * appDel;
}
@property (strong, nonatomic) IBOutlet UITextField *nameField;
- (IBAction)insertUpdateNameInDb:(id)sender;

@end

