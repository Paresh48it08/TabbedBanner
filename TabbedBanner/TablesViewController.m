/*
     File: TextViewController.m
 Abstract: A simple view controller that manages a content view and an ADBannerView.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "TablesViewController.h"
#import "BannerViewController.h"
#import "MySQLKitDatabase.h"
#import "MySQLKitQuery.h"
@interface TablesViewController ()

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *timerLabel;

@end

@implementation TablesViewController
@synthesize Donators,friendCodes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUpdateAlert)];
    self.tabBarController.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
#pragma mark -
#pragma mark Add Button method
-(void)addUpdateAlert
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Enter Your Name" message:@"Enter your name to be first in donator's list." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if([alertView textFieldAtIndex:0].text.length == 0)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please Enter any name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            alert.tag = 10;
            [alert show];
            return;
        }
        [self startLoading];
        [[alertView textFieldAtIndex:0] resignFirstResponder];
        if(appDel.isInternetAvailable)
        {
            [self performSelectorInBackground:@selector(connectoDbAndPerformAction:) withObject:[alertView textFieldAtIndex:0]];
        }
        else
        {
            [self stopLoading];
            [appDel showInternetNotAvailableAlert];
        }
    }
}
- (void)connectoDbAndPerformAction:(UITextField *)nameField {
    MySQLKitDatabase* server = [[MySQLKitDatabase alloc] init];
    server.serverName = @"83.161.149.206";
    server.dbName = @"simpsonstappedout";
    server.userName = @"STO12345";
    server.password = @"3wb7eu6TwE3y7wmn";
    server.port = 3306;
    @try{
        [server connect];
        MySQLKitQuery *query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
        query2.sql = [NSString stringWithFormat:@"SELECT ID FROM simpsonstappedout.codes WHERE ID=('%@')", nameField.text];
        [query2 execQuery];
        NSInteger len = query2.recordCount;
        if(len == 0)
        {
            query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
            query2.sql = [NSString stringWithFormat:@"INSERT INTO simpsonstappedout.codes VALUES ('%@', NOW())", nameField.text];
            [query2 execQuery];
        }
        else
        {
            query2 = [[MySQLKitQuery alloc] initWithDatabase:server];
            query2.sql = [NSString stringWithFormat:@"UPDATE simpsonstappedout.codes SET ID=('%@'), Timestamp=NOW() WHERE ID=('%@')", nameField.text,nameField.text];
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
    [self updateDontaorsList];
    [self stopLoading];
    
}
#pragma mark -
#pragma mark Table value update
- (void)updateDontaorsList
{
    MySQLKitDatabase* server = [[MySQLKitDatabase alloc] init];
    server.serverName = @"83.161.149.206";
    server.dbName = @"simpsonstappedout";
    server.userName = @"STO12345";
    server.password = @"3wb7eu6TwE3y7wmn";
    server.port = 3306;
    @try{
        [server connect];
        NSString * tableString;
        if(self.tabBarController.selectedIndex == 0)
        {
            tableString = @"Donations";
        }
        else if (self.tabBarController.selectedIndex == 1)
        {
            tableString = @"codes";
        }
        [self allvalues:server table:tableString dbName:@"simpsonstappedout"];
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
    if(self.tabBarController.selectedIndex == 0)
    {
        [Donators reloadData];
    }
    else if (self.tabBarController.selectedIndex == 1)
    {
        [friendCodes reloadData];
    }
}

- (NSMutableArray *)allvalues:(MySQLKitDatabase *)server table:(NSString *)table dbName:(NSString *)dbName{
    valueAarray = [NSMutableArray new];
    MySQLKitQuery *query3 = [[MySQLKitQuery alloc] initWithDatabase:server];
    query3.sql = [NSString stringWithFormat:@"select * from %@.%@", dbName,table];
    [query3 execQuery];
    NSInteger len = query3.recordCount;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    for(int i = 0; i < len; i++)
    {
        [dict setValue:[query3 stringValFromRow:i Column:1] forKey:[query3 stringValFromRow:i Column:0]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSArray *sortedKeys = [dict  keysSortedByValueUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2)
                           {
                               NSDate *date1 = [dateFormatter dateFromString:obj1];
                               NSDate *date2 = [dateFormatter dateFromString:obj2];
                               return [date1 compare:date2];
                           }];
    valueAarray = [sortedKeys mutableCopy];
    return valueAarray;
}
#pragma mark -
#pragma mark Table Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return valueAarray.count;
}
-(UIColor *)getBGColor:(NSIndexPath *)indexPath
{
    int count = 10;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        count = 20;
    }
    float Red = (62 + (10*(indexPath.row%count)))/255.0;
    float Green = (134 + (6*(indexPath.row%count)))/255.0;
    float Blue = (176 + (4*(indexPath.row%count)))/255.0;
    return [UIColor colorWithRed:Red green:Green blue:Blue alpha:0.7];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellID = @"CellId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [self getBGColor:indexPath];
    cell.textLabel.text = [valueAarray objectAtIndex:(valueAarray.count-1)-indexPath.row];
    return cell;
}
#pragma mark -
#pragma mark Indicators method
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
    //    if([appDel.alertView isVisible])
    {
        [appDel.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

@end
