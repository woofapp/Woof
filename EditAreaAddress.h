//
//  EditAreaAddress.h
//  Woof
//
//  Created by Mattia Campana on 04/02/13.
//  Copyright (c) 2013 nikotia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Area.h"

@interface EditAreaAddress : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocation *searchedLocation;
@property (retain, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) IBOutlet CLGeocoder *geoCoder;
@property (weak, nonatomic) IBOutlet UITextField *addressTextView;

@property (weak, nonatomic) IBOutlet UIView *messageBackground;
@property (retain, nonatomic) Area *area;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


- (IBAction)currentLocationClicked:(id)sender;
- (IBAction)backToAreaDetails:(id)sender;
- (IBAction)goToHome:(id)sender;
- (IBAction)sendAddress:(id)sender;

@end
