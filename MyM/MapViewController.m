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
#import "FriendsListViewController.h"
#import "MomentCreateViewController.h"

#define screenWidth [[UIScreen mainScreen] applicationFrame].size.width
#define screenHeight [[UIScreen mainScreen] applicationFrame].size.height

#define navboxRectVisible CGRectMake(-10, 5, 90, screenHeight-55)
#define navboxRectHidden CGRectMake(-100, 5, 90, screenHeight-55)
#define navboxRectLoc CGRectMake(0, 0, 10, screenHeight)

@implementation MapViewController
{
    UIView *navBox;
    
    BOOL navboxIsVisible;
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
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(menuButtonShowHide)];
    self.navigationItem.leftBarButtonItem = menuButton;
    

    [self createNavbox];
    [self createAwesomeMenu];
    [self createLocationButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateMoments];
    [self zoomToUserLocation];
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

#pragma mark - Animation methods for subviews
                                          
- (void)showNavbox
{
    NSLog(@"Show Navbox");
    if(!navboxIsVisible) {
        [UIView animateWithDuration:.2
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
        [UIView animateWithDuration:.2
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

- (void)search
{
}

- (void)friends
{
    FriendsListViewController *vc = [[FriendsListViewController alloc] initWithNibName:@"FriendsListViewController" bundle:nil];
    [mapView removeAnnotations:mapView.annotations]; //!
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settings
{
}

- (void)signOut
{
    [mapView removeAnnotations:mapView.annotations]; //!
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - S3 methods

/*     This group of methods updates the moments on the map from the S3 server
 *
 * Logical Structure :::
 *         -dataController is cleared
 *         -each s3 folder that the user has access to will list all of the keys
 *             for the objects in them and add them to an array
 *         -the getAllObjectsFromKeys: method will take that array and get the data
 *             for each individual object, unarchive it, then add it to the dataController
 *
 *                            *** Caution ***
 *     The only method here that should be called outside of this block is the
 * updateMoments method to refresh the dataController. updateMoments has an
 * asynchronous block from where it calls it's helper functions, but the helper
 * functions themselves do not, thus if they are called directly they will cause
 * the UI to hang until they finish.
 */

- (void)updateMoments
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        [dataController removeAllMoments];
        NSArray *keys = [NSArray arrayWithArray:[self listAllMomentsForUser]];
        [self getAllObjectsFromKeys:keys];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self loadAnnotations];
        });
    });

}

- (NSArray *)listMomentsInS3Folder:(NSString *)folder
{
    NSArray *keys = [[NSArray alloc] init];
    
    @try{
        S3ListObjectsRequest *request = [[S3ListObjectsRequest alloc] init];
        [request setBucket:kS3BUCKETNAME];
        [request setMarker:folder];
        S3ListObjectsResponse *response = [[AmazonClientManager amazonS3Client] listObjects:request];
        keys = response.listObjectsResult.objectSummaries;
        if(response.error != nil)
            NSLog(@"Error: %@", response.error);
    }
    @catch (AmazonClientException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Exception: %@", exception);
    }
    
    return keys;
}

- (NSArray *)listAllMomentsForUser
{
    NSMutableArray *objectKeys = [[NSMutableArray alloc] init];
    
    /* the list moments in s3 folder will be called for each
     * friend a user has, and will store all of the keys in an array,
     * which it will return for the getAllObjectsFromKeys method
     */
    
    // for now, this will just return the user's moments
    [objectKeys addObjectsFromArray:[self listMomentsInS3Folder:[NSString stringWithFormat:@"%@/", user.username]]];
    
    return objectKeys;
}

- (void)getMomentWithKey:(NSString *)key
{
    @try{
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:key withBucket:kS3BUCKETNAME];
        S3GetObjectResponse *response = [[AmazonClientManager amazonS3Client] getObject:request];
        
        // get the data for the moment, then use the KeyedUnarchiver to convert it back to a moment object.
        // temp moment will get overwritten everytime this method is called.
        NSData *momentData = response.body;
        tempMoment = [NSKeyedUnarchiver unarchiveObjectWithData:momentData];
        
        if(response.error != nil)
            NSLog(@"Error: %@", response.error);
    }
    @catch (AmazonClientException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:exception.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"Exception: %@", exception);
    }
}

- (void)getAllObjectsFromKeys:(NSArray *)keys
{
    for (S3ObjectSummary *object in keys) {
        [self getMomentWithKey:object.key];
        [dataController addMomentToMomentsWithMoment:tempMoment];
    }
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

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self zoomToUserLocation];
}

- (void)zoomToUserLocation
{
    MKUserLocation *userLocation = [mapView userLocation];
    
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(2.0, 2.0);
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)showMomentDetail
{
    NSLog(@"Show Moment Detail");
}

@end
