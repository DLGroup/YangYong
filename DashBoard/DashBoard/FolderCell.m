//
//  FolderCell.m
//  DashBoard
//
//  Created by Teddy on 8/4/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "FolderCell.h"

typedef enum{
    ARROWBTN = 101, PLAYBTN, CLIPNAME, CONFIGINFO, REDBTN
}FolderCellTag;

static UIButton *arrowBtn, *playBtn, *redBtn;
static UILabel *clipName, *configInfo;

@implementation FolderCell

#pragma mark - init a custom cell

+ (UITableViewCell *)tableView:(UITableView *)tableView folderCellWithNibName:(NSString *)nibName
{
    static NSString *cellIdentifier = @"FolderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        //init the cell
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FolderCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //init the sub controls
        arrowBtn = (UIButton *)[cell viewWithTag:ARROWBTN];
        playBtn = (UIButton *)[cell viewWithTag:PLAYBTN];
        clipName = (UILabel *)[cell viewWithTag:CLIPNAME];
        configInfo = (UILabel *)[cell viewWithTag:CONFIGINFO];
        redBtn = (UIButton *)[cell viewWithTag:REDBTN];
    }
    return cell;
}

#pragma mark - Config the already existed cell's sub controls

+ (void)setArrowBtnHidden:(BOOL)arrowBtnHidden andPlayBtnHidden:(BOOL)playBtnHidden andRedBtnHidden:(BOOL)redBtnHidden
{
    arrowBtn.hidden = arrowBtnHidden;
    playBtn.hidden = playBtnHidden;
    redBtn.hidden = redBtnHidden;
}

+ (void)setClipName:(NSString *)name andColor:(UIColor *)color
{
    clipName.text = [name copy];
    [clipName setTextColor:color];
}

+ (void)setConfigInfo:(NSString *)configInformation
{
    //copy method ok or not ?
    configInfo.text = [configInformation copy];
}

+ (UIButton *)playBtn
{
    return playBtn;
}

+ (UIButton *)arrowBtn
{
    return arrowBtn;
}

@end
