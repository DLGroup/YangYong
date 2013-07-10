//
//  BobFolderDetailViewController.m
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import "BobFolderDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#define PLAYAUDIOTAG 100
#define DATEINFOTAG 101
#define DETAILINFOTAG 102
#define LABELTAG 103

@interface BobFolderDetailViewController ()
{
    NSString *name;
    NSInteger tag;
}

@end

@implementation BobFolderDetailViewController

@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (IBAction)camera:(id)sender {
}

- (IBAction)sound:(id)sender {
    tag++;
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //need to change according to the custom cell amount
    return tag;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (void)playAudio:(id)sender{
    
}

- (void)detailInfo:(id)sender{
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *str = @"SoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"SoundCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = (UILabel *)[cell viewWithTag:103];
        label.layer.cornerRadius = 10;
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
