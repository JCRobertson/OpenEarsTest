//
//  ViewController.m
//  OpenEarsTest
//
//  Created by James Robertson on 6/17/13.
//  Copyright (c) 2013 James Robertson. All rights reserved.
//

#import "VoiceViewController.h"

@interface VoiceViewController ()

@end

@implementation VoiceViewController

@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize addressField;
@synthesize lmPath;
@synthesize dicPath;
@synthesize isOn;
@synthesize speakButton;
@synthesize wheel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSArray *words = [NSArray arrayWithObjects:@"6", @"0", @"1", @"2", @"3", @"4", @"5", @"100", /*For some reason 6 has to be listed twice to work....*/@"6", @"7", @"8", @"9", @"Alexandria", @"Street", @"Avenue", @"Boulevard", @"Road", @"Virginia", @"Main", @"Maple", @"Elm", @"Pennsylvania", @"North", @"West", @"Washington", @"DC", @"Oak", @"Cedar", @"City", @"Fairfax", @"Chantilly", @"Maryland", @"Vienna", @"Address", nil];
    NSString *name = @"Addresses";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name];
    
    
    NSDictionary *languageGeneratorResults = nil;
	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        self.lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    isOn = FALSE;

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)speak:(id)sender {
    NSLog(@"Button Press");
    if(!isOn){
        [wheel setHidden:FALSE];
        self.addressField.text = @"Loading...";
        NSLog(@"Button Text: %@", self.speakButton.titleLabel.text);
        isOn = TRUE;
        self.speakButton.userInteractionEnabled = FALSE;
        [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.lmPath dictionaryAtPath:dicPath languageModelIsJSGF:NO];
        [self.openEarsEventsObserver setDelegate:self];
    }
    else{
        isOn = FALSE;
        self.addressField.text = @"";
        [self.pocketsphinxController  stopListening];
        self.speakButton.titleLabel.text = @"Start Listening";

    }
}

- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    self.addressField.text = @"";
    [self.wheel setHidden:FALSE];
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if ([hypothesis rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
                
        NSString *numberString;
        
        NSScanner *scanner = [NSScanner scannerWithString:hypothesis];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 "];
        hypothesis = [[hypothesis componentsSeparatedByCharactersInSet: [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
        NSLog(@"The received hypothesis is %@" , hypothesis);


        //Throw away characters before the first number.
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
         NSLog(@"The received hypothesis is %@" , hypothesis);
        //Collect numbers.
        [scanner scanCharactersFromSet:numbers intoString:&numberString];
         NSLog(@"The received hypothesis is %@" , hypothesis);
        //Remove Spaces
        numberString = [numberString stringByReplacingOccurrencesOfString:@" " withString:@""];
         NSLog(@"The received hypothesis is %@" , hypothesis);
        hypothesis = [hypothesis substringFromIndex:[numberString length]+1];
         NSLog(@"The received hypothesis is %@" , hypothesis);
        hypothesis = [numberString stringByAppendingString:hypothesis];
    }
    self.addressField.text = [self.addressField.text stringByAppendingString:hypothesis];
    [self.pocketsphinxController  stopListening];
    [self.wheel setHidden:TRUE];
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
    self.speakButton.titleLabel.text = @"Loading...";
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
    [wheel setHidden:TRUE];
    self.speakButton.titleLabel.text = @"Stop Listening";
    self.addressField.text = @"Speak Now";
    self.speakButton.userInteractionEnabled = TRUE;
}

- (void) pocketsphinxDidDetectSpeech {
    self.addressField.text = @"Listening...";
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
    isOn = FALSE;
    self.speakButton.titleLabel.text = @"Start Listening";
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
@end
