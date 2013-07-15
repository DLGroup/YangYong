//
//  BobFolderDetailViewController.m
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import "BobFolderDetailViewController.h"
#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>

#define PLAYAUDIOTAG 100
#define DATEINFOTAG 101
#define DETAILINFOTAG 102
#define LABELTAG 103
extern NSMutableDictionary *recording;

@interface BobFolderDetailViewController ()
{
    NSString *name;
//  NSArray *dataInfoOfCell;
}
@end

@implementation BobFolderDetailViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil name:(NSString *)thename tag:(NSInteger)thetag
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tag = thetag;
        name = thename;
        self.title = name;
    }
    return self;
}

- (void)addCellByName:(NSString *)cellName{
    ++tag;
    name = cellName;
    [tableView reloadData];
}
- (NSInteger)tag{
    return tag;
}

- (NSString *)convertTagToNSString{
    return [[NSString alloc]initWithFormat:@"%d", tag];
}

- (IBAction)camera:(id)sender {
    
}

- (IBAction)sound:(id)sender {
    
    [self addCellByName:name];
}

- (void)playAudio:(id)sender{
    
}

- (void)detailInfo:(id)sender{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tag;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"SoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"SoundCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:103];
        label1.layer.cornerRadius = 10;
        
        UILabel *label2 = (UILabel *)[cell viewWithTag:101];
        label2.text = [[NSString alloc] initWithFormat:@"%@", name];
//        
//        UIButton *playButton = (UIButton *)[cell viewWithTag:PLAYAUDIO];
//        [playButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        
//        UILabel *label = (UILabel *)[cell viewWithTag:DATEINFO];
        //set current date infomation
        //...
        
//        UIButton *detailButton = (UIButton *)[cell viewWithTag:DETAILINFO];
//        [detailButton addTarget:self action:@selector(detailInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
