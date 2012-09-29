//
//  MusicPlayerViewController.h
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MusicPlayerViewController : UIViewController <UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (nonatomic, weak) IBOutlet UIButton *rewindButton;
@property (nonatomic, weak) IBOutlet UIButton *fastForwardButton;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (weak, nonatomic) IBOutlet UIView *songControl;

@property (weak, nonatomic) IBOutlet UIView *songInfoView;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UISlider *seekSlider;

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSMutableArray *songQueue;
@property (nonatomic, strong) MPMusicPlayerController *mPlayer;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) NSArray *locationsArray;

@property (nonatomic, weak) IBOutlet UIPickerView *locationPickerView;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)seekSliderDidChange:(id)sender;
- (void)handleTapGesture:(id)sender;

- (void)musicDidNavigate;
- (void)musicDidChangeState;

@end
