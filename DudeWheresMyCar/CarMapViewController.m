//
//  ViewController.m
//  DudeWheresMyCar
//
//  Created by Gregory Weiss on 8/9/16.
//  Copyright © 2016 Gregory Weiss. All rights reserved.
//

#import "CarMapViewController.h"
#import <MapKit/MapKit.h>

@import CoreLocation;

@interface CarMapViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation CarMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
