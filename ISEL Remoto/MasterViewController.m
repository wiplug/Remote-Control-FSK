//
//  MasterViewController.m
//  ISEL Remoto
//
//  Created by Omr on 17/03/14.
//  Copyright (c) 2014 Omr. All rights reserved.
//

#import "MasterViewController.h"



@interface MasterViewController ()

@end

@implementation MasterViewController

//Not necesary.
//@synthesize RemoteControl = _RemoteControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //SET BACKGROUND IMAGE TO VIEW CONTAINER BUTTONS
    
    UIColor *ImageBackground = [ [UIColor alloc] initWithPatternImage: [UIImage imageNamed:@"container.png"]];
    self.UIViewContainerButtons.backgroundColor = ImageBackground;
    
    
    
    NSLog(@"wooo");
    
    // INIT OBJECT  EncodeDataIntoFSK
    
    _RemoteControl = [ [RemoteControl alloc] init];
    
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
    BOTON
 
    @id : POWER
 
*/

- (IBAction)PowerButton:(id)sender {
   
    
    NSLog(@"power");
    
    [_RemoteControl SendSignalWithProtocol:@"009" AndKeyPressed:@"01"];

    
    
    
}



@end
