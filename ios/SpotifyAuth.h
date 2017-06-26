//
//  SpotifyAuth.h
//  spotifyModule
//
//  Created by Jack on 8/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#else
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#endif

@interface SpotifyAuth : RCTEventEmitter <RCTBridgeModule>
@property (nonatomic, strong) NSString *myScheme;
@property (nonatomic, strong) UIViewController *rootViewController;
-(void)urlCallback: (NSURL *)url;
+ (id)sharedManager;
@end
