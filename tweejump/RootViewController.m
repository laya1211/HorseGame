//
//  RootViewController.m
//  tweejump
//
//  Created by Yannick Loriot on 10/07/12.
//  Copyright Yannick Loriot 2012. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "GameConfig.h"

#import "GADBannerView.h"
#import "GADRequest.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	// Custom initialization
	}
	return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	[super viewDidLoad];
 
 }
 */

- (void)initGADBannerWithAdPositionAtTop:(BOOL)isAdPositionAtTop {
    isAdPositionAtTop_ = isAdPositionAtTop;
    
    // NOTE:
    // Add your publisher ID here and fill in the GADAdSize constant for the ad
    // you would like to request.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    //bannerView_.adUnitID = @"pub-9137017936591748";
    bannerView_.adUnitID = @"ca-app-pub-9137017936591748/9749421316";
    bannerView_.delegate = self;
    [bannerView_ setRootViewController:self];
    
    //默认不显示
    //bannerView_.hidden = true;
    
    isADReady = false;
    
    [self.view addSubview:bannerView_];
    [bannerView_ loadRequest:[self createRequest]];

    // Use the status bar orientation since we haven't signed up for orientation
    // change notifications for this class.
    [self resizeViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(amShowADBanner) name:@"amShowADBanner" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(amHideADBanner) name:@"amHideADBanner" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(amReloadADBanner) name:@"amReloadADBanner" object:nil];

}


- (void)resizeViewsForOrientation:(UIInterfaceOrientation)toInt {
    // If the banner hasn't been created yet, no need for resizing views.
    if (!bannerView_) {
        return;
    }
    
    BOOL adIsShowing = [self.view.subviews containsObject:bannerView_];
    if (!adIsShowing) {
        return;
    }
    
    // Frame of the main RootViewController which we call the root view.
    CGRect rootViewFrame = self.view.frame;
    // Frame of the main RootViewController view that holds the Cocos2D view.
    CGRect glViewFrame = [[CCDirector sharedDirector] openGLView].frame;
    CGRect bannerViewFrame = bannerView_.frame;
    CGRect frame = bannerViewFrame;
    // The updated x and y coordinates for the origin of the banner.
    CGFloat yLocation = 0.0;
    CGFloat xLocation = 0.0;
    
    if (isAdPositionAtTop_) {
        // Move the root view underneath the ad banner.
        glViewFrame.origin.y = bannerViewFrame.size.height;
        // Center the banner using the value of the origin.
        if (UIInterfaceOrientationIsLandscape(toInt)) {
            // The superView has not had its width and height updated yet so use those
            // values for the x and y of the new origin respectively.
            xLocation = (rootViewFrame.size.height -
                         bannerViewFrame.size.width) / 2.0;
        } else {
            xLocation = (rootViewFrame.size.width -
                         bannerViewFrame.size.width) / 2.0;
        }
    } else {
        // Move the root view to the top of the screen.
        glViewFrame.origin.y = 0;
        // Need to center the banner both horizontally and vertically.
        if (UIInterfaceOrientationIsLandscape(toInt)) {
            yLocation = rootViewFrame.size.width -
            bannerViewFrame.size.height;
            xLocation = (rootViewFrame.size.height -
                         bannerViewFrame.size.width) / 2.0;
        } else {
            yLocation = rootViewFrame.size.height -
            bannerViewFrame.size.height;
            xLocation = (rootViewFrame.size.width -
                         bannerViewFrame.size.width) / 2.0;
        }
    }
    frame.origin = CGPointMake(xLocation, yLocation);
    bannerView_.frame = frame;
   
    /*
    if (UIInterfaceOrientationIsLandscape(toInt)) {
        // The super view's frame hasn't been updated so use its width
        // as the height.
        glViewFrame.size.height = rootViewFrame.size.width -
        bannerViewFrame.size.height;
        glViewFrame.size.width = rootViewFrame.size.height;
    } else {
        glViewFrame.size.height = rootViewFrame.size.height -
        bannerViewFrame.size.height;
    }
    //*/
    [[CCDirector sharedDirector] openGLView].frame = glViewFrame;
    
}

#pragma mark GADBannerViewDelegate impl

- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as
    // well as any devices you want to receive test ads.
    request.testDevices =
    [NSArray arrayWithObjects:
     // TODO: Add your device/simulator test identifiers here. They are
     // printed to the console when the app is launched.
     nil];
    return request;
}

#pragma mark GADBannerViewDelegate impl

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad");
    
    isADReady = true;
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}


#pragma mark - show or hide adview
-(void)amHideADBanner
{
    if (!bannerView_) {
        return;
    }
    bannerView_.hidden = true;
}
-(void)amShowADBanner
{
    if (!bannerView_) {
        return;
    }
    bannerView_.hidden = false;
}

-(void)amReloadADBanner
{
    if (!bannerView_) {
        return;
    }
    if (isADReady) {
        [bannerView_ loadRequest:[self createRequest]];
        //isADReady = false;
    }

}

#pragma mark -

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	//
	// There are 2 ways to support auto-rotation:
	//  - The OpenGL / cocos2d way
	//     - Faster, but doesn't rotate the UIKit objects
	//  - The ViewController way
	//    - A bit slower, but the UiKit objects are placed in the right place
	//
	
#if GAME_AUTOROTATION==kGameAutorotationNone
	//
	// EAGLView won't be autorotated.
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	//
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION==kGameAutorotationCCDirector
	//
	// EAGLView will be rotated by cocos2d
	//
	// Sample: Autorotate only in landscape mode
	//
	if( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
	} else if( interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
	}
	
	// Since this method should return YES in at least 1 orientation, 
	// we return YES only in the Portrait orientation
	return ( interfaceOrientation == UIInterfaceOrientationPortrait );
	
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController
	//
	// EAGLView will be rotated by the UIViewController
	//
	// Sample: Autorotate only in landscpe mode
	//
	// return YES for the supported orientations
	
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	
#else
#error Unknown value in GAME_AUTOROTATION
	
#endif // GAME_AUTOROTATION
	
	
	// Shold not happen
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// Assuming that the main window has the size of the screen
	// BUG: This won't work if the EAGLView is not fullscreen
	///
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect rect = CGRectZero;

	
	if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
		rect = screenRect;
	
	else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
	
	CCDirector *director = [CCDirector sharedDirector];
	EAGLView *glView = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

