//
//  OJSCoordinationController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 21.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJSCoordinationController.h"

#import "OJSBLEScanner.h"

// Move this to settings
double CONTEXT_REPORT_INTERVAL = 1;

// Private propersties here
@interface OJSCoordinationController ()

@property NSTimer* contextReportTimer;

@property OJSBLEScanner *bb;

@property NSMutableDictionary* previousResults;

@end



@implementation OJSCoordinationController



- (id) init
{
    self = [super init];
    if (self) {
        
        _ojsConnection = [[OJSConnection alloc] init];
        
        _settingsManager = [[OJSSettingsManager alloc] init];
        _ojsPeripheral = [[OJSPeripheral alloc] init];
        _actionController = [[OJSActionController alloc] init];
        
        // use setter for this
        _mainUIView = nil;
        
        // begin to advertise and act as peripheral
        [_ojsPeripheral initBLEPeripheral: _actionController];
        
        
    }
    return self;
}



- (void) initOJS
{
    [_ojsConnection initOJS:_actionController];
    [_actionController initCapabilities];
    
    [self initPeriodicalContextDataReporting];
}


- (void) disconnectOJS
{
    [_ojsConnection disconnectOJS];
    
    
    [_bb stopScan];
    _bb = nil;
    [self cancelPeriodicalContextDataReporting];
}


- (void) initScan
{
    if(_ojsConnection == nil || !_ojsConnection.IS_CONNECTED)
        return;
    
    _previousResults = [[NSMutableDictionary alloc]init];
    _bb = [[OJSBLEScanner alloc] init];
    [_bb initScan];
    
    /*
     NSMutableArray *devices = [[NSMutableArray alloc]init];
     [devices addObject:@[@"84:B1:53:F0:39:96",@"-90"]];
     [devices addObject:@[@"D0:E7:82:08:66:06",@"-60"]];
     
     NSMutableDictionary* mm = [[NSMutableDictionary alloc]init];
     [mm setObject:devices forKey:@"bt_devices"];
     
     [_ojsConnection sendContextData:mm];
     */
}


- (void) initPeriodicalContextDataReporting
{
    _contextReportTimer = [NSTimer scheduledTimerWithTimeInterval:CONTEXT_REPORT_INTERVAL target:self selector:@selector(reportContextData) userInfo:nil repeats:YES];
}


- (void) reportContextData
{
    
    if( _ojsConnection != nil && _bb != nil ) {
        
        [_bb stopScan];
        
        NSMutableDictionary* mm = [_previousResults copy];
        
        NSMutableArray* devices = [[NSMutableArray alloc] init];
        for (NSString* serviceUUID in _bb.scanResults) {
            
            NSArray* RSSIs = [_bb.scanResults objectForKey:serviceUUID];
            float tempRSSI = 0; //[RSSIs valueForKeyPath:@"avg"];
            
            int i;
            for ( i = 0; i < [RSSIs count]; i++ ) {
                NSNumber* t = (NSNumber*)[ [_bb.scanResults objectForKey:serviceUUID] objectAtIndex:i];
                tempRSSI += [t floatValue];
            }
            
            float pp = [RSSIs count];
            tempRSSI = tempRSSI / pp;
            
            // some times, for some reason gets value of positive 127 -> use -35 instead..
            if (tempRSSI > 0) {
                if([_previousResults objectForKey:serviceUUID] != nil) {
                    tempRSSI = [[_previousResults objectForKey:serviceUUID] floatValue];
                } else {
                    tempRSSI = -35;
                }
            }
            [_previousResults setObject:[NSNumber numberWithFloat:tempRSSI] forKey:serviceUUID];
            [devices addObject:@[serviceUUID, [NSNumber numberWithFloat:tempRSSI]]];
        }
        
        // Correct occasionally missing results:
        //      If a device was not in results, use one time value from prev.results, then nil its value for prev.results
        for (id prevResServiceUUID in mm) {
            if ([mm objectForKey:prevResServiceUUID] != nil) {
                BOOL deviceMissing = TRUE;
                for (int i = 0; i < [devices count]; i++) {
                    if([devices objectAtIndex:i] != nil && [[devices objectAtIndex:i] count] > 0 && [[devices objectAtIndex:i] objectAtIndex:1] != nil) {
                        deviceMissing = FALSE;
                    }
                }
                
                if(deviceMissing) {
                    [devices addObject:@[prevResServiceUUID, [mm objectForKey:prevResServiceUUID]]];
                    [_previousResults removeObjectForKey:prevResServiceUUID];
                }
            }
        }
        
        
        
        NSMutableDictionary* reportData = [[NSMutableDictionary alloc]init];
        [reportData setObject:devices forKey:@"bt_devices"];
        
        [_ojsConnection sendContextData:reportData];
        
        
        _bb = [[OJSBLEScanner alloc] init];
        [_bb initScan];
    }
}



/*
- (void) reportContextData
{
    
    if( _ojsConnection != nil && _bb != nil ) {
        
        [_bb stopScan];
        
        NSMutableArray* devices = [[NSMutableArray alloc] init];
        for (NSString* serviceUUID in _bb.scanResults) {
            
            NSArray* RSSIs = [_bb.scanResults objectForKey:serviceUUID];
            float tempRSSI = 0; //[RSSIs valueForKeyPath:@"avg"];
            
            int i;
            for ( i = 0; i < [RSSIs count]; i++ ) {
                NSNumber* t = (NSNumber*)[ [_bb.scanResults objectForKey:serviceUUID] objectAtIndex:i];
                tempRSSI += [t floatValue];
            }
            
            float pp = [RSSIs count];
            tempRSSI = tempRSSI / pp;
            
            // some times, for some reason gets value of positive 127 -> use -35 instead..
            if (tempRSSI > 0) {
                tempRSSI = -35;
            }
            
            [devices addObject:@[serviceUUID, [NSNumber numberWithFloat:tempRSSI]]];
        }
        NSMutableDictionary* mm = [[NSMutableDictionary alloc]init];
        [mm setObject:devices forKey:@"bt_devices"];
        
        [_ojsConnection sendContextData:mm];
        
        
        _bb = [[OJSBLEScanner alloc] init];
        [_bb initScan];
    }
}

*/



- (void) cancelPeriodicalContextDataReporting
{
    [_contextReportTimer invalidate];
}



@end