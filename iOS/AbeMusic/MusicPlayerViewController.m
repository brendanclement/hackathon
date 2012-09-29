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
#import <QuartzCore/QuartzCore.h>
#import "UIDevice+IdentifierAddition.h"

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

@synthesize recommendationsView;
@synthesize recommendedArtist;
@synthesize recommendedSong;
@synthesize recommendedArray;
@synthesize recommendedTimer;
@synthesize previewPlayer;

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
        recommendedArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    currentSongIndex = 0;
    distance = 0.0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    [albumArtImageView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapPreview = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewWasTapped:)];
    tapPreview.delegate = self;
    [recommendationsView addGestureRecognizer:tapPreview];
//    [recommendedArtist addGestureRecognizer:tapPreview];
//    [recommendedSong addGestureRecognizer:tapPreview];
    
    volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(20, songControl.frame.size.height - 33, songControl.frame.size.width - 40, 20)];
     [songControl addSubview: volumeView];
    
    songQueue = [[NSMutableArray alloc] init];
    
    mPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    //[mPlayer setShuffleMode:MPMusicShuffleModeSongs];
//    MPMediaPropertyPredicate *artist = [MPMediaPropertyPredicate predicateWithValue:@"Body of Yours" forProperty:MPMediaItemPropertyTitle];
//    MPMediaQuery *artistQ = [[MPMediaQuery alloc] init];
//    [artistQ addFilterPredicate:artist];
//    [mPlayer setQueueWithQuery:artistQ];
    //^ play specific songs
    
    [self getInitialQueue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialQueueLoaded) name:@"LoadedQueue" object:nil];
    
    recommendationsView.layer.cornerRadius = 5.0f;
    [self.view bringSubviewToFront:recommendationsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialQueueLoaded {
    NSLog(@"loaded");
    [mPlayer beginGeneratingPlaybackNotifications];
    [mPlayer setQueueWithQuery:[songQueue objectAtIndex:currentSongIndex]];
    [mPlayer play];
    currentSongIndex++;
    [self updateRecommendations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidChangeState)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:mPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicDidNavigate)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:mPlayer];
    
    NSTimer *seekSliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSeekSlider) userInfo:nil repeats:YES];
    NSLog(@"%f", seekSliderTimer.timeInterval);
    [locationButton setTitle:location forState:UIControlStateNormal];
}

