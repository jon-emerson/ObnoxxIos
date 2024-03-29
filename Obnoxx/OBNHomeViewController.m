//
//  OBHomeViewController.m
//  Obnoxx
//
//  Created by Chandrashekar Raghavan on 7/30/14.
//  Copyright (c) 2014 Obnoxx. All rights reserved.
//

#import "OBNHomeViewController.h"
#import "OBNRecordViewController.h"
#import "OBNMessageViewController.h"

@implementation OBNHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Create the record and message list views, add them to an array
        // and turn that array assign that array as the view controllers list
        // for this tab bar controller
        OBNRecordViewController *recorder = [[OBNRecordViewController alloc]init];
        OBNMessageViewController *messages = [[OBNMessageViewController alloc] init];
        messages.title = @"Noxxes";
        
        NSArray *coreViews = [[NSArray alloc] initWithObjects:recorder,messages,nil];
        self.viewControllers = coreViews;
    }
    return self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
