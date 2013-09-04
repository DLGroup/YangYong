//
//  TagView.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 8/5/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "TagView.h"
#import "SharedObj.h"
#import "TagNew.h"
#import "GlobalObj.h"
#import "VoiceInfo.h"
#import "VoiceListViewController.h"
#import "DirInfo.h"
#import <QuartzCore/QuartzCore.h>
@interface TagView ()

@end

@implementation TagView

@synthesize dirInfo=_dirInfo;

- (void)done{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem=rightBtn;
    rightBtn.tintColor=[UIColor blackColor];

    self.navigationItem.leftBarButtonItem=nil;
    [_tableView setEditing:NO animated:YES];
}

- (void)dealloc{
    NSLog(@"tagview dealloc");
    _dirInfo=nil;
}

- (void)edit{
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem=rightBtn;

    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.leftBarButtonItem=leftBtn;
    
    leftBtn.tintColor=[UIColor blackColor];
    rightBtn.tintColor=[UIColor blackColor];
    
    [_tableView setEditing:YES animated:YES];

}


- (void)add{
    [self _add:nil];
}

- (void)_add:(NSString*)tagName{
    TagNew *tagNew=[[TagNew alloc] initWithNibName:@"TagNew" bundle:nil lastTagName:tagName];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tagNew];
    [navigationController.navigationBar setBackgroundImage:[GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];
    
    [self presentModalViewController:navigationController animated:YES];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
        rightBtn.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem=rightBtn;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"Tags";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}



- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView* customView = [[UIView alloc]
                          initWithFrame:CGRectMake(0.0, 0.0, 300.0, 35.0)];
	
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font=[UIFont italicSystemFontOfSize:17.0f];
	headerLabel.frame = CGRectMake(25.0, 0.0, 300.0, 35.0);
    headerLabel.text = @"My Tags";
	[customView addSubview:headerLabel];
    
    return customView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[SharedObj sharedObj].tag count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellId=@"BaseCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell){
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"TagCell" owner:self options:nil] lastObject];
    }
    NSArray *keys=[[SharedObj sharedObj].tag allKeys];
    UILabel *tagName=(UILabel*)[cell viewWithTag:101];
    UILabel *voiceCnt=(UILabel*)[cell viewWithTag:102];

    tagName.text=[keys objectAtIndex:indexPath.row];
    NSArray *voiceList=[[SharedObj sharedObj].tag objectForKey:tagName.text];
    voiceCnt.text=[NSString stringWithFormat:@"%d", voiceList.count];
    CGFloat _width = [voiceCnt.text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f]].width;

    CGRect frame=voiceCnt.frame;
    frame.size.width -= (frame.size.width-_width);
    frame.size.width += 15.0f;
    voiceCnt.frame=frame;
    voiceCnt.layer.cornerRadius=9.0f;
    
  
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor=[UIColor lightGrayColor];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UILabel *tagName=(UILabel*)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:101];

    if(tableView.editing){
        [self _add:tagName.text];
    }
    
    else{
        
        self.dirInfo=nil;
        _dirInfo=[[DirInfo alloc] initWithParent:tagName.text];
        _dirInfo.voices=[[SharedObj sharedObj].tag objectForKey:tagName.text];
        VoiceListViewController *voiceListViewController=[[VoiceListViewController alloc]
                                                          initWithNibName:@"VoiceListViewController"
                                                          bundle:nil
                                                          dirInfo:_dirInfo
                                                          recording:NO
                                                          withVoice:nil];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Tags" style:UIBarButtonItemStyleBordered target:nil action:nil];
        backItem.tintColor=[UIColor blackColor];
        [self.navigationItem setBackBarButtonItem:backItem];
        
        [self.navigationController pushViewController:voiceListViewController animated:YES];

    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.editing ;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UILabel *tagName=(UILabel*)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:101];
    NSMutableArray *array=[[SharedObj sharedObj].tag objectForKey:tagName.text];
    
    //Delete voice tag
    for(int i=0; i<array.count; ++i){
        int voiceIdx=[[array objectAtIndex:i] intValue];
        VoiceInfo *info=[[SharedObj sharedObj].voice objectAtIndex:voiceIdx];
        [info.tag removeObject:tagName.text];
    }
    
    //Delete global tag
    [[SharedObj sharedObj].tag removeObjectForKey:tagName.text];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil]
                     withRowAnimation:UITableViewRowAnimationFade];
}
- (void)viewWillAppear:(BOOL)animated{
    [_tableView reloadData];
}

@end







