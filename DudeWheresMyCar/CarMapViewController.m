//
//  ViewController.m
//  DudeWheresMyCar
//
//  Created by Gregory Weiss on 8/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

#import "CarMapViewController.h"
#import "AppDelegate.h"
#import "CarItem.h"
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@import CoreLocation;

@interface CarMapViewController () <CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *annotations;
@property(strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSManagedObjectContext *moc;

@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@property (strong, nonatomic) NSMutableArray *carItems;
@property (strong, nonatomic) CarItem *aCarItem;


@end

@implementation CarMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.carItems = [[NSMutableArray alloc] init];
    self.annotations = [[NSMutableArray alloc] init];
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.moc = appDelegate.managedObjectContext;
    
    // This block will fetch our counter objects from Core Data and load them in the tableView
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([CarItem class])];
    NSError *error = nil;
    NSArray *carItemsFromCoreData = [self.moc executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"Could not fetch from moc: %@", [error localizedDescription]);
    }
    else
    {
        [self.carItems addObjectsFromArray:carItemsFromCoreData];
        
        
//        CarItem *firstCarItem = self.carItems[0];
//        double firstLat = firstCarItem.carLocationLat;
//        double firstLong = firstCarItem.carLocationLong;
//        CLLocationCoordinate2D theCarWasParkedHere = CLLocationCoordinate2DMake(firstLat, firstLong);
//        MKPointAnnotation *carHereAnnotation = [[MKPointAnnotation alloc] init];
//        carHereAnnotation.coordinate = theCarWasParkedHere;
//        carHereAnnotation.title = firstCarItem.carLocationDescription;
//        [self.mapView addAnnotation:carHereAnnotation];
    }
   // [self configureLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureAnnotations
{
  /*
    // TAMPA
    CLLocationCoordinate2D tiyTampa = CLLocationCoordinate2DMake(27.770068, -82.63642);
    // 0 lat is equator north is pos, south is neg
    // 0 long greeninch england west is neg, east is pos of England
    MKPointAnnotation *tiyTampaAnnotation = [[MKPointAnnotation alloc] init];
    tiyTampaAnnotation.coordinate = tiyTampa;
    tiyTampaAnnotation.title = @"The Iron Yard";
    tiyTampaAnnotation.subtitle = @"Tampa";
    [self.annotations addObject:tiyTampaAnnotation];
   */
    
    
    // LAKELAND
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"Orlando, FL" completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            MKPlacemark *placemark = placemarks[0];
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = placemark.location.coordinate; // Using this later as a center point
            annotation.title = @"Center of Town";
       //     [self.mapView addAnnotation:annotation]; // runs in background with network call
            
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5000, 5000);
            [self.mapView setRegion:viewRegion animated:YES];
            
        }
    }];
    
    // ORLANDO configured in bottom method
    
    
    
    
    [self.mapView addAnnotations:self.annotations];
    
}



#pragma mark - CLLocation related methods

-(void)configureLocationManager
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)
    {
        if (!self.locationManager)
        {
            self.locationManager = [[CLLocationManager alloc] init]; // need one to exist to even ask permission!!
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
            {
                // Don't forget to add the reason to the info.plist
                [self.locationManager requestWhenInUseAuthorization];
            }
        }
        
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self enableLocationManager:YES];
    }
    else
    {
        [self enableLocationManager:NO];
    }
}

-(void)enableLocationManager:(BOOL)enable
{
    if (self.locationManager)
    {
        // good practice to stop locationManager first then start
        [self.locationManager stopUpdatingLocation];
        
        if (enable)
        {
            [self.locationManager startUpdatingLocation];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error

{
    if (error != kCLErrorLocationUnknown)
    {
        [self enableLocationManager:NO];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    [self enableLocationManager:NO];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    //CarItem *newCarItem = [[CarItem alloc] init];
//    self.aCarItem.carLocationLat = location.coordinate.latitude;
//    self.aCarItem.carLocationLong = location.coordinate.longitude;
//    [self saveContext];
    annotation.coordinate = location.coordinate;
    annotation.title = @"Here is your car!!";
  //  self.aCarItem.carLocationDescription = annotation.title;
    [self.annotations addObject:annotation];
    
    [self configureAnnotations]; // This just makes hard coded
}

#pragma mark - Search bar method

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // called when keyboard search button pressed
    [self configureLocationManager];
    
    if ([self.mySearchBar.text  isEqual: @""])
    {
        return;
    }
    
    self.aCarItem = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass([CarItem class]) inManagedObjectContext:self.moc];
    self.aCarItem.carLocationDescription = self.mySearchBar.text;
    //aCarItem.carLocationLat =
    //CLLocation *location =
   // [self.carItems addObject:aCarItem];
    [self saveContext];
    [self doSearch:self.mySearchBar.text];
}

#pragma mark - Using api inside of a custom search method

-(void)doSearch:(NSString *)descriptionForCar
{
    [self.mySearchBar resignFirstResponder];
 //   CarItem *aCarItem = self.
  //  NSLog([NSString stringWithFormat:@"%@", descriptionForCar]);
   // APIController *apiController = [APIController sharedAPIController];
   // apiController.delegate = self;
   // [apiController searchForCharacter:searchThisMarvel];
    self.mySearchBar.text = @"";
    
}

#pragma mark - Cancel button to resign typing

// MAYBE use this. NEEDS TO BE HOOKED UP TO A NEW BUTTON!!!

- (IBAction)plusTapped:(UIBarButtonItem *)sender
{
    [self configureLocationManager];
    self.aCarItem = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass([CarItem class]) inManagedObjectContext:self.moc];
    self.aCarItem.carLocationLat = self.locationManager.location.coordinate.latitude;
    self.aCarItem.carLocationLong = self.locationManager.location.coordinate.longitude;
    [self saveContext];
    //[self.mySearchBar resignFirstResponder];
    //self.mySearchBar.text = @"";
}


#pragma mark - misc

- (void)saveContext
{
    NSError *error = nil;
    [self.moc save:&error];
    if (error)
    {
        NSLog(@"Error saving moc: %@", [error localizedDescription]);
    }
    
}



@end
