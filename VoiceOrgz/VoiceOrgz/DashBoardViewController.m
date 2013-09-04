//
//  DashBoardViewController.m
//  VoiceOrgz
//
//  Created by XIAO LIHAO on 2/25/13.
//  Copyright (c) 2013 diluntech. All rights reserved.
//

#import "DashBoardViewController.h"
#import "VoiceListViewController.h"
#import "SharedObj.h"
#import "DirInfo.h"
#import "CameraView.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalObj.h"
#import "FolderEditView.h"
#import "TagView.h"
#import "GlobalObj.h"
#import "DLRecorder.h"
#define TABLEVIEWCELL_BACKGROUND_TAG    100
#define TABLEVIEWCELL_IMAGE_TAG         101
#define TABLEVIEWCELL_LABEL_TAG         102
#define TABLEVIEWCELL_BUTTON_TAG        103
#define TABLEVIEWCELL_TEXTFIELD_TAG     104

@interface DashBoardViewController ()
-(void) keyboardDidShow: (NSNotification *)notif;
-(void) keyboardDidHide: (NSNotification *)notif;
-(UITableViewCell*)paddingCell;
@end

@implementation DashBoardViewController

@synthesize tableView=_tableView;
@synthesize activeTextField=_activeTextField;
@synthesize dirInfo=_dirInfo;
@synthesize layoutView=_layoutView;
@synthesize backgroudView=_backgroudView;
@synthesize recordBackgroudView=_recordBackgroudView;
@synthesize cameraBackgroundView=_cameraBackgroundView;
@synthesize recordBtn=_recordBtn;
@synthesize cameraBtn=_cameraBtn;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"DashBoard";
    }
    return self;
}

- (IBAction)startRecording:(id)sender{
    VoiceListViewController *voiceListViewController=[[VoiceListViewController alloc]
                                                      initWithNibName:@"VoiceListViewController"
                                                      bundle:nil
                                                      dirInfo:[_dirInfo.dirsMap valueForKey:@"Recordings"]
                                                      recording:YES
                                                      withVoice:nil];
    
    [self.navigationController pushViewController:voiceListViewController animated:YES];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}


- (IBAction)startCamera:(id)sender{
    UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSLog(@"camera is not available");
        return;
    }
    
    ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
    ipc.allowsEditing=NO;
    ipc.showsCameraControls=NO;
    
    ipc.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.3);
    

    NSString *xibFile=@"CameraView";
    if([[UIScreen mainScreen] bounds].size.height==568){
        xibFile=@"CameraViewR";
        ipc.cameraViewTransform = CGAffineTransformMakeScale(1.0, 1.42);

    }
    
    _layoutView=[[CameraView alloc] initWithNibName:xibFile bundle:nil
                                                ipc:ipc dirInfo:[_dirInfo.dirsMap objectForKey:@"Recordings"]];
    ipc.cameraOverlayView=_layoutView.view;
    ipc.delegate=_layoutView;
    
    
    [self.navigationController presentViewController:ipc animated:NO completion:^(void){
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    }];
}

// folder edit
- (void)edit{
    if(keyboardVisible){
        [self keyboardDidHide:nil];
    }
    
    FolderEditView *editView=[[FolderEditView alloc] initWithNibName:@"FolderEditView" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editView];
    [navigationController.navigationBar setBackgroundImage:[GlobalObj getImageFromFile:@"navigation_bar_background.png"] forBarMetrics:UIBarMetricsDefault ];
    
    [self presentModalViewController:navigationController animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *rightBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    
    UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"DashBoard" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    rightBarBtnItem.tintColor=[UIColor blackColor];
    backBarBtnItem.tintColor=[UIColor blackColor];
    
    self.navigationItem.rightBarButtonItem=rightBarBtnItem;
    self.navigationItem.backBarButtonItem=backBarBtnItem;
    

    _tableView.backgroundView=[[UIImageView alloc] initWithImage:[GlobalObj getImageFromFile:@"dashboard_gray_bckgd.png"]];
    _backgroudView.image=[GlobalObj getImageFromFile:@"dashboard_gray_bckgd.png"];
    _cameraBackgroundView.image=[GlobalObj getImageFromFile:@"camera_btn_background.png"];
    _recordBackgroudView.image=[GlobalObj getImageFromFile:@"recording_btn_background.png"];
    
    [_cameraBtn setImage:[GlobalObj getImageFromFile:@"camera_btn.png"] forState:UIControlStateNormal];
    [_recordBtn setImage:[GlobalObj getImageFromFile:@"recording_btn.png"] forState:UIControlStateNormal];

    _dirInfo = [SharedObj sharedObj].dirInfo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"dashboard memory warning");
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0 || section == 2)
        return 1;
    else if(section == 1)
        return _dirInfo.subDirs.count;
    
    // Padding cells;
    else
        return 2;
}


-(UITableViewCell*)paddingCell{
    static NSString *TableIdentifier = @"PaddingCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:
                             TableIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier];
    }
    
    cell.hidden=YES;
    return cell;
}

