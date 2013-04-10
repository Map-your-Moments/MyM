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

#import "MapCreateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MomentCreateView.xib"

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

#define navboxRectVisible CGRectMake(-10, 0, 90, screenHeight)
#define navboxRectHidden CGRectMake(-100, 0, 90, screenHeight)
#define navboxRectLoc CGRectMake(0, 0, 10, screenHeight)

@implementation MapCreateViewController
{
    UIView *navBox;
    
    BOOL navboxIsVisible;
}

@synthesize mapView, dataController;

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
    
    /*
     * Add some dummy moments to test with until we can pull them from the server
     */
    User *user = [[User alloc] initWithUserName:@"adamcumiskey"
                                    andPassword:nil
                                  andDateJoined:nil
                                       andEmail:nil
                                    andSettings:nil
                                     andMoments:nil
                                     andFriends:nil];
    Moment *moment1 = [[Moment alloc] initWithTitle:@"test moment"
                                           withTags:nil
                                            andUser:user
                                         andContent:nil
                                            andDate:nil
                                          andCoords:CLLocationCoordinate2DMake(40.0f, -70.0f)
                                        andComments:nil
                                          andTripID:nil];
    [dataController addMomentToMomentsWithMoment:moment1];
    
    [mapView setShowsUserLocation:YES];
    [mapView setDelegate:self];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(menuButtonShowHide)];
    self.navigationItem.leftBarButtonItem = menuButton;
    

    [self createNavbox];
    [self createAwesomeMenu];
    
    [self loadAnnotations];
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
    [navBox setBackgroundColor:[UIColor whiteColor]];
    [navBox.layer setCornerRadius:10.0f];
    [navBox.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [navBox.layer setBorderWidth:1.5f];
    [navBox.layer setShadowColor:[UIColor blackColor].CGColor];
    [navBox.layer setShadowOpacity:0.5];
    [navBox.layer setShadowRadius:2.0];
    [navBox.layer setShadowOffset:CGSizeMake(7.0, 5.0)];
    
    [self.view addSubview:navBox];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchButton setFrame:CGRectMake(14, 35, 70, 45)];
    [searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [navBox addSubview:searchButton];
    
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [friendsButton setFrame:CGRectMake(14, 135, 70, 45)];
    [friendsButton addTarget:self action:@selector(friends) forControlEvents:UIControlEventTouchUpInside];
    [friendsButton setTitle:@"Friends" forState:UIControlStateNormal];
    [navBox addSubview:friendsButton];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [settingsButton setFrame:CGRectMake(14, 235, 70, 45)];
    [settingsButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    [navBox addSubview:settingsButton];
    
    UIButton *signOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [signOutButton setFrame:CGRectMake(14, 335, 70, 45)];
    [signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
    [signOutButton setTitle:@"Logout" forState:UIControlStateNormal];
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
    menu.startPoint = CGPointMake(screenWidth-25, screenHeight-70);
    menu.menuWholeAngle = -M_2_PI * 3.5;
    menu.endRadius = 75.0f;
    menu.farRadius = 85.0f;
    menu.nearRadius = 65.0f;
    [self.view addSubview:menu];
    
}

#pragma mark - Animation methods for subviews
                                          
- (void)showNavbox
{
    NSLog(@"Show Navbox");
    if(!navboxIsVisible) {
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ [navBox setFrame:navboxRectVisible]; }
                         completion:nil];
        navboxIsVisible = YES;
    }
}

- (void)hideNavbox
{
    NSLog(@"Hide Navbox");
    if(navboxIsVisible) {
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ [navBox setFrame:navboxRectHidden]; }
                         completion:nil];
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

- (void)search
{
    NSLog(@"Search");
}

- (void)friends
{
    NSLog(@"Friends");
}

- (void)settings
{
    NSLog(@"Settings");
}

- (void)signOut
{
    NSLog(@"Sign Out");
}

#pragma mark - AwesomeMenu Delegate

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    
    CLLocationCoordinate2D currentLocation = [[[mapView userLocation] location] coordinate];
    
    if(idx == 0) {
        NSLog(@"Add Picture Moment");
        MomentCre *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
        [vc setContentType:kTAGMOMENTPICTURE];
        [vc setCurrentLocation:currentLocation];
        [vc setDataController:dataController];
        [vc setCurrentUser:user];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if(idx == 1) {
        NSLog(@"Add Audio Moment");
        MomentCreateViewController *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
        [vc setContentType:kTAGMOMENTAUDIO];
        [vc setCurrentLocation:currentLocation];
        [vc setDataController:dataController];
        [vc setCurrentUser:user];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if(idx == 2) {
        NSLog(@"Add Text Moment");
        MomentCreateViewController *vc = [[MomentCreateViewController alloc] initWithNibName:@"MomentCreateView" bundle:nil];
        [vc setContentType:kTAGMOMENTTEXT];
        [vc setCurrentLocation:currentLocation];
        [vc setDataController:dataController];
        [vc setCurrentUser:user];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - MapView methods

- (void)loadAnnotations
{
    for(int i = 0; i < [dataController countOfMoments]; i++) {
        Moment *moment = [dataController objectInMomentsAtIndex:i];
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = moment.coords;
        pin.title = moment.user.username;
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
    pin.animatesDrop = NO;
    pin.pinColor = MKPinAnnotationColorPurple;
    
    return pin;
}

- (void)showMomentDetail
{
    NSLog(@"Show Moment Detail");
}

@end
