//
//  MusicPlayerViewController.m
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FSNConnection.h"

@interface MusicPlayerViewController ()

@end

@implementation MusicPlayerViewController

@synthesize location;
@synthesize songQueue;
@synthesize mPlayer;
@synthesize volumeView;
@synthesize locationsArray;

@synthesize playPauseButton;
@synthesize rewindButton;
@synthesize fastForwardButton;
@synthesize albumArtImageView;
@synthesize songControl;

@synthesize titleLabel;
@synthesize artistLabel;
@synthesize albumLabel;
@synthesize seekSlider;
@synthesize locationButton;
@synthesize songInfoView;

@synthesize locationPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        locationsArray = [[NSArray alloc] initWithObjects:@"Home", @"Library", @"Gym", @"Driving", @"Walking", @"Brendan's House", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [albumArtImageView addGestureRecognizer:tapGesture];
    
    
    volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(20, songControl.frame.size.height - 40, songControl.frame.size.width - 40, 20)];
     [songControl addSubview: volumeView];
    
    songQueue = [[NSMutableArray alloc] init];
    
    mPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [mPlayer setShuffleMode:MPMusicShuffleModeSongs];
//    MPMediaPropertyPredicate *artist = [MPMediaPropertyPredicate predicateWithValue:@"Body of Yours" forProperty:MPMediaItemPropertyTitle];
//    MPMediaQuery *artistQ = [[MPMediaQuery alloc] init];
//    [artistQ addFilterPredicate:artist];
//    [mPlayer setQueueWithQuery:artistQ];
    //^ play specific songs
    [mPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
    [mPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidChangeState)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidNavigate)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:mPlayer];
    
    [mPlayer beginGeneratingPlaybackNotifications];
    
    NSTimer *seekSliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSeekSlider) userInfo:nil repeats:YES];
    NSLog(@"%f", seekSliderTimer.timeInterval);
    [locationButton setTitle:location forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    if ((UIButton *)sender == self.playPauseButton) {
        if ([mPlayer playbackState] == MPMusicPlaybackStateStopped || [mPlayer playbackState] == MPMusicPlaybackStatePaused) {
            [mPlayer play];
        } else {
            [mPlayer pause];
        }
    } else if ((UIButton *)sender == self.rewindButton) {
        if (mPlayer.currentPlaybackTime < 3.0) {
            [mPlayer skipToPreviousItem];
        } else {
            if (mPlayer.currentPlaybackTime >= 45.0) {        //change this to a higher value
                MPMediaItem *song = [mPlayer nowPlayingItem];
                NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
                NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
                NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", artist, @"artist", location, @"location", @"+1", @"score", nil];
                NSLog(@"%@", [parameters valueForKey:@"title"]);
//                FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/points"]
//                                                            method:FSNRequestMethodPOST
//                                                           headers:nil
//                                                        parameters:parameters
//                                                        parseBlock:nil
//                                                   completionBlock:^(FSNConnection *c) {
//                                                       NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
//                                                   }
//                                                     progressBlock:nil];
//                
//                [connection start];
            }
            [mPlayer skipToBeginning];
        }
    } else if ((UIButton *)sender == self.fastForwardButton) {
        MPMediaItem *song = [mPlayer nowPlayingItem];
        NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", artist, @"artist", location, @"location", @"-1", @"score", nil];
        NSLog(@"%@", [parameters valueForKey:@"title"]);
        
//        FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/points"]
//                                                    method:FSNRequestMethodPOST
//                                                   headers:nil
//                                                parameters:parameters
//                                                parseBlock:nil
//                                           completionBlock:^(FSNConnection *c) {
//                                               NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
//                                           }
//                                             progressBlock:nil];
//        
//        [connection start];
        
        
        [mPlayer stop];
//        MPMediaPropertyPredicate *art = [MPMediaPropertyPredicate predicateWithValue:@"Body of Yours" forProperty:MPMediaItemPropertyTitle];
//        MPMediaQuery *artistQ = [[MPMediaQuery alloc] init];
//        [artistQ addFilterPredicate:art];
//        [mPlayer setQueueWithQuery:artistQ];
//        [mPlayer play];
    } else if ((UIButton *)sender == self.locationButton) {
        if (locationPickerView.frame.origin.y >= self.view.frame.size.height) {
            [self.view bringSubviewToFront:locationPickerView];
            NSInteger index = [locationsArray indexOfObject:location];
            [locationPickerView selectRow:index inComponent:0 animated:nil];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            locationPickerView.frame = (CGRect){{locationPickerView.frame.origin.x, self.view.frame.size.height - locationPickerView.frame.size.height}, locationPickerView.frame.size};
            [UIView commitAnimations];
        } else {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            locationPickerView.frame = (CGRect){{locationPickerView.frame.origin.x, self.view.frame.size.height}, locationPickerView.frame.size};
            [UIView commitAnimations];
        }
    }
}

- (IBAction)seekSliderDidChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [mPlayer setCurrentPlaybackTime:slider.value];
}

- (void)handleTapGesture:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (songInfoView.alpha == 0.0) {
        songInfoView.alpha = 0.8;
    } else {
        songInfoView.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)updateInformation {
    MPMediaItem *song = [mPlayer nowPlayingItem];
    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:CGSizeMake(320, 320)];
    [albumArtImageView setContentMode:UIViewContentModeScaleAspectFill];
    [albumArtImageView setImage:nil];
    [albumArtImageView setImage:image];
    
    [titleLabel setText:[song valueForProperty:MPMediaItemPropertyTitle]];
    [artistLabel setText:[song valueForProperty:MPMediaItemPropertyArtist]];
    [albumLabel setText:[song valueForProperty:MPMediaItemPropertyAlbumTitle]];
    
    NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
    [seekSlider setMaximumValue:[duration floatValue]];
}

- (void)updateSeekSlider {
    [seekSlider setValue:[mPlayer currentPlaybackTime]];
}

- (void)musicDidNavigate {
    [self updateInformation];
}

- (void)musicDidChangeState {
    if ([mPlayer playbackState] == MPMusicPlaybackStateStopped || [mPlayer playbackState] == MPMusicPlaybackStatePaused) {
        [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    } else {
        [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
    }
    
    if ([mPlayer nowPlayingItem] != nil) {
        [self updateInformation];
    }
}

- (void)viewDidUnload {
    [self setAlbumArtImageView:nil];
    [self setSongControl:nil];
    [self setArtistLabel:nil];
    [self setTitleLabel:nil];
    [self setAlbumLabel:nil];
    [self setLocationButton:nil];
    [self setSeekSlider:nil];
    [self setSongInfoView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return locationsArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [locationsArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    location = [locationsArray objectAtIndex:row];
    [locationButton setTitle:location forState:UIControlStateNormal];
    
}


@end
