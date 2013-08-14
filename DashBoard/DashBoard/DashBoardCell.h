//
//  DashBoardCell.h
//  DashBoard
//
//  Created by Teddy on 8/3/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DashBoardCell : NSObject

+ (UITableViewCell *)tableView: (UITableView *)tableView dashBoardCellWithNibName:(NSString *)nibName;

+ (void)setHiddenOfTextField:(BOOL)textFieldHidden andRowIcon:(BOOL)rowIconHidden andDetailArraw:(BOOL)detailArrowHidden;

+ (void)setImageOfRowBG:(NSString *)rowBGName andRowIcon:(NSString *)rowIconBG andRowName:(NSString *)therowName;

+ (void)setImageOfRowBG:(NSString *)rowBGName andRowIcon:(NSString *)rowIconBG;

+ (void)setRowName:(NSString *)therowName;

+ (UITextField *)textField;

@end
