//
//  ViewController.m
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import "ViewController.h"
#import "MusicPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    buttonPressed = (UIButton *)sender;
    [self performSegueWithIdentifier:@"buttonPressedSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"buttonPressedSegue"]) {
        MusicPlayerViewController *mpvc = [segue destinationViewController];
        [mpvc setLocation:buttonPressed.titleLabel.text];
    }
}

@end
