//
//  TagView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirInfo;
@interface TagView : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DirInfo *dirInfo;
@end
