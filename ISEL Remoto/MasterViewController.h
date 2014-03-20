//
//  MasterViewController.h
//  ISEL Remoto
//
//  Created by Omr on 17/03/14.
//  Copyright (c) 2014 Omr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteControl.h"


@interface MasterViewController : UITableViewController

@property (nonatomic,retain) RemoteControl *RemoteControl;

@property (weak, nonatomic) IBOutlet UIView *UIViewContainerButtons;

- (IBAction)PowerButton:(id)sender;

@end
