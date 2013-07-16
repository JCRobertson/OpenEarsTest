//
//  ViewController.h
//  OpenEarsTest
//
//  Created by James Robertson on 6/17/13.
//  Copyright (c) 2013 James Robertson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/OpenEarsEventsObserver.h>


@interface VoiceViewController : UIViewController <OpenEarsEventsObserverDelegate>{
    OpenEarsEventsObserver *openEarsEventsObserver;
}
- (IBAction)speak:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *addressField;
@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) IBOutlet UIButton *speakButton;
@property NSString *lmPath;
@property NSString *dicPath;
@property Boolean isOn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *wheel;

@end
