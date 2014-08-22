//
//  SettingsManager.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 13.5.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OJSSettingsManager : NSObject
{
    NSString *testi;

}


// use directly manager instead of settings object
//-(OJSSettings*) getSettings;


-(NSString*) getUsername;
-(NSString*) getDeviceName;
-(NSString*) getDeviceIdentity;

-(NSString*) getDeviceBTUUID;
-(NSString*) getDeviceBTMAC;

-(NSMutableData*) getDeviceCapabilities;


-(NSString*) getHostName;
-(NSString*) getHostPort;


@property (nonatomic, retain) NSUserDefaults *_userDefaults;

/*
 // these are loaded from ojs or from settings bundle
@property (nonatomic, retain) NSString *_username;
@property (nonatomic, retain) NSString *_password;

@property (nonatomic, retain) NSString *_deviceName;
@property (nonatomic, retain) NSString *_deviceIdentity;

@property (nonatomic, retain) NSString *_deviceBTUUID;
@property (nonatomic, retain) NSString *_deviceBTMAC;

@property (nonatomic, retain) NSMutableData *_capabilities;
*/

+ (id) settingsManager;


@end
