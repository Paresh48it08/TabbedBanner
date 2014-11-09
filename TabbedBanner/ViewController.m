//
//  ViewController.m
//  Simpsons Tapped Out Friends
//
//  Created by Paresh Kacha on 01/11/14.
//  Copyright (c) 2014 Universe. All rights reserved.
//

#import "ViewController.h"
#import "mysql.h"
#import "MySQLKitDatabase.h"
#import "MySQLKitQuery.h"
#import "AppDelegate.h"
#import "Constant.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize nameField;
- (void)viewDidLoad {
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)connectoDbAndPerformAction {
    MySQLKitDatabase* server = [[MySQLKitDatabase alloc] init];
    server.serverName = @"xx.xxx.xxx.xxx";
    server.dbName = @"xxx";
    server.userName = @"xxx";
    server.password = @"xxx";
    server.port = 3306;
    @try{
        [server connect];
        MySQLKitQuery *query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
        query2.sql = [NSString stringWithFormat:@"SELECT ID FROM xxx.yyy WHERE ID=('%@')", nameField.text];
        [query2 execQuery];
        NSInteger len = query2.recordCount;
        if(len == 0)
        {
            query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
            query2.sql = [NSString stringWithFormat:@"INSERT INTO xxx.yyy VALUES ('%@', NOW())", nameField.text];
            [query2 execQuery];
        }
        else
        {
            query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
            query2.sql = [NSString stringWithFormat:@"UPDATE xxx.yyy SET ID=('%@'), Timestamp=NOW() WHERE ID=('%@')", nameField.text,nameField.text];
            [query2 execQuery];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        NSLog(@"ERROR! Message: %@", [server errorMessage]);
        [server alertIfError];
    }
    @finally {
        [server disconnect];
    }
    [self stopLoading];
    [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:isFirstTime];
//    UIStoryboard* storyboard   = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    UITabBarController *tabBar = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    [self performSegueWithIdentifier:@"ToTabBar" sender:nil];
}

- (IBAction)insertUpdateNameInDb:(id)sender {
    if(nameField.text.length == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please Enter any name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        alert.tag = 10;
        [alert show];
        return;
    }
    [self startLoading];
    [nameField resignFirstResponder];
    if(appDel.isInternetAvailable)
    {
        [self performSelectorInBackground:@selector(connectoDbAndPerformAction) withObject:nil];
    }
    else
    {
        [self stopLoading];
        [appDel showInternetNotAvailableAlert];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10)
    {
        [nameField becomeFirstResponder];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [nameField resignFirstResponder];
    return YES;
}
-(void)startLoading
{
    if(!appDel.alertView)
    {
        appDel.alertView = [[UIAlertView alloc] initWithTitle:@"Please wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    }
    [appDel.alertView show];
}
-(void)stopLoading
{
    if([appDel.alertView isVisible])
    {
        [appDel.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
