//
//  OBNConversationViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 8/19/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNConversationViewController.h"
#import "OBNServerCommunicator.h"


@interface OBNConversationViewController ()
@property (nonatomic, strong) IBOutlet UITableView *conversation;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

-(IBAction) backButton:(id)selector;

@end

@implementation OBNConversationViewController

-(IBAction) backButton:(id)selector
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _conversation = [[UITableView alloc] init];
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    OBNState *appState = [OBNState sharedInstance];
    int i;
    NSLog(@"Messages");
    
    // Populate conversation view with deliveries from this user
    for(i=0;i<appState.deliveries.count;i++)
    {
        if([[appState.deliveries[i] valueForKey:@"userId"] isEqualToString:self.sender])
        {
            [self.messages addObject:appState.deliveries[i]];
            NSLog(@"%@",appState.deliveries[i]);
            continue;
        }
        
        if([[appState.deliveries[i] valueForKey:@"recipientUserId"] isEqualToString:self.sender])
        {
            [self.messages addObject:appState.deliveries[i]];
            NSLog(@"%@",appState.deliveries[i]);
            continue;
        }

        if([[appState.deliveries[i] valueForKey:@"phoneNumber"] isEqualToString:self.sender])
        {
            [self.messages addObject:appState.deliveries[i]];
            NSLog(@"%@",appState.deliveries[i]);
            continue;
        }

    }

    [self.conversation reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    OBNState *appState = [OBNState sharedInstance];
    if (self.messages) {
        return self.messages.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OBNState *appState = [OBNState sharedInstance];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendString:@"From "];
    
    for(int i=0;i<appState.users.count;i++)
    {
        if([[appState.users[i] valueForKey:@"id"] isEqualToString:[self.messages[indexPath.row] valueForKey:@"userId"]])
        {
            [message appendString:[appState.users[i] valueForKey:@"name"]];
            break;
        }
    }
    [message appendString:@" to "];
    
    for(int i=0;i<appState.users.count;i++)
    {
        if([[appState.users[i] valueForKey:@"id"] isEqualToString:[self.messages[indexPath.row] valueForKey:@"recipientUserId"]])
        {
            [message appendString:[appState.users[i] valueForKey:@"name"]];
            break;
        }
    }
    UIImage *img = [UIImage imageNamed:@"heart.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,100,110);
    
    [button setImage:img forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.textLabel.text =  message;
    cell.accessoryView = button;
    return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.conversation];
    
    NSIndexPath *indexPath = [self.conversation indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil){
        [self tableView:self.conversation accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // User selected a sound, play it back
     OBNState *appState = [OBNState sharedInstance];
     NSDictionary *delivery = self.messages[indexPath.row];
     NSMutableArray *sounds = appState.sounds;
     
     NSString *soundURL;
     NSString *soundId = [delivery valueForKey:@"soundId"];
     
     for (int i = 0; i < sounds.count; i++) {
         NSString *s = [sounds[i] valueForKey:@"id"];
         if ([soundId isEqualToString:s]) {
             soundURL = [sounds[i] valueForKey:@"soundFileUrl"];
             break;
         }
     }
     OBNAudioManager *audioManager = [OBNAudioManager sharedInstance];
    
     // Log playback
     dispatch_async(dispatch_get_main_queue(), ^{
         OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
         [server logPlayback:soundId delivery:[delivery valueForKey:@"id"]];
     });
    
     
     dispatch_async(dispatch_get_main_queue(), ^{
         NSURL *url = [NSURL URLWithString:soundURL];
         NSData *urlData = [NSData dataWithContentsOfURL:url];
         NSString *filePath;
         if (urlData) {
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
             NSString  *documentsDirectory = [paths objectAtIndex:0];
     
             filePath = [NSString stringWithFormat:@"%@/%@",
                         documentsDirectory,@"sound.m4a"];
             [urlData writeToFile:filePath atomically:YES];
         }
         [audioManager play:filePath isRecording:NO filter:nil];
     });
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Hearting", indexPath);
    OBNServerCommunicator *server = [OBNServerCommunicator sharedInstance];
    
    OBNState *appState = [OBNState sharedInstance];
    NSDictionary *delivery = self.messages[indexPath.row];
    NSMutableArray *sounds = appState.sounds;
    
    BOOL hearted;
    NSString *soundId = [delivery valueForKey:@"soundId"];
    
    for (int i = 0; i < sounds.count; i++) {
        NSString *s = [sounds[i] valueForKey:@"id"];
        if ([soundId isEqualToString:s]) {
            
            NSString *value =[sounds[i] valueForKey:@"hearted"];
            if([[sounds[i] valueForKey:@"hearted"] isEqualToString:@"false"])
                hearted = false;
            else hearted = true;
            break;
        }
    }
    hearted = !hearted;
    [server heart:soundId hearted:hearted];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
