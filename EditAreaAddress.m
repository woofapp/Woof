//
//  EditAreaAddress.m
//  Woof
//
//  Created by Mattia Campana on 04/02/13.
//  Copyright (c) 2013 nikotia. All rights reserved.
//

#import "EditAreaAddress.h"
#import "SearchedLocationPoint.h"
#import "UIEffects.h"

@interface EditAreaAddress ()

@end

@implementation EditAreaAddress

@synthesize mapView, addressTextView, messageBackground, titleLabel;
@synthesize searchedLocation,userLocation, geoCoder, area;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [mapView.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    
    geoCoder = [[CLGeocoder alloc] init];
    
    [mapView addAnnotation:area];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideMessage) userInfo:nil repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPin:)];
    [recognizer setNumberOfTapsRequired:1];
    [mapView addGestureRecognizer:recognizer];
    
    [titleLabel setFont:[UIFont fontWithName:@"Opificio" size:20]];
    messageBackground.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(self.userLocation == NULL || [userLocation distanceFromLocation:mapView.userLocation.location] >= 500){
        userLocation = mapView.userLocation.location;
        [self mapZoomInLocation:userLocation];
        [mapView.userLocation removeObserver:self forKeyPath:@"location"];
    }
}

- (void) mapZoomInLocation: (CLLocation *)location{
    MKCoordinateRegion region;
    region.center = location.coordinate;
    
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.001;
    span.longitudeDelta = 0.001;
    region.span = span;
    
    [mapView setRegion:region animated:YES];
}

- (void)addPin:(UITapGestureRecognizer*)recognizer
{
    CGPoint tappedPoint = [recognizer locationInView:mapView];
    CLLocationCoordinate2D coord= [mapView convertPoint:tappedPoint toCoordinateFromView:mapView];
    
    SearchedLocationPoint *slp = [[SearchedLocationPoint alloc]init];
    slp.coordinate = coord;
    
    NSArray *annotations = [mapView annotations];
    for(int i=0; i<[annotations count]; i++){
        NSLog(@"TIT: %@",[annotations[i] title]);
        if([annotations[i] isKindOfClass:[SearchedLocationPoint class]] && ![annotations[i] isKindOfClass:[Area class]]){
            [mapView removeAnnotation:annotations[i]];
        }
    }
    
    searchedLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    
    
    NSArray *ann = [[NSArray alloc]initWithObjects:area,slp, nil];
    [mapView addAnnotations:ann];
    
    //[mapView addAnnotation:slp];
    //[mapView addAnnotation:area];
    
    [self getAddressFromLocation:searchedLocation];
    area.coordinate = coord;
}


/*
 * REVERSE GEOCODING
 */

-(void) getAddressFromLocation: (CLLocation *)location{
    
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        //ottieni l'indirizzo più vicino
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        //String to hold address
        NSString *address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        addressTextView.text = address;
    }];
}

-(void)hideMessage{
    [UIEffects fadeOut:messageBackground withDuration:2 andWait:0];
}

- (IBAction)currentLocationClicked:(id)sender {
    
    //Rimuovo ipotetici pin
    NSArray *annotations = [mapView annotations];
    for(int i=0; i<[annotations count]; i++){
        if([annotations[i] isKindOfClass:[SearchedLocationPoint class]]){
            SearchedLocationPoint *slp2 = annotations[i];
            [mapView removeAnnotation:slp2];
        }
    }
    
    [self mapZoomInLocation:userLocation];
    [self getAddressFromLocation:userLocation];
}


- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[Area class]]) {
        
        NSLog(@"AREA");
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"searchedPoint"];
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;
        annotationView.image=[UIImage imageNamed:@"mypos_overlay@2.png"];
        
        return annotationView;
        
    }else if([annotation isKindOfClass:[SearchedLocationPoint class]]){
        
        NSLog(@"SEARCHED LOCATION POINT");
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"searchedPoint"];
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;
        annotationView.image=[UIImage imageNamed:@"area_overlay@2.png"];
        
        return annotationView;
        
    }
    
    return nil;
}



- (IBAction)backToAreaDetails:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)sendAddress:(id)sender {
    if([addressTextView.text length] == 0){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Devi prima selezionare una posizione!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"La posizione selezionata è corretta?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"SI",nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"SI"]){
        
        //Invia address
        NSLog(@"Invia indirizzo.");
    }
}

@end
