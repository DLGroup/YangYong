//
//  BobFolderDetailViewController.h
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BobFolderDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSCoding, NSCopying>
{
    NSInteger tag;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil name:(NSString *)thename tag:(NSInteger)thetag;
- (IBAction)camera:(id)sender;
- (IBAction)sound:(id)sender;
- (void)addCellByName:(NSString *)cellName;
- (NSInteger)tag;
- (NSString *)convertTagToNSString;

@end
