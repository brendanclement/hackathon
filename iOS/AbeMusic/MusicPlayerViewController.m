//
//  MusicPlayerViewController.m
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayerViewController ()

@end

@implementation MusicPlayerViewController

@synthesize location;
@synthesize mPlayer;

@synthesize playPauseButton;
@synthesize rewindButton;
@synthesize fastForwardButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    mPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidChangeState)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:mPlayer];
    
    [mPlayer beginGeneratingPlaybackNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)buttonPressed:(id)sender {
    if ((UIButton *)sender == self.playPauseButton) {
        if ([mPlayer playbackState] == MPMusicPlaybackStateStopped || [mPlayer playbackState] == MPMusicPlaybackStatePaused) {
            [mPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
            [mPlayer play];
            //[playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        } else {
            [mPlayer stop];
            //[playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
        }
    } else if ((UIButton *)sender == self.rewindButton) {
        NSLog(@"rewind");
    } else if ((UIButton *)sender == self.fastForwardButton) {
        NSLog(@"ff");
    }
}

- (void)musicDidChangeState {
    NSLog(@"NO");
    if ([mPlayer playbackState] == MPMusicPlaybackStateStopped || [mPlayer playbackState] == MPMusicPlaybackStatePaused) {
        [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
    } else {
        [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    }
}

@end
