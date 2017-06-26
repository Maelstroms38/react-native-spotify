//
//  SpotifyAuth.m
//  spotifyModule
//
//  Created by Jack on 8/8/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "SpotifyAuth.h"
#import "SpotifyLoginViewController.h"

@interface SpotifyAuth ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSArray *requestedScopes;
@property (nonatomic, strong) NSString *headerString;

@property (nonatomic, assign) BOOL *hasListeners;
@end

@implementation SpotifyAuth

@synthesize hasListeners = _hasListeners;

RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
    NSString *SPLoginResponse = @"SPLoginResponse";
    return @[SPLoginResponse];
}

//Start Auth process
RCT_EXPORT_METHOD(setClientID:(NSString *) clientID
                  setRedirectURL:(NSString *) redirectURL
                  setRequestedScopes:(NSArray *) requestedScopes
                  callback:(RCTResponseSenderBlock)block)
{
    SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //set the sharedManager properties
    [sharedManager setClientID:clientID];
    [sharedManager setRequestedScopes:requestedScopes];
    [sharedManager setMyScheme:redirectURL];
    
    //Observer for successful login
    if (!self.hasListeners) {
        [center addObserverForName:@"SPLoginResponse" object:nil queue:nil usingBlock:^(NSNotification *notification)
         {
             if (notification.userInfo[@"error"] != nil) {
                 block(@[notification.userInfo]);
                 //[self deliverNotification:notification];
             } else {
                 block(@[notification.userInfo]);
             }
         }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startAuth:clientID setRedirectURL:redirectURL setRequestedScopes:requestedScopes];
    });
}

/////////////////////////////////
////  SPTAudioStreamingController
/////////////////////////////////

///-----------------------------
/// Properties
///-----------------------------

//Returns true when SPTAudioStreamingController is initialized, otherwise false
RCT_EXPORT_METHOD(initialized:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn initialized])]);
}

//Returns true if the receiver is logged into the Spotify service, otherwise false
RCT_EXPORT_METHOD(loggedIn:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn loggedIn])]);
}

//Returns true if the receiver is playing audio, otherwise false
RCT_EXPORT_METHOD(isPlaying:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn isPlaying])]);
}

//Returns the volume, as a value between 0.0 and 1.0.
RCT_EXPORT_METHOD(volume:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn volume])]);
}

//Returns true if the receiver expects shuffled playback, otherwise false
RCT_EXPORT_METHOD(shuffle:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn shuffle])]);
}

//Returns true if the receiver expects repeated playback, otherwise false
RCT_EXPORT_METHOD(repeat:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn repeat])]);
}

//Returns the current approximate playback position of the current track
RCT_EXPORT_METHOD(currentPlaybackPosition:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn currentPlaybackPosition])]);
}

//Returns the length of the current track
RCT_EXPORT_METHOD(currentTrackDuration:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn currentTrackDuration])]);
}

//Returns the current track URI, playing or not
RCT_EXPORT_METHOD(currentTrackURI:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[[[sharedIn currentTrackURI] absoluteString]]);
}

//Returns the currenly playing track index
RCT_EXPORT_METHOD(currentTrackIndex:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn currentTrackIndex])]);
}

//Returns the current streaming bitrate the receiver is using
RCT_EXPORT_METHOD(targetBitrate:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    block(@[@([sharedIn targetBitrate])]);
}

///-----------------------------
/// Methods
///-----------------------------

//Logout from Spotify
RCT_EXPORT_METHOD(logout)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn logout];
}

