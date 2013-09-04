//
//  VoiceTag.h
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceTag : UIViewController

@property (copy, nonatomic) NSString *tagName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
