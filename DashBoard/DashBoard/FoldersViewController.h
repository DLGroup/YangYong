//
//  FoldersViewController.h
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

NSUInteger sectionCounts;
NSMutableArray *allRecordsConfigInfo;

@interface FoldersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)name;

@end
