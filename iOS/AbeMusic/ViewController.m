//
//  ViewController.m
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import "ViewController.h"
#import "MusicPlayerViewController.h"
#import "FSNConnection.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize allSongs;
@synthesize json;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBarHidden = YES;
    
    MPMediaQuery *allSongsQuery = [[MPMediaQuery alloc] init];
    NSArray *itemsFromQuery = [allSongsQuery items];
    
    allSongs = [[NSMutableArray alloc] init];
    
    for (MPMediaItem *song in itemsFromQuery) {
        [allSongs addObject:[NSDictionary dictionaryWithObjectsAndKeys:[song valueForProperty:MPMediaItemPropertyTitle], @"title", [song valueForProperty:MPMediaItemPropertyArtist], @"artist", nil]];
    }
    
    NSError *error;
    json = [NSJSONSerialization dataWithJSONObject:allSongs options:NSJSONWritingPrettyPrinted error:&error];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:json forKey:@"AllSongs"];
    
//    FSNConnection *connection = [FSNConnection withUrl:nil
//                                                method:FSNRequestMethodPOST
//                                               headers:nil
//                                            parameters:parameters
//                                            parseBlock:nil
//                                       completionBlock:nil
//                                         progressBlock:nil];
    /*^(FSNConnection *c) {
     NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
     }*/
    
//    [connection start];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    buttonPressed = (UIButton *)sender;
    [self performSegueWithIdentifier:@"buttonPressedSegue" sender:self];
//    if ([buttonPressed.titleLabel.text isEqualToString:@"Home"]) {
//        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSStringEncodingConversionAllowLossy];
//        NSLog(@"%@", jsonString);
//    } else {
//        
//    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"buttonPressedSegue"]) {
        MusicPlayerViewController *mpvc = [segue destinationViewController];
        [mpvc setLocation:buttonPressed.titleLabel.text];
    }
}

@end