- (void)_voiceMain:(id)sender{
    NSLog(@"click btn");
    UITableViewCell *cell=(UITableViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath=[_tableView indexPathForCell:cell];
    [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 3)
        return [self paddingCell];
    
    
    static NSString *TableIdentifier = @"BaseCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:
                             TableIdentifier];
    
    if(!cell){
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FolderCell" owner:self options:nil] lastObject];
    }
    UIButton *btn=(UIButton*)[cell viewWithTag:TABLEVIEWCELL_BUTTON_TAG];
    [btn addTarget:self action:@selector(_voiceMain:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *background=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_BACKGROUND_TAG];
    UIImageView *imageView=(UIImageView*)[cell viewWithTag:TABLEVIEWCELL_IMAGE_TAG];
    UILabel *label=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_LABEL_TAG];
    UITextField *textField=(UITextField*)[cell viewWithTag:TABLEVIEWCELL_TEXTFIELD_TAG];
    textField.hidden=YES;
    
    label.font=[UIFont systemFontOfSize:15.0f];
    if(indexPath.section==0){
        background.image=[GlobalObj getImageFromFile:@"recording_background.png"];
        imageView.image=[GlobalObj getImageFromFile:@"recording_icon.png"];
        label.text=@"Recordings";
        btn.hidden=NO;
    }
    else if(indexPath.section==2){
        background.image=[GlobalObj getImageFromFile:@"tag_cell_bckgd.png"];
        imageView.image=[GlobalObj getImageFromFile:@"tag_icon.png"];
        label.text=@"Tags";
        btn.hidden=NO;
    }
    else if((indexPath.section==1)&&(indexPath.row==_dirInfo.subDirs.count-1)){
        background.image=[GlobalObj getImageFromFile:@"folder_background.png"];
        CGRect frame=label.frame;
        frame.origin.x=imageView.frame.origin.x;
        label.frame=frame;
        imageView.hidden=YES;
        label.text=@"Enter new folder name";
        btn.hidden=YES;
        label.font=[UIFont italicSystemFontOfSize:15.0f];

        
    }
    else{

        background.image=[GlobalObj getImageFromFile:@"folder_background.png"];
        imageView.image=[GlobalObj getImageFromFile:@"folder_icon.png"];
        label.text=[_dirInfo.subDirs objectAtIndex:indexPath.row+1];
        btn.hidden=NO;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0 || section == 3)
        return nil;
    
    UIView* customView = [[UIView alloc]
                          initWithFrame:CGRectMake(10.0, 0.0, 300.0, 35.0)];
	
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font=[UIFont italicSystemFontOfSize:17.0f];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 35.0);
    if(section==1)
        headerLabel.text = @"My Folders";
    else if(section==2)
        headerLabel.text=@"My Tags";
	[customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0)
        return 0.0;
    else
        return 35.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor=[UIColor colorWithPatternImage:[GlobalObj getImageFromFile:@"dashboard_cell_bckgd.png"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(keyboardVisible){
        [self keyboardDidHide:nil];
    }
    
    //Tag
    if(indexPath.section==2){
        TagView *tagView=[[TagView alloc] initWithNibName:@"TagView" bundle:nil];
        [self.navigationController pushViewController:tagView animated:YES];
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *label=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_LABEL_TAG];
    UITextField *textField=(UITextField*)[cell viewWithTag:TABLEVIEWCELL_TEXTFIELD_TAG];

    if((indexPath.section==1)&&(indexPath.row==_dirInfo.subDirs.count-1)){
        label.text=@"";
        textField.hidden=NO;
        [textField becomeFirstResponder];
        return;
    }
  
    VoiceListViewController *voiceListViewController=[[VoiceListViewController alloc]
                                                      initWithNibName:@"VoiceListViewController"
                                                      bundle:nil
                                                      dirInfo:[_dirInfo.dirsMap valueForKey:label.text]
                                                      recording:NO
                                                      withVoice:nil];
    
    [self.navigationController pushViewController:voiceListViewController animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    UITableViewCell *cell= [_tableView cellForRowAtIndexPath:[_tableView indexPathForSelectedRow]];
    UILabel *label=(UILabel*)[cell viewWithTag:TABLEVIEWCELL_LABEL_TAG];

    if(![textField.text isEqualToString:@""]){
        
        if(![_dirInfo.dirsMap objectForKey:textField.text]){
            label.text=textField.text;
            [_dirInfo.subDirs addObject:textField.text];
            
            DirInfo *info=[[DirInfo alloc] initWithParent:textField.text];
            [_dirInfo.dirsMap setObject:info forKey:textField.text];
        }
        else{
            
            //process same folder name
            label.text=@"Enter new folder name";
        }
    }
    else{
        label.text=@"Enter new folder name";
        
    }
    [textField removeFromSuperview];
    [_tableView reloadData];
    return YES;
}

- (void) viewWillAppear:(BOOL)animated {
    
    if(_layoutView)
        _layoutView=nil;
	// Register for the events
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector (keyboardDidShow:)
	 name: UIKeyboardDidShowNotification
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector (keyboardDidHide:)
	 name: UIKeyboardDidHideNotification
	 object:nil];
    
	keyboardVisible = NO;
    [_tableView reloadData];
    
    if([GlobalObj globalObj].recorder.state==RECORDING||[GlobalObj globalObj].recorder.state==PAUSE){
        [[GlobalObj globalObj].recorder drop];
    }
    
    
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) keyboardDidShow: (NSNotification *)notif {
	if (keyboardVisible) {
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
    
    CGRect viewFrame = _tableView.frame;
    tableHeight=_tableView.frame.size.height;
    viewFrame.size.height=self.view.frame.size.height-keyboardSize.height;
    _tableView.frame=viewFrame;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dirInfo.subDirs.count-2 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
	keyboardVisible = YES;
}

-(void) keyboardDidHide: (NSNotification *)notif {
	if (!keyboardVisible){
		return;
	}
	
	CGRect viewFrame = _tableView.frame;
    viewFrame.size.height=tableHeight;
    _tableView.frame=viewFrame;
    
	keyboardVisible = NO;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
	_activeTextField = textField;
	return YES;
}


@end