- (IBAction)buttonPressed:(id)sender {
    if ((UIButton *)sender == self.playPauseButton) {
        if ([mPlayer playbackState] == MPMusicPlaybackStateStopped || [mPlayer playbackState] == MPMusicPlaybackStatePaused) {
            [mPlayer play];
            [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        } else {
            [mPlayer pause];
            [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
        }
    } else if ((UIButton *)sender == self.rewindButton) {
        playedPastFortyFive = NO;
        if (mPlayer.currentPlaybackTime < 3.0) {
            if (currentSongIndex > 0) currentSongIndex-=2;
            [mPlayer stop];
            
            MPMediaQuery *nextQuery = [songQueue objectAtIndex:currentSongIndex];
            currentSongIndex++;
            [mPlayer setQueueWithQuery:nextQuery];
            [mPlayer play];
            [self getNextInQueue];
        } else {
            [mPlayer skipToBeginning];
        }
    } else if ((UIButton *)sender == self.fastForwardButton) {
        NSString *udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        MPMediaItem *song = [mPlayer nowPlayingItem];
        NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", artist, @"artist", location, @"location", @"-1", @"score", udid, @"udid", nil];
        [self updateRecommendations];
        
        FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/points"]
                                                    method:FSNRequestMethodPOST
                                                   headers:nil
                                                parameters:parameters
                                                parseBlock:^id(FSNConnection *c, NSError **error) {
                                                    return [c.responseData dictionaryFromJSONWithError:error];
                                                }
                                           completionBlock:^(FSNConnection *c) {
                                               NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
                                           }
                                             progressBlock:nil];
        
        [connection start];
        
        [mPlayer stop];
        playedPastFortyFive = NO;
        
        MPMediaQuery *nextQuery = [songQueue objectAtIndex:currentSongIndex];
        currentSongIndex++;
        [mPlayer setQueueWithQuery:nextQuery];
        [mPlayer play];
        [self getNextInQueue];
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
    } else if ((UIButton *)sender == self.recommendedPlayButton) {
        if (previewPlayer != nil) {
            if ([previewPlayer isPlaying]) {
                [previewPlayer pause];
                [self.recommendedPlayButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
            } else {
                [previewPlayer play];
                [self.recommendedPlayButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
            }
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
    [self.view bringSubviewToFront:songControl];
    
    [titleLabel setText:[song valueForProperty:MPMediaItemPropertyTitle]];
    [artistLabel setText:[song valueForProperty:MPMediaItemPropertyArtist]];
    [albumLabel setText:[song valueForProperty:MPMediaItemPropertyAlbumTitle]];
    
    NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
    [seekSlider setMaximumValue:[duration floatValue]];
}

- (void)updateSeekSlider {
    [seekSlider setValue:[mPlayer currentPlaybackTime]];
    MPMediaItem *song = [mPlayer nowPlayingItem];
    if (!playedPastFortyFive && [mPlayer currentPlaybackTime] >= 30.0) {
        song = [mPlayer nowPlayingItem];
        NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
        NSString *udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", artist, @"artist", location, @"location", @"+1", @"score", udid, @"udid", nil];
        [self updateRecommendations];
        
        FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/points"]
                                                    method:FSNRequestMethodPOST
                                                   headers:nil
                                                parameters:parameters
                                                parseBlock:^id(FSNConnection *c, NSError **error) {
                                                    return [c.responseData dictionaryFromJSONWithError:error];
                                                }
                                           completionBlock:^(FSNConnection *c) {
                                               NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
                                           }
                                             progressBlock:nil];
        
        [connection start];
        playedPastFortyFive = YES;
    }
    NSNumber *duration = [song valueForProperty:MPMediaItemPropertyPlaybackDuration];
    if ([mPlayer currentPlaybackTime] >= [duration floatValue] - 1 && song != nil ) {
        [mPlayer stop];
        playedPastFortyFive = NO;
        
        MPMediaQuery *nextQuery = [songQueue objectAtIndex:currentSongIndex];
        currentSongIndex++;
        [mPlayer setQueueWithQuery:nextQuery];
        [mPlayer play];
        [self getNextInQueue];
    }
}

- (void)musicDidNavigate {
    [self updateInformation];
}

- (void)musicDidChangeState {
    if ([mPlayer playbackState] == MPMusicPlaybackStateStopped || [mPlayer playbackState] == MPMusicPlaybackStatePaused) {
        [playPauseButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    } else {
        [playPauseButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        [self updateInformation];
    }
}

- (void)getInitialQueue {
    NSString *udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:location, @"location", udid, @"udid", @"2", @"number", [NSString stringWithFormat:@"%f",distance], @"distance", nil];
    __block NSArray *initialQueue = [[NSArray alloc] init];
    
    FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/getSong"]
                                                method:FSNRequestMethodPOST
                                               headers:nil
                                            parameters:parameters
                                            parseBlock:^id(FSNConnection *c, NSError **error) {
                                                return [c.responseData dictionaryFromJSONWithError:error];
                                            }
                                       completionBlock:^(FSNConnection *c) {
                                           NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
                                           NSDictionary *dict = (NSDictionary *)c.parseResult;
                                           initialQueue = [dict objectForKey:@"songs"];
                                           
                                           for (int i = 0; i < 2; i++) {
                                               NSDictionary *song = [initialQueue objectAtIndex:i];
                                               //MPMediaPropertyPredicate *artist = [MPMediaPropertyPredicate predicateWithValue:[[song valueForKey:@"artist"] capitalizedString] forProperty:MPMediaItemPropertyArtist];
                                               MPMediaPropertyPredicate *songTitle = [MPMediaPropertyPredicate predicateWithValue:[[song valueForKey:@"title"] capitalizedString] forProperty:MPMediaItemPropertyTitle];
                                               MPMediaQuery *query = [[MPMediaQuery alloc] init];
                                               //[query addFilterPredicate:artist];
                                               [query addFilterPredicate:songTitle];
                                               [songQueue addObject:query];
                                               
                                               if (i == 0) distance = [[song objectForKey:@"distance"] floatValue];
                                               else {
                                                   if ([[song objectForKey:@"distance"] floatValue] > distance) distance = [[song objectForKey:@"distance"] floatValue];
                                               }
                                           }
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedQueue" object:nil];
                                       }
                                         progressBlock:nil];
    
    [connection start];
    
    //PULL FROM SERVER
    //songOne = [NSDictionary dictionaryWithObjectsAndKeys:@"simply simple", @"title", @"mother mother", @"artist", nil];
    //songTwo = [NSDictionary dictionaryWithObjectsAndKeys:@"pumped up kicks", @"title", @"foster the people", @"artist", nil];
    //initialQueue = [NSArray arrayWithObjects:songOne, songTwo, nil];
    
    
}

- (void)getNextInQueue {
    NSString *udid = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:location, @"location", udid, @"udid", @"1", @"number", [NSString stringWithFormat:@"%f",distance], @"distance", nil];
    FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/getSong"]
                                                method:FSNRequestMethodPOST
                                               headers:nil
                                            parameters:parameters
                                            parseBlock:^id(FSNConnection *c, NSError **error) {
                                                return [c.responseData dictionaryFromJSONWithError:error];
                                            }
                                       completionBlock:^(FSNConnection *c) {
                                           NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
                                           NSDictionary *dict = (NSDictionary *)c.parseResult;
                                           NSArray *queue = [dict objectForKey:@"songs"];
                                           NSDictionary *song = [queue objectAtIndex:0];
                                           //MPMediaPropertyPredicate *artist = [MPMediaPropertyPredicate predicateWithValue:[[song valueForKey:@"artist"] capitalizedString] forProperty:MPMediaItemPropertyArtist];
                                           MPMediaPropertyPredicate *songTitle = [MPMediaPropertyPredicate predicateWithValue:[[song valueForKey:@"title"] capitalizedString] forProperty:MPMediaItemPropertyTitle];
                                           MPMediaQuery *query = [[MPMediaQuery alloc] init];
                                           //[query addFilterPredicate:artist];
                                           [query addFilterPredicate:songTitle];
                                           NSLog(@"%@", [song valueForKey:@"title"]);
                                           if (currentSongIndex == songQueue.count) [songQueue addObject:query];
                                           else [songQueue replaceObjectAtIndex:currentSongIndex withObject:query];
                                           distance = [[song objectForKey:@"distance"] floatValue];
                                       }
                                         progressBlock:nil];
    
    [connection start];
    
    //PULL FROM SERVER
    
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
    [self setRecommendedPlayButton:nil];
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

- (void)updateRecommendations {
    [recommendedTimer invalidate];
    recommendedTimer = nil;
    [recommendedArray removeAllObjects];
    
//    MPMediaItem *song = [mPlayer nowPlayingItem];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[song valueForKey:@"song"], @"title", [song valueForKey:@"artist"], @"artist", nil];
//    FSNConnection *connection = [FSNConnection withUrl:[NSURL URLWithString:@"http://abemusic.elasticbeanstalk.com/index.php/music/getRecommendations"]
//                                                method:FSNRequestMethodPOST
//                                               headers:nil
//                                            parameters:parameters
//                                            parseBlock:^id(FSNConnection *c, NSError **error) {
//                                                return [c.responseData dictionaryFromJSONWithError:error];
//                                            }
//                                       completionBlock:^(FSNConnection *c) {
//                                           NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
//                                           NSDictionary *dict = (NSDictionary *)c.parseResult;
//                                           NSArray *queue = [dict objectForKey:@"songs"];
//                                           
//                                           for (int i = 0; i < queue.count; i++) {
//                                               NSDictionary *song = [queue objectAtIndex:i];
//                                               NSString *searchURL = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@+%@&entity=song", [song valueForKey:@"artist"], [song valueForKey:@"song"]];
//                                               NSError *err;
//                                               NSData *searchData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]];
//                                               NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData options:NSJSONWritingPrettyPrinted error:&err];
//                                               NSArray *results = [searchDict objectForKey:@"results"];
//                                               NSDictionary *previewSong = [results objectAtIndex:0];
//                                               NSDictionary *dictionaryToAdd = [NSDictionary dictionaryWithObjectsAndKeys:[previewSong objectForKey:@"artistName"], @"artist", [previewSong objectForKey:@"trackName"], @"song", [previewSong objectForKey:@"previewUrl"], @"previewURL", nil];
//                                               if (i < recommendedArray.count - 1) [recommendedArray replaceObjectAtIndex:i withObject:dictionaryToAdd];
//                                               else [recommendedArray addObject:dictionaryToAdd];
//                                           }
//                                       }
//                                         progressBlock:nil];
//    
//    [connection start];
    
    //pull from server, return an array or dicts
    //CHECK INTERNET
    NSDictionary *songOne = [NSDictionary dictionaryWithObjectsAndKeys:@"Body+of+Years", @"song", @"Mother+Mother", @"artist", nil];
    NSDictionary *songTwo = [NSDictionary dictionaryWithObjectsAndKeys:@"the+cave", @"song", @"mumford+sons", @"artist", nil];
    NSDictionary *songThree = [NSDictionary dictionaryWithObjectsAndKeys:@"12+fingers", @"song", @"young+the+giant", @"artist", nil];
    NSArray *pulledArray = [NSArray arrayWithObjects:songOne, songTwo, songThree, nil];
    
    for (int i = 0; i < pulledArray.count; i++) {
        NSDictionary *pulledSong = [pulledArray objectAtIndex:i];
        NSString *searchURL = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@+%@&entity=song", [pulledSong valueForKey:@"artist"], [pulledSong valueForKey:@"song"]];
        NSError *err;
        NSData *searchData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]];
        NSDictionary *searchDict = [NSJSONSerialization JSONObjectWithData:searchData options:NSJSONWritingPrettyPrinted error:&err];
        NSArray *results = [searchDict objectForKey:@"results"];
        NSDictionary *previewSong = [results objectAtIndex:0];
        NSDictionary *dictionaryToAdd = [NSDictionary dictionaryWithObjectsAndKeys:[previewSong objectForKey:@"artistName"], @"artist", [previewSong objectForKey:@"trackName"], @"song", [previewSong objectForKey:@"previewUrl"], @"previewURL", nil];
        [recommendedArray addObject:dictionaryToAdd];
    }
    
    recommendedIndex = recommendedArray.count - 1;
    [self scrollRecommendations];
    recommendedTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrollRecommendations) userInfo:nil repeats:YES];
}

