//
//  ViewController.m
//  PeerReview4
//
//  Created by user01 on 09.09.16.
//  Copyright © 2016 user01. All rights reserved.
//

#import "ViewController.h"
#import "DistanceGetter/DGDistanceRequest.h"



@interface ViewController ()

@property (nonatomic) DGDistanceRequest* req;
@property (nonatomic) NSArray* res;

@property (weak, nonatomic) IBOutlet UITextField *startingLocation;

@property (weak, nonatomic) IBOutlet UISegmentedControl *measurementSelector;

@property (weak, nonatomic) IBOutlet UITextField *endLocationA;
@property (weak, nonatomic) IBOutlet UITextField *endLoactionB;
@property (weak, nonatomic) IBOutlet UITextField *endLoactionC;
@property (weak, nonatomic) IBOutlet UITextField *endLocationD;

@property (weak, nonatomic) IBOutlet UILabel *distanceA;
@property (weak, nonatomic) IBOutlet UILabel *distanceB;
@property (weak, nonatomic) IBOutlet UILabel *distanceC;
@property (weak, nonatomic) IBOutlet UILabel *distanceD;

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;

@end

@implementation ViewController
- (IBAction)calculateButtonTapped:(id)sender {
    self.calculateButton.enabled = NO;
    self.measurementSelector.enabled = NO;
    NSArray* locationDescription = @[self.endLocationA.text,
                                     self.endLoactionB.text,
                                     self.endLoactionC.text,
                                     self.endLocationD.text];
    NSString* sourceDescription = self.startingLocation.text;
    self.req = [[DGDistanceRequest alloc] initWithLocationDescriptions:locationDescription sourceDescription:sourceDescription];
    
    __weak ViewController *weakSelf = self;
    self.req.callback = ^(NSArray *distances){
        ViewController* strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        
        // save to use when new scale selected
        strongSelf.res = distances;
        
        assert(distances.count == locationDescription.count);
        [strongSelf updateDistanceValues:distances];
        strongSelf.calculateButton.enabled = YES;
        strongSelf.measurementSelector.enabled = YES;
    };
    
    [self.req start];   
}
- (IBAction)onScaleChange:(id)sender {
    if (self.res) {
        [self updateDistanceValues:self.res];
    }
}

- (void) updateDistanceValues:(NSArray*) res
{
    [self updateDistanceValueInLabel:self.distanceA ByRequestResult:res[0]];
    [self updateDistanceValueInLabel:self.distanceB ByRequestResult:res[1]];
    [self updateDistanceValueInLabel:self.distanceC ByRequestResult:res[2]];
    [self updateDistanceValueInLabel:self.distanceD ByRequestResult:res[3]];
}

- (void) updateDistanceValueInLabel:(UILabel*) distanceLabel ByRequestResult:(id) res{
    NSNull* badResult = [NSNull null];
    if (res == badResult) {
        distanceLabel.text = @"Unknown location";
        return;
    }
    double resNumber = [res floatValue];
    NSString* printingValue;
    switch (self.measurementSelector.selectedSegmentIndex) {
        case 0:
            printingValue = [NSString stringWithFormat:@"%.2f Meters", resNumber];
            break;
        case 1:
            printingValue = [NSString stringWithFormat:@"%.2f Kilometers", resNumber / 1000.0];
            break;
        case 2:
            printingValue = [NSString stringWithFormat:@"%.2f Miles", resNumber * 0.000621371];
            break;
        default:
            printingValue = @"";
            break;
    }
    distanceLabel.text = printingValue;
}

@end
