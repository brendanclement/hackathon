//
//  MusicPlayerViewController.h
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (nonatomic, weak) IBOutlet UIButton *rewindButton;
@property (nonatomic, weak) IBOutlet UIButton *fastForwardButton;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView;

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSMutableArray *songQueue;
@property (nonatomic, strong) MPMusicPlayerController *mPlayer;
@property (nonatomic, strong) MPVolumeView *volumeView;

- (IBAction)buttonPressed:(id)sender;

- (void)musicDidNavigate;
- (void)musicDidChangeState;

@end
