//
//  FolderCell.h
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolderCell : NSObject

+ (UITableViewCell *)tableView: (UITableView *)tableView folderCellWithNibName:(NSString *)nibName;

+ (void) setArrowBtnHidden:(BOOL)arrowBtnHidden andPlayBtnHidden:(BOOL)playBtnHidden andRedBtnHidden:(BOOL)redBtnHidden;

+ (void) setClipName:(NSString *)name andColor:(UIColor *)color;

+ (void) setConfigInfo:(NSString *)configInformation;

+ (UIButton *) playBtn;

+ (UIButton *) arrowBtn;
@end
