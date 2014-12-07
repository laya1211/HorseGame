//
//  RootViewController.h
//  tweejump
//
//  Created by Yannick Loriot on 10/07/12.
//  Copyright Yannick Loriot 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GADBannerViewDelegate.h"

@class GADBannerView, GADRequest;

@interface RootViewController : UIViewController <GADBannerViewDelegate> {
    @private
        GADBannerView *bannerView_;
        BOOL isAdPositionAtTop_;
    
    BOOL isADReady;
}

- (GADRequest *)createRequest;
- (void)initGADBannerWithAdPositionAtTop:(BOOL)isAdPositionAtTop;
- (void)resizeViewsForOrientation:(UIInterfaceOrientation)toInt;

@end
