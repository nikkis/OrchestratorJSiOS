//
//  SettingsManager.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 13.5.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSSettingsManager.h"

@implementation OJSSettingsManager

@synthesize _userDefaults;


+ (id)settingsManager {
    static OJSSettingsManager *settingsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingsManager = [[self alloc] init];
    });
    return settingsManager;
}

- (id)init {
    if (self = [super init]) {
        // alloc here user defaults
        _userDefaults = [NSUserDefaults standardUserDefaults];
        [self _loadSettings];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}






// loads settings from OJS and saves them locally
-(void) _loadSettings
{
    
    if([_userDefaults objectForKey:@"username_preference"] == nil || [_userDefaults objectForKey:@"devicename_preference"] == nil ||
       [_userDefaults objectForKey:@"hostname_preference"] == nil || [_userDefaults objectForKey:@"hostport_preference"] == nil )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit settings first!"
                                                        message:@"You must set all the settings befor connecting to OJS."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
    
    NSString* deviceSettings = [NSString stringWithFormat:@"http://%@:%@/api/1/user/%@/device/%@",[_userDefaults objectForKey:@"hostname_preference"], [_userDefaults objectForKey:@"hostport_preference"], [_userDefaults objectForKey:@"username_preference"], [_userDefaults objectForKey:@"devicename_preference"]];
    
    NSLog(deviceSettings);
    
    
    //NSURL* deviceSettingsUrl = [NSURL URLWithString:deviceSettings];
    //NSData* data = [NSData dataWithContentsOfURL:deviceSettingsUrl];
    
    //NSLog(data);
    
    //NSError* error;
    //NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //NSLog(json);
    
    
    
    NSURL* url = [NSURL URLWithString:deviceSettings];
    NSMutableURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse* response,
                                               NSData* data,
                                               NSError* error)
     {
         if (data) {
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             // check status code and possibly MIME type (which shall start with "application/json"):
             NSRange range = [response.MIMEType rangeOfString:@"application/json"];
             
             if (httpResponse.statusCode == 200 && range.length != 0) {
                 NSError* error;
                 id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                 //NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                 if (jsonObject) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         // generate settings here, and connect to ojs
                         
                         NSLog(@"jsonObject: %@", jsonObject);
                         NSString *btUUID = [jsonObject valueForKey:@"btUUID"];
                         
                         [_userDefaults setObject:btUUID forKey:@"btuuid_preference"];
                         NSLog(@"btUUID %@", btUUID);
                         
                         NSArray *capabilities = [jsonObject valueForKey:@"capabilities"];
                         [_userDefaults setObject:capabilities forKey:@"capabilities_preference"];
                         
                         
                     });
                 } else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         //[self handleError:error];
                         NSLog(@"ERROR: %@", error);
                     });
                 }
             }
             else {
                 // status code indicates error, or didn't receive type of data requested
                 NSString* desc = [[NSString alloc] initWithFormat:@"HTTP Request failed with status code: %d (%@)",
                                   (int)(httpResponse.statusCode),
                                   [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]];
                 NSError* error = [NSError errorWithDomain:@"HTTP Request"
                                                      code:-1000
                                                  userInfo:@{NSLocalizedDescriptionKey: desc}];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //[self handleError:error];  // execute on main thread!
                     NSLog(@"ERROR: %@", error);
                 });
             }
         }
         else {
             // request failed - error contains info about the failure
             dispatch_async(dispatch_get_main_queue(), ^{
                 //[self handleError:error]; // execute on main thread!
                 NSLog(@"ERROR: %@", error);
             });
         }
     }];
    
    
    return;
}


-(NSString*) getUsername
{
    return [_userDefaults objectForKey:@"username_preference"];
}


-(NSString*) getDeviceName
{
    return [_userDefaults objectForKey:@"devicename_preference"];
}


-(NSString*) getDeviceIdentity
{
    
    NSString* deviceIdentity = [NSString stringWithFormat:@"%@@%@",[_userDefaults objectForKey:@"username_preference"], [_userDefaults objectForKey:@"devicename_preference"]];
    NSLog(deviceIdentity);
    
    
    // maybe check that ios 8?
    // check if username is nil or devicename is nil or empty..
    if([_userDefaults objectForKey:@"username_preference"] == nil )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        return nil;
    } else {
        return deviceIdentity;
    }
}


-(NSString*) getDeviceBTUUID
{
    NSLog(@"GET BTUUID %s",[_userDefaults objectForKey:@"btuuid_preference"]);
    return [_userDefaults objectForKey:@"btuuid_preference"];
}


-(NSString*) getDeviceBTMAC
{
    return nil;
}


-(NSMutableData*) getDeviceCapabilities
{
    return [_userDefaults objectForKey:@"capabilities_preference"];
}


-(NSString*) getHostName
{
    return [_userDefaults objectForKey:@"hostname_preference"];
}


-(NSString*) getHostPort
{
    return [_userDefaults objectForKey:@"hostport_preference"];
}



@end
