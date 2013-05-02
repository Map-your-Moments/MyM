/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * MapViewController.m
 * View Controller for the main map view
 *
 */

#import "MapViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchBarTableViewController.h"
#import "MomentCreateViewController.h"
#import "UserAccountViewController.h"

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

#define navboxRecSize 230
#define navboxRectVisible CGRectMake(-10, screenHeight / 2 - navboxRecSize / 2, 50, navboxRecSize)
#define navboxRectHidden CGRectMake(-100, screenHeight / 2 - navboxRecSize / 2, 50, navboxRecSize)
#define navboxRectLoc CGRectMake(0, 0, 10, screenHeight)

@implementation MapViewController {
    UIView *navBox;
    
    BOOL navboxIsVisible;
    BOOL firstLoad;
}

@synthesize mapView, dataController, user, tempMoment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataController = [[MomentDataController alloc] init];
    self.navigationItem.hidesBackButton = YES;
    
    [mapView setShowsUserLocation:YES];
    [mapView setDelegate:self];

    [self createNavbox];
    [self createAwesomeMenu];
    [self createLocationButton];
    [self createMenuButton];
    
    firstLoad = TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateAnnotations];
    
    if(firstLoad)
    {
        [self zoomToUserLocation];
        firstLoad = FALSE;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom UI creation methods

- (void)createNavbox
{
    navBox = [[UIView alloc] initWithFrame:navboxRectHidden];
    navBox.hidden = YES;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"ios-linen_blue.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [navBox setBackgroundColor:[UIColor colorWithPatternImage: image]];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"ios-linen_darkblue.png"] drawInRect:self.view.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [navBox.layer setCornerRadius:10.0f];
    [navBox.layer setBorderColor:[UIColor colorWithPatternImage: image].CGColor];
    [navBox.layer setBorderWidth:1.5f];
    [navBox.layer setShadowColor:[UIColor blackColor].CGColor];
    [navBox.layer setShadowOpacity:0.5];
    [navBox.layer setShadowRadius:2.0];
    [navBox.layer setShadowOffset:CGSizeMake(7.0, 5.0)];
    
    [self.view addSubview:navBox];
    
    UIImage *friendsImage = [UIImage imageNamed:@"Group.png"];
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [friendsButton setFrame:CGRectMake(15, 20, 30, 30)];
    [friendsButton addTarget:self action:@selector(friends) forControlEvents:UIControlEventTouchUpInside];
    [friendsButton setImage:friendsImage forState:UIControlStateNormal];
    [friendsButton setShowsTouchWhenHighlighted:YES];
    [navBox addSubview:friendsButton];
    
    UIImage *profileImage = [UIImage imageNamed:@"Cogwheels.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(15, 100, 30, 30)];
    [settingsButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setImage:profileImage forState:UIControlStateNormal];
    [settingsButton setShowsTouchWhenHighlighted:YES];
    [navBox addSubview:settingsButton];
    
    UIImage *logoutImage = [UIImage imageNamed:@"Power.png"];
    UIButton *signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signOutButton setFrame:CGRectMake(15, 180, 30, 30)];
    [signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    [signOutButton setImage:logoutImage forState:UIControlStateNormal];
    [signOutButton setShowsTouchWhenHighlighted:YES];
    [navBox addSubview:signOutButton];
    
    UIView *navboxGestureArea = [[UIView alloc] initWithFrame:navboxRectLoc];
    [self.view addSubview:navboxGestureArea];
    
    UISwipeGestureRecognizer *swipeIn = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNavbox)];
    [swipeIn setDirection:UISwipeGestureRecognizerDirectionRight];
    [navboxGestureArea addGestureRecognizer:swipeIn];
    
    UISwipeGestureRecognizer *swipeOut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideNavbox)];
    [swipeOut setDirection:UISwipeGestureRecognizerDirectionLeft];
    [navBox addGestureRecognizer:swipeOut];
    
    UITapGestureRecognizer *tapDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideNavbox)];
    [self.mapView addGestureRecognizer:tapDismiss];
}

- (void)createAwesomeMenu
{
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    UIImage *picImage = [UIImage imageNamed:@"Camera.png"];
    UIImage *micImage = [UIImage imageNamed:@"Microphone.png"];
    UIImage *noteImage = [UIImage imageNamed:@"Notepad.png"];
    UIImage *videoImage = [UIImage imageNamed:@"Video.png"];
    AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:picImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:micImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:noteImage
                                                    highlightedContentImage:nil];
    AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:videoImage
                                                    highlightedContentImage:nil];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:[NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, nil]];
    menu.delegate = self;
    menu.startPoint = CGPointMake(screenWidth-25, screenHeight-25);
    menu.menuWholeAngle = -M_2_PI * 3.3;
    menu.endRadius = 75.0f;
    menu.farRadius = 85.0f;
    menu.nearRadius = 65.0f;
    [self.view addSubview:menu];
    
}