//Set playback volume to the given level. Volume is a value between `0.0` and `1.0`.
RCT_EXPORT_METHOD(setVolume:(CGFloat)volume callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn setVolume:volume callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Set the target streaming bitrate. 0 for low, 1 for normal and 2 for high
RCT_EXPORT_METHOD(setTargetBitrate:(NSInteger)bitrate callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn setTargetBitrate:bitrate callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Seek playback to a given location in the current track (in secconds).
RCT_EXPORT_METHOD(seekToOffset:(CGFloat)offset callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn seekToOffset:offset callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Set the "playing" status of the receiver. Pass true to resume playback, or false to pause it.
RCT_EXPORT_METHOD(setIsPlaying:(BOOL)playing callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn setIsPlaying: playing callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Play a list of Spotify URIs.(at most 100 tracks).`SPTPlayOptions` containing extra information about the play request such as which track to play and from which starting position within the track.
RCT_EXPORT_METHOD(playURIs:(NSArray *)uris withOptions:(NSDictionary *)options callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    NSMutableArray *urisArr = [NSMutableArray arrayWithArray:uris];
    SPTPlayOptions *playOptions = [[SPTPlayOptions alloc] init];
    //set the properties of the SPTPlayOptions 'options'
    if(options[@"trackIndex"] != nil){
        [playOptions setTrackIndex:[[options objectForKey:@"trackIndex"]intValue]];
    }
    if(options[@"startTime"] != nil){
        [playOptions setStartTime:[options[@"startTime"] floatValue]];
    }
    
    //Turn all the strings in urisArr to NSURL
    for (int i = 0; i < [urisArr count]; i++) {
        urisArr[i] = [NSURL URLWithString:urisArr[i]];
    }
    [sharedIn playURIs:urisArr withOptions:playOptions callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

// Replace the current list of tracks without stopping playback.
RCT_EXPORT_METHOD(replaceURIs:(NSArray *)uris withCurrentTrack:(int)index callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    NSMutableArray *urisArr = [NSMutableArray arrayWithArray:uris];
    //Turn all the strings in urisArr to NSURL
    for (int i = 0; i < [urisArr count]; i++) {
        urisArr[i] = [NSURL URLWithString:urisArr[i]];
    }
    
    [sharedIn replaceURIs:urisArr withCurrentTrack:index callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Play a Spotify URI.
RCT_EXPORT_METHOD(playURI:(NSString *)uri callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn playURI:[NSURL URLWithString:uri] callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Queue a Spotify URI.
RCT_EXPORT_METHOD(queueURI:(NSString *)uri callback:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn queueURI:[NSURL URLWithString:uri] callback:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Stop playback and clear the queue and list of tracks.
RCT_EXPORT_METHOD(stop:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn stop:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Go to the next track in the queue
RCT_EXPORT_METHOD(skipNext:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn skipNext:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

//Go to the previous track in the queue
RCT_EXPORT_METHOD(skipPrevious:(RCTResponseSenderBlock)block)
{
    SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
    [sharedIn skipPrevious:^(NSError *error) {
        if(error == nil){
            block(@[[NSNull null]]);
        }else{
            block(@[[NSNull null]]);
            [self checkSession];
        }
        return;
    }];
}

/////////////////////////////////
////  END SPTAudioStreamingController
/////////////////////////////////


/////////////////////////////////
////  Search
/////////////////////////////////

///-----------------------------
/// Properties
///-----------------------------

///-----------------------------
/// Methods
///-----------------------------

//Performs a search with a given query, offset and market filtering, returns an Array filled with json Objects
/*
 */
RCT_EXPORT_METHOD(performSearchWithQuery:(NSString *)searchQuery
                  queryType:(NSString *)searchQueryType
                  offset:(NSInteger)offset
                  market:(NSString *)market
                  callback:(RCTResponseSenderBlock)block)
{
    SPTSearchQueryType parm;
    //set the SPTSearchQueryType depending on searchQueryType
    if ([searchQueryType  isEqual: @"track"]){
        parm = SPTQueryTypeTrack;
    } else if ([searchQueryType  isEqual: @"artist"]){
        parm = SPTQueryTypeArtist;
    } else if ([searchQueryType  isEqual: @"album"]){
        parm = SPTQueryTypeAlbum;
    } else if ([searchQueryType  isEqual: @"playList"]){
        parm = SPTQueryTypePlaylist;
    }
    
    [SPTSearch performSearchWithQuery:searchQuery queryType:parm offset:offset accessToken:[[[SpotifyAuth sharedManager] session] accessToken] market:market callback:^(NSError *error, id object) {
        
        NSMutableDictionary *resObj = [NSMutableDictionary dictionary];
        NSMutableArray *resArr = [NSMutableArray array];
        for (int i; i < [[object items] count]; i++){
            SPTPartialArtist *temp = (SPTPartialArtist *)[object items][i];
            resObj[[temp name]] = [temp decodedJSONObject];
            [resArr addObject:[temp decodedJSONObject]];
        }
        NSLog(@"ret %@ ret", [object nextPageURL]);
        block(@[[NSNull null],resArr]);
        return;
    }];
    
}

/////////////////////////////////
////  END Search
/////////////////////////////////


- (BOOL)startAuth:(NSString *) clientID setRedirectURL:(NSString *) redirectURL setRequestedScopes:(NSArray *) requestedScopes {
    NSMutableArray *scopes = [NSMutableArray array];
    //Turn scope arry of strings into an array of SPTAuth...Scope objects
    for (int i = 0; i < [requestedScopes count]; i++) {
        if([requestedScopes[i]  isEqual: @"playlist-read-private"]){
            [scopes addObject: SPTAuthPlaylistReadPrivateScope];
        } else if([requestedScopes[i]  isEqual: @"playlist-modify-private"]){
            [scopes addObject: SPTAuthPlaylistModifyPrivateScope];
        } else if([requestedScopes[i]  isEqual: @"playlist-modify-public"]){
            [scopes addObject: SPTAuthPlaylistModifyPublicScope];
        } else if([requestedScopes[i]  isEqual: @"user-follow-modify"]){
            [scopes addObject: SPTAuthUserFollowModifyScope];
        } else if([requestedScopes[i]  isEqual: @"user-follow-read"]){
            [scopes addObject: SPTAuthUserFollowReadScope];
        } else if([requestedScopes[i]  isEqual: @"user-library-read"]){
            [scopes addObject: SPTAuthUserLibraryReadScope];
        } else if([requestedScopes[i]  isEqual: @"user-library-modify"]){
            [scopes addObject: SPTAuthUserLibraryModifyScope];
        } else if([requestedScopes[i]  isEqual: @"user-read-private"]){
            [scopes addObject: SPTAuthUserReadPrivateScope];
        } else if([requestedScopes[i]  isEqual: @"user-read-birthdate"]){
            [scopes addObject: SPTAuthUserReadBirthDateScope];
        } else if([requestedScopes[i]  isEqual: @"user-read-email"]){
            [scopes addObject: SPTAuthUserReadEmailScope];
        } else if([requestedScopes[i]  isEqual: @"streaming"]){
            [scopes addObject: SPTAuthStreamingScope];
        }
    }
    
    [[SPTAuth defaultInstance] setClientID:clientID];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:redirectURL]];
    [[SPTAuth defaultInstance] setRequestedScopes:scopes];
    
    // Construct a login URL
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    NSURL *authURL = [self loginURLForClientId:clientID withRedirectURL:[NSURL URLWithString:redirectURL] scopes:scopes responseType:@"code"];
    [[SPTAuth defaultInstance] setTokenSwapURL:loginURL];
    [[SPTAuth defaultInstance] setTokenRefreshURL:loginURL];
    
    self.rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    // init the webView with the loginURL
    SpotifyLoginViewController *webView1 =[[SpotifyLoginViewController alloc] initWithURL:authURL];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController: webView1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //Present the webView over the rootView
        [self.rootViewController presentViewController: controller animated:YES completion:nil];
    });
    
    
    return YES;
}

- (NSURL *)loginURLForClientId:(NSString *)clientId withRedirectURL:(NSURL *)redirectURL scopes:(NSArray *)scopes responseType:(NSString *)responseType {
    
    //Create the Authorization Code Flow URL with params:
    //client_id, redirect_uri, state, scope, response_type.
    
    NSMutableString *req = [NSMutableString stringWithFormat:@"https://accounts.spotify.com/authorize?"];
    NSString *authString = [NSString stringWithFormat:@"client_id=%@&response_type=code&redirect_uri=%@&scope=%@&show_dialog=true", clientId, redirectURL, scopes[0]];
    [req appendString:authString];
    NSURL *authURL = [NSURL URLWithString:req];
    
    NSMutableURLRequest *requestAuth = [[NSMutableURLRequest alloc] initWithURL: authURL];
    requestAuth.HTTPMethod = @"GET";
    [requestAuth setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestAuth setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Peform the request
        NSURLResponse *response;
        NSError *error = nil;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (error) {
            // Deal with your error
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSLog(@"HTTP Error: %ld %@", (long)httpResponse.statusCode, error);
                return;
            }
            NSLog(@"Error %@", error);
            return;
        }
        
    });
    
    return authURL;
}

-(void)urlCallback: (NSURL *)url {
    
    NSLog(@"%@", url);
    
    SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];
    NSMutableString *basicString = [[NSMutableString alloc] initWithString:@"Basic "];
    
    NSMutableString *baseString = [[NSMutableString alloc] initWithString:_clientID];
    [baseString appendString:@":7733b014f86e4399b60077aeffe7ad22"];
    
    _headerString = baseString;
    
    NSData *baseData = [_headerString dataUsingEncoding:0];
    
    // Convert to Base64 data
    NSString *base64Data = [baseData base64EncodedStringWithOptions:0];
    
    [basicString appendString:base64Data];
    
    NSString *codedUrl = [url absoluteString];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"code=([a-zA-Z\\d-_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:codedUrl options:0 range:NSMakeRange(0, codedUrl.length)];
    
    if (match) {
        
        NSString *code = [codedUrl substringWithRange:[match rangeAtIndex:1]];
        
        NSMutableString *reqUrl = [NSMutableString stringWithFormat:@"https://accounts.spotify.com/api/token?"];
        
        NSString *authString = [NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@", code, sharedManager.myScheme];
        
        [reqUrl appendString:authString];
        
        NSURL *authURL = [NSURL URLWithString:reqUrl];
        
        NSMutableURLRequest *requestAuth = [[NSMutableURLRequest alloc] initWithURL: authURL];
        requestAuth.HTTPMethod = @"POST";
        [requestAuth setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [requestAuth setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [requestAuth setValue:basicString forHTTPHeaderField:@"Authorization"];
        
        //NSLog(@"%@", requestAuth.allHTTPHeaderFields);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Peform the request
            NSURLResponse *response;
            NSError *error = nil;
            NSData *receivedData = [NSURLConnection sendSynchronousRequest:requestAuth
                                                         returningResponse:&response
                                                                     error:&error];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            if (error) {
                // Deal with your error
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSLog(@"HTTP Error: %ld %@", (long)httpResponse.statusCode, error);
                    return;
                }
                NSLog(@"Error %@", error);
                return;
            }
            NSArray *dict = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error:&error];
            
            if ((long)httpResponse.statusCode == 200) {
                
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                NSMutableDictionary *loginRes =  [NSMutableDictionary dictionary];
                
                NSString *callback = [NSString stringWithFormat:@"%@/#access_token=%@&token_type=%@&expires_in=%@", _myScheme, [dict valueForKey:@"access_token"], [dict valueForKey:@"token_type"], [dict valueForKey:@"expires_in"]];
                NSLog(@"%@", callback);
                NSURL *callbackUrl = [[NSURL alloc] initWithString:callback];
                
                if ([[SPTAuth defaultInstance] canHandleURL:callbackUrl]) {
                    [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:callbackUrl callback:^(NSError *error, SPTSession *session) {
                        
                        if (error != nil) {
                            NSLog(@"*** Auth error: %@", error);
                            loginRes[@"error"] = @"error while attempting to login!";
                            
                        } else {
                            
                            // Create a new player if needed
                            
                            if (self.player == nil) {
                                //Set the session property to the seesion we got from the login Url
                                
                                _session = session;
                                [self setSession: session];
                                SPTAudioStreamingController *sharedIn = [SPTAudioStreamingController sharedInstance];
                                [sharedIn startWithClientId:[SPTAuth defaultInstance].clientID error:nil];
                                self.player = sharedIn;
                                //keep this one
                                [[SpotifyAuth sharedManager] setSession:session];
                                [[sharedManager player] loginWithAccessToken:[session accessToken]];
                                [self setPlayer:[sharedManager player]];
                                
                                loginRes[@"tokenType"] = [dict valueForKey:@"token_type"];
                                loginRes[@"accessToken"] = [dict valueForKey:@"access_token"];
                                loginRes[@"expires"] = [dict valueForKey:@"expires_in"];
                                loginRes[@"refreshToken"] = [dict valueForKey:@"refresh_token"];
                                [center postNotificationName:@"SPLoginResponse" object:nil userInfo:loginRes];
                            }
                        }
                    }];
                } else {
                    NSLog(@"Error during login attempt");
                }
            }
        });
    }
}

//Check if session is valid and renew it if not
-(void)checkSession{
    SpotifyAuth *sharedManager = [SpotifyAuth sharedManager];
    if (![[sharedManager session] isValid]){
        [[SPTAuth defaultInstance] renewSession:[sharedManager session] callback:^(NSError *error, SPTSession *session) {
            if(error != nil){
                NSLog(@"Error: %@", error);
                //launch the login again
                [sharedManager startAuth:sharedManager.clientID setRedirectURL:sharedManager.myScheme setRequestedScopes:sharedManager.requestedScopes];
            } else {
                [sharedManager setSession:session];
                [[sharedManager player] loginWithAccessToken:session.accessToken];
            }
        }];
    }
    
}
-(void)setSession:(SPTSession *)session{
    _session = session;
}

-(void)setMyScheme:(NSString *)myScheme{
    _myScheme = myScheme;
}

-(void)setClientID:(NSString *)clientID{
    _clientID = clientID;
}

-(void)setRequestedScopes:(NSArray *)requestedScopes{
    _requestedScopes = requestedScopes;
}

+ (id)sharedManager {
    static SpotifyAuth *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}
#pragma mark - Notification handlers

// Will be called when this module's first listener is added.
-(void)startObservingSpotify {
    self.hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObservingSpotify {
    self.hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

- (void)deliverNotification:(NSNotification *)notification {
    if (self.hasListeners) { // Only send events if anyone is listening
        //NSLog(@"Name: %@, Object: %@", notification.name, notification.userInfo);
        [self sendEventWithName:notification.name body:notification.userInfo];
    }
}


@end
