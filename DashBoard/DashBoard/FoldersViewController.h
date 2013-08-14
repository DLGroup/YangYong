//
//  FoldersViewController.h
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoldersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSUInteger sectionCounts;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)name;

@end