- (void)createLocationButton
{
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton.layer setCornerRadius:10.0f];
    [locationButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.8f]];
    [locationButton addTarget:self action:@selector(zoomToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [locationButton setImage:[UIImage imageNamed:@"ic_action_location_on_me.png"] forState:UIControlStateNormal];
    [locationButton setFrame:CGRectMake(screenWidth-37, 5, 32, 32)];
    [mapView addSubview:locationButton];
    
}

- (void)createMenuButton
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton.layer setCornerRadius:10.0f];
    [menuButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.8f]];
    [menuButton addTarget:self action:@selector(menuButtonShowHide) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
    [menuButton setFrame:CGRectMake(5, 5, 32, 32)];
    [mapView addSubview:menuButton];
    
}

#pragma mark - Animation methods for subviews

- (void)showNavbox
{
    NSLog(@"Show Navbox");
    if(!navboxIsVisible) {
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [navBox setHidden:NO];
                             [navBox setFrame:navboxRectVisible];
                         }
                         completion:nil];
        navboxIsVisible = YES;
    }
}

- (void)hideNavbox
{
    NSLog(@"Hide Navbox");
    if(navboxIsVisible) {
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ [navBox setFrame:navboxRectHidden]; }
                         completion:^(BOOL finished){
                             [navBox setHidden:YES];
                         }];
        navboxIsVisible = NO;
    }
}

#pragma mark - Navbox Button actions

- (void)menuButtonShowHide
{
    if(!navboxIsVisible) {
        [self showNavbox];
    }
    
    else if(navboxIsVisible) {
        [self hideNavbox];
    }
}

- (void)friends
{
    //[self hideNavbox];
    SearchBarTableViewController *vc = [[SearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [mapView removeAnnotations:mapView.annotations]; //!
    [vc setUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settings
{
    //[self hideNavbox];
    UserAccountViewController *vc = [[UserAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [mapView removeAnnotations:mapView.annotations]; //!
    [vc setUser:user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signOut
{
    [mapView removeAnnotations:mapView.annotations]; //!
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - AwesomeMenu Delegate

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    
    CLLocationCoordinate2D currentLocation = [[[mapView userLocation] location] coordinate];
    
    if(idx == 0) {
        NSLog(@"Add Picture Moment");
        MomentCreateViewController *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
        [vc setContentType:kTAGMOMENTPICTURE];
        [vc setCurrentLocation:currentLocation];
        [vc setDataController:dataController];
        [vc setCurrentUser:user];
        [mapView removeAnnotations:mapView.annotations]; //!
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if(idx == 1) {
        NSLog(@"Add Audio Moment");
        MomentCreateViewController *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
        [vc setContentType:kTAGMOMENTAUDIO];
        [vc setCurrentLocation:currentLocation];
        [vc setDataController:dataController];
        [vc setCurrentUser:user];
        [mapView removeAnnotations:mapView.annotations]; //!
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if(idx == 2) {
        NSLog(@"Add Text Moment");
        MomentCreateViewController *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
        [vc setContentType:kTAGMOMENTTEXT];
        [vc setCurrentLocation:currentLocation];
        [vc setDataController:dataController];
        [vc setCurrentUser:user];
        [mapView removeAnnotations:mapView.annotations]; //!
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - MapView methods

- (void)updateAnnotations
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        S3UtilityClass *s3 = [[S3UtilityClass alloc] init];
        dataController = [s3 updateMomentsForUser:user];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self loadAnnotations];
        });
    });
}

- (void)loadAnnotations
{
    for(int i = 0; i < [dataController countOfMoments]; i++) {
        Moment *moment = [dataController objectInMomentsAtIndex:i];
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = moment.coords;
        pin.title = moment.user;
        pin.subtitle = moment.title;
        [mapView addAnnotation:pin];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        //Don't trample the user location annotation (pulsing blue dot).
        return nil;
    }
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"momentAnnotation"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imageView setImage:[UIImage imageNamed:@"Default.png"]];
    pin.leftCalloutAccessoryView = imageView;
    
    UIButton *buttonView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.rightCalloutAccessoryView = buttonView;
    [buttonView addTarget:self action:@selector(showMomentDetail) forControlEvents:UIControlEventTouchUpInside];
    
    pin.canShowCallout = YES;
    pin.animatesDrop = YES; //!
    pin.pinColor = MKPinAnnotationColorPurple;
    
    return pin;
}

//- (void)centerOnUserLocation
//{
//    MKUserLocation *userLocation = [mapView userLocation];
//    
//    if (!userLocation)
//        return;
//    
//    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
//}

- (void)zoomToUserLocation
{
    MKUserLocation *userLocation = [mapView userLocation];
    
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.8, 0.8);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)showMomentDetail
{
    NSLog(@"Show Moment Detail");
}

@end
