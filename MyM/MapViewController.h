/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MapViewController.h
 * View Controller for the main map view
 *
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AwesomeMenu.h"
#import "Moment.h"

@class MomentDataController;

@interface MapViewController : UIViewController <AwesomeMenuDelegate, MKMapViewDelegate, MKAnnotation>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic)  MomentDataController *dataController;

@end
