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
    
    //[self configureLocationManager];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.moc = appDelegate.managedObjectContext;
    
    // This block will fetch our counter objects from Core Data and load them in the tableView
  //  if (self.plusCount > 0)
 //   {
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
        
        
        
//  ********************THIS PART HAS PROBLEMS! SEEMS LIKE I DON"T NEED< BUT CORE DATA NOT STORING!!***************
        
        if (self.carItems.count != 0)
        {
            
            self.aCarItem = self.carItems[0];
            [self configureAnnotations];
            NSLog(@"%g carLat", self.aCarItem.carLocationLat);
            NSLog(@"%g carLong", self.aCarItem.carLocationLong);
            
        }
        
        
    }
   // [self configureLocationManager];
  //  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureAnnotations
{
      // ORLANDO configured in bottom method
    CLLocationCoordinate2D carCoordnts = CLLocationCoordinate2DMake(self.aCarItem.carLocationLat, self.aCarItem.carLocationLong);
    // 0 lat is equator north is pos, south is neg
    // 0 long greeninch england west is neg, east is pos of England
    MKPointAnnotation *thisIsMyCarAnnotation = [[MKPointAnnotation alloc] init];
    thisIsMyCarAnnotation.coordinate = carCoordnts;
    thisIsMyCarAnnotation.title = self.aCarItem.carLocationDescription;
    [self.annotations addObject:thisIsMyCarAnnotation];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(thisIsMyCarAnnotation.coordinate, 5000, 5000);
    [self.mapView setRegion:viewRegion animated:YES];
    
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
//    UIView *aview = [location superview];      // CAN"T SEEM TO FIGURE OUT SUPERVIEW STUFF!!!!!
//    MKMapView *aMapView = [aview superview];
//    self.aCarItem = (CarItem *)[self.mapView superview];
    self.aCarItem.carLocationLat = location.coordinate.latitude;
    self.aCarItem.carLocationLong = location.coordinate.longitude;
    annotation.coordinate = location.coordinate;
    annotation.title = @"Here is your car!!";
    self.aCarItem.carLocationDescription = annotation.title;
    [self.carItems addObject:self.aCarItem];
    
    [self.annotations addObject:annotation];
    [self saveContext];
    [self configureAnnotations]; // This just makes hard coded
}

#pragma mark - Search bar method  // DECIDED NOT TO USE SEARCH BAR, TOO MUCH ELSE NOT WORKING!!!!!!

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // called when keyboard search button pressed
  //  [self configureLocationManager];
    
    if ([self.mySearchBar.text  isEqual: @""])
    {
        return;
    }
    
  //  self.aCarItem = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass([CarItem class]) inManagedObjectContext:self.moc];
  //  self.aCarItem.carLocationDescription = self.mySearchBar.text;
    //aCarItem.carLocationLat =
   // CLLocation *location =
   //[self.carItems addObject:aCarItem];
  //  [self saveContext];
    [self doSearch:self.mySearchBar.text];
}

#pragma mark - NOT REALLY USING THIS!!!!

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
    //UIView *contentView = [sender superview];
    self.aCarItem = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass([CarItem class]) inManagedObjectContext:self.moc];
    self.aCarItem.carLocationLat = self.locationManager.location.coordinate.latitude;
    self.aCarItem.carLocationLong = self.locationManager.location.coordinate.longitude;
    self.aCarItem.carLocationDescription = @"Here is your Car!";
    [self.carItems addObject:self.aCarItem];
    [self saveContext];
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
