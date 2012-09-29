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
@synthesize songQueue;
@synthesize mPlayer;
@synthesize volumeView;

@synthesize playPauseButton;
@synthesize rewindButton;
@synthesize fastForwardButton;
@synthesize albumArtImageView;
@synthesize songControl;

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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /*volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(20, songControl.frame.size.height - 40, songControl.frame.size.width - 40, 20)];
     [songControl addSubview: volumeView];*/
    
    songQueue = [[NSMutableArray alloc] init];
    
    mPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [mPlayer setShuffleMode:MPMusicShuffleModeSongs];
    [mPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidChangeState)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidNavigate)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
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
            [mPlayer play];
        } else {
            [mPlayer pause];
        }
    } else if ((UIButton *)sender == self.rewindButton) {
        if (mPlayer.currentPlaybackTime < 3.0) {
            [mPlayer skipToPreviousItem];
        } else {
            [mPlayer skipToBeginning];
        }
    } else if ((UIButton *)sender == self.fastForwardButton) {
        [mPlayer skipToNextItem];
    }
}

- (void)updateInformation {
    MPMediaItem *song = [mPlayer nowPlayingItem];
    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:CGSizeMake(320, 320)];
    [albumArtImageView setContentMode:UIViewContentModeScaleAspectFill];
    [albumArtImageView setImage:nil];
    [albumArtImageView setImage:image];
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
    [super viewDidUnload];
}
@end
