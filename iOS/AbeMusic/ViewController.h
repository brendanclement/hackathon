//
//  ViewController.h
//  AbeMusic
//
//  Created by Noel Feliciano on 2012-09-28.
//  Copyright (c) 2012 Noel Feliciano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    UIButton *buttonPressed;
}

@property (nonatomic, strong) NSMutableArray *allSongs;
@property (nonatomic, strong) NSData *json;

- (IBAction)buttonPressed:(id)sender;

@end
