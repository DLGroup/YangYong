//
//  TagViewController.m
//  DashBoard
//
//  Created by YangYong on 8/19/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "TagViewController.h"

#define NAME 104

@implementation TagViewController

@synthesize tableView = _tableView;
@synthesize tagName = _tagName;
@synthesize editView = _editView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Tag Edit";
        removeNum = 0;
        tagNames = [[NSMutableArray alloc] init];
        persistence = [Persistence sharedPersistence];
        isChangeName = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStyleBordered target:self action:@selector(add:)];
    editButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = editButton;
    [self reloadTags];
    _tableView.editing = YES;
}

- (void)reloadTags
{
    for (NSString *theTag in [[persistence tags] allKeys]) {
        [tagNames addObject:theTag];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tagNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tagEditID = @"TagEdit";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tagEditID];
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FolderEditCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *image = (UIImageView *)[cell viewWithTag:103];
        [image setImage:[UIImage imageNamed:@"tag_icon.png"]];
        
        UILabel *tagLabel = (UILabel *)[cell viewWithTag:NAME];
        tagLabel.text = [tagNames objectAtIndex:indexPath.row];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [persistence removeTag:[tagNames objectAtIndex:indexPath.row]];
    [tagNames removeObjectAtIndex:indexPath.row];
    [_tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isChangeName = YES;
    removeNum = indexPath.row;
    _tagName.delegate = self;
    [self animation];
    [_tagName becomeFirstResponder];
}

- (void)add:(id)sender
{
    isChangeName = NO;
    _tagName.delegate = self;
    [self animation];
    [_tagName becomeFirstResponder];
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text = NULL;
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:_tableView];
    CGPoint contentOffset = _tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - 160.0f);
    [_tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (![self isBlankFloderName:textField]) {
        for (NSString *textFieldName in tagNames) {
            if ([textFieldName isEqualToString:textField.text]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Existed Name" message:@"The name you input already has existed.\nPlease input a new name !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                textField.text = nil;
                return YES;
            }
        }
        if (isChangeName) {
            [persistence changeTagName:[tagNames objectAtIndex:removeNum] toNewName:textField.text];
            [tagNames removeObjectAtIndex:removeNum];
            [tagNames addObject:textField.text];

        }
        else {
            [tagNames addObject:textField.text];
            [persistence addTag:textField.text];
        }
        textField.text = nil;
    }
    [_tableView reloadData];
    [self animation];
    return YES;
}

#pragma used by textFieldShouldReturn:
//use c language to delete the blank beginning
-(BOOL)isBlankFloderName:(UITextField *)textField{
    //convert the textField.text from NSSttring* to char*
    char *str = (char *)[textField.text UTF8String];
    
    //the algorithm about delete blank beginning char
    int len = strlen(str);
    if (len <=0 ) {
        return TRUE;
    }
    char *myStr = NULL;
    for (int i=0; i<len; ++i) {
        if (str[i] != ' '){
            myStr = &str[i];
            break;
        }
    }
    if (myStr==NULL) {
        return TRUE;
    }
    else{
        textField.text = [NSString stringWithUTF8String:myStr];
        return FALSE;
    }
}

- (void)animation{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         //animation
         CGFloat positionX = _editView.frame.size.width / 2;
         CGFloat x = (_editView.layer.position.x == positionX) ? 320+positionX:positionX;
         [_editView.layer setPosition:CGPointMake(x, _editView.layer.position.y)];
     }completion:nil];
}

@end
