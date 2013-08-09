//
//  FoldersViewController.h
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *folderName;

@interface FoldersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSUInteger sectionCounts;
}

+ (void)setFolderName: (NSString *)folderName;

@end
