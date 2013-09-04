//
//  MoveView.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/1/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoveView : UIViewController{
    int lastDirCount;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
