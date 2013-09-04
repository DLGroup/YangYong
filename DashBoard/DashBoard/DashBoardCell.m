//
//  DashBoardCell.m
//  DashBoard
//
//  Created by Teddy on 8/3/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "DashBoardCell.h"

static UIImageView *dashboardCellBG, *rowBG, *rowIcon;
static UIButton *detailArrow;
static UILabel *rowName;
static UITextField *textField;

@implementation DashBoardCell

+ (UITableViewCell *)tableView: (UITableView *)tableView dashBoardCellWithNibName:(NSString *)nibName
{
    //init the cell
    static NSString *cellIdentifier = @"DashBoardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"DashBoardCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //config the sub controls infomation
        dashboardCellBG = (UIImageView *)[cell viewWithTag:DASHBOARDCELLBG];
        rowBG = (UIImageView *)[cell viewWithTag:ROWBG];
        rowIcon = (UIImageView *)[cell viewWithTag:ROWICON];
        detailArrow = (UIButton *)[cell viewWithTag:DETAILARROW];
        rowName = (UILabel *)[cell viewWithTag:ROWNAME];
        textField = (UITextField *)[cell viewWithTag:TEXTFIELD];
    }
    return cell;
}

+ (UITextField *)textField
{
    return textField;
}

#pragma Config the custom cell attribute

+ (void)setHiddenOfTextField:(BOOL)textFieldHidden andRowIcon:(BOOL)rowIconHidden andDetailArraw:(BOOL)detailArrowHidden
{
    textField.hidden = textFieldHidden;
    rowIcon.hidden = rowIconHidden;
    detailArrow.hidden =detailArrowHidden;
}

+ (void)setImageOfRowBG:(NSString *)rowBGName andRowIcon:(NSString *)rowIconBG andRowName:(NSString *)therowName
{
    [rowIcon setImage:[UIImage imageNamed:rowIconBG]];
    [rowBG setImage:[UIImage imageNamed:rowBGName]];
    [rowName setText:therowName];
}

+ (void)setRowName:(NSString *)therowName
{
    [rowName setText:therowName];
}

+ (void)setImageOfRowBG:(NSString *)rowBGName andRowIcon:(NSString *)rowIconBG
{
    [DashBoardCell setImageOfRowBG:rowBGName andRowIcon:rowIconBG andRowName:nil];
}

@end
