//
//  BobRootViewController.h
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BobRootViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *myFolderSections;
    NSMutableArray *myFolderData;
}
@end