- (void)scrollRecommendations {
    if (recommendedIndex >= recommendedArray.count - 1) recommendedIndex = 0;
    else recommendedIndex++;
    
    NSDictionary *song = [recommendedArray objectAtIndex:recommendedIndex];
    [UIView animateWithDuration:0.4 animations:^(void) {
        [recommendedArtist setAlpha:0.0];
        [recommendedSong setAlpha:0.0];
    } completion:^(BOOL finished) {
        [recommendedArtist setText:[song valueForKey:@"artist"]];
        [recommendedSong setText:[song valueForKey:@"song"]];
        [UIView animateWithDuration:0.4 animations:^(void) {
            [recommendedArtist setAlpha:1.0];
            [recommendedSong setAlpha:1.0];
        }];
    }];
}

- (void)previewWasTapped:(id)sender {
    [UIView animateWithDuration:0.1 animations:^(void) {
        if (!recommendationsAreUp) {
            recommendationsView.frame = (CGRect){recommendationsView.frame.origin, {recommendationsView.frame.size.width, recommendationsView.frame.size.height + 42}};
        }
        else {
            recommendationsView.frame = (CGRect){{recommendationsView.frame.origin.x, self.view.frame.size.height - 38}, recommendationsView.frame.size};
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            if (!recommendationsAreUp) {
                recommendationsView.frame = (CGRect){{recommendationsView.frame.origin.x, self.view.frame.size.height / 2 - recommendationsView.frame.size.height / 2}, recommendationsView.frame.size};
                recommendationsAreUp = YES;
                [mPlayer pause];
                
                NSDictionary *songtoPlay = [recommendedArray objectAtIndex:recommendedIndex];
                NSError *err;
                NSData *songData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[songtoPlay valueForKey:@"previewURL"]]];
                previewPlayer = [[AVAudioPlayer alloc] initWithData:songData error:&err];
                [previewPlayer play];
                [recommendedTimer invalidate];
                recommendedTimer = nil;
            }
            else {
                recommendationsView.frame = (CGRect){recommendationsView.frame.origin, {recommendationsView.frame.size.width, 38}};
                recommendationsAreUp = NO;
                [previewPlayer stop];
                previewPlayer = nil;
                [mPlayer play];
                recommendedTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrollRecommendations) userInfo:nil repeats:YES];
            }
        }];
    }];
}

@end
