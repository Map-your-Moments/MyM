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

@interface MapViewController()
@property(strong, nonatomic) UIView *navBox;
@property(nonatomic) BOOL navboxIsVisible;
@property(nonatomic) BOOL firstLoad;
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataController = [[MomentDataController alloc] init];
    
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];

    [self createNavbox];
    [self createAwesomeMenu];
    [self createLocationButton];
    [self createMenuButton];
    
    self.firstLoad = TRUE;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateAnnotations];
    
    if(self.firstLoad)
    {
        [self zoomToUserLocation];
        self.firstLoad = FALSE;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

#pragma mark - Custom UI creation methods
- (void)createNavbox
{
    self.navBox = [[UIView alloc] initWithFrame:navboxRectHidden];
    self.navBox.hidden = YES;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"ios-linen_blue.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navBox setBackgroundColor:[UIColor colorWithPatternImage: image]];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"ios-linen_darkblue.png"] drawInRect:self.view.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.navBox.layer setCornerRadius:10.0f];
    [self.navBox.layer setBorderColor:[UIColor colorWithPatternImage: image].CGColor];
    [self.navBox.layer setBorderWidth:1.5f];
    [self.navBox.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.navBox.layer setShadowOpacity:0.5];
    [self.navBox.layer setShadowRadius:2.0];
    [self.navBox.layer setShadowOffset:CGSizeMake(7.0, 5.0)];
    
    [self.view addSubview:self.navBox];
    
    UIImage *friendsImage = [UIImage imageNamed:@"Group.png"];
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [friendsButton setFrame:CGRectMake(15, 20, 30, 30)];
    [friendsButton addTarget:self action:@selector(friends) forControlEvents:UIControlEventTouchUpInside];
    [friendsButton setImage:friendsImage forState:UIControlStateNormal];
    [friendsButton setShowsTouchWhenHighlighted:YES];
    [self.navBox addSubview:friendsButton];
    
    UIImage *profileImage = [UIImage imageNamed:@"Cogwheels.png"];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(15, 100, 30, 30)];
    [settingsButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setImage:profileImage forState:UIControlStateNormal];
    [settingsButton setShowsTouchWhenHighlighted:YES];
    [self.navBox addSubview:settingsButton];
    
    UIImage *logoutImage = [UIImage imageNamed:@"Power.png"];
    UIButton *signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signOutButton setFrame:CGRectMake(15, 180, 30, 30)];
    [signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    [signOutButton setImage:logoutImage forState:UIControlStateNormal];
    [signOutButton setShowsTouchWhenHighlighted:YES];
    [self.navBox addSubview:signOutButton];
    
    UIView *navboxGestureArea = [[UIView alloc] initWithFrame:navboxRectLoc];
    [self.view addSubview:navboxGestureArea];
    
    UISwipeGestureRecognizer *swipeIn = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNavbox)];
    [swipeIn setDirection:UISwipeGestureRecognizerDirectionRight];
    [navboxGestureArea addGestureRecognizer:swipeIn];
    
    UISwipeGestureRecognizer *swipeOut = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideNavbox)];
    [swipeOut setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.navBox addGestureRecognizer:swipeOut];
    
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
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds menus:[NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, nil]];
    menu.delegate = self;
    menu.startPoint = CGPointMake(screenWidth-25, screenHeight-25);
    menu.menuWholeAngle = -M_2_PI * 3.71;
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
    [locationButton setFrame:CGRectMake(screenWidth-45, 5, 40, 40)];
    [self.mapView addSubview:locationButton];
}

- (void)createMenuButton
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton.layer setCornerRadius:10.0f];
    [menuButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.8f]];
    [menuButton addTarget:self action:@selector(menuButtonShowHide) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
    [menuButton setFrame:CGRectMake(5, 5, 40, 40)];
    [self.mapView addSubview:menuButton];
    
}

#pragma mark - Animation methods for subviews
- (void)showNavbox
{
    NSLog(@"Show Navbox");
    if(!self.navboxIsVisible) {
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.navBox setHidden:NO];
                             [self.navBox setFrame:navboxRectVisible];
                         }
                         completion:nil];
        self.navboxIsVisible = YES;
    }
}

- (void)hideNavbox
{
    NSLog(@"Hide Navbox");
    if(self.navboxIsVisible) {
        [UIView animateWithDuration:.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.navBox setFrame:navboxRectHidden];
                         }
                         completion:^(BOOL finished){
                             [self.navBox setHidden:YES];
                         }];
        self.navboxIsVisible = NO;
    }
}

#pragma mark - Navbox Button actions
- (void)menuButtonShowHide
{
    self.navboxIsVisible ? [self hideNavbox]: [self showNavbox];
}

- (void)friends
{
    SearchBarTableViewController *vc = [[SearchBarTableViewController alloc] initWithSectionIndexes:YES];
    [vc setUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settings
{
    UserAccountViewController *vc = [[UserAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [vc setUser:self.user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)signOut
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - AwesomeMenu Delegate
- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)index
{
    MomentCreateViewController *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
    [vc setCurrentLocation:[[[self.mapView userLocation] location] coordinate]];
    [vc setDataController:self.dataController];
    [vc setCurrentUser:self.user];
    
    if(index == 0) {
        NSLog(@"Add Picture Moment");
        [vc setContentType:kTAGMOMENTPICTURE];
    } else if(index == 1) {
        NSLog(@"Add Audio Moment");
        [vc setContentType:kTAGMOMENTAUDIO];
    } else if(index == 2) {
        NSLog(@"Add Text Moment");
        [vc setContentType:kTAGMOMENTTEXT];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
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
        self.dataController = [s3 updateMomentsForUser:self.user];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self loadAnnotations];
        });
    });
}

- (void)loadAnnotations
{
    for(int i = 0; i < [self.dataController countOfMoments]; i++) {
        Moment *moment = [self.dataController objectInMomentsAtIndex:i];
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = moment.coords;
        pin.title = moment.user;
        pin.subtitle = moment.title;
        [self.mapView addAnnotation:pin];
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

- (void)zoomToUserLocation
{
    MKUserLocation *userLocation = [self.mapView userLocation];
    
    if (!userLocation) return;
    
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
