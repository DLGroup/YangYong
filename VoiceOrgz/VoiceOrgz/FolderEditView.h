//
//  FolderEditView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/2/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderEditView : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
