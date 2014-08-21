//
//  OJSHelpers.m
//  orchestrator.js
//
//  Created by Niko on 7.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

//#import <Foundation/Foundation.h>

@interface OJSHelpers : NSObject
+ (void) printFileToConsole: (NSString*) filePath;

@end

@implementation OJSHelpers

/*
+ (id)ojsHelpers {
    static OJSSettingsManager *settingsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingsManager = [[self alloc] init];
    });
    return settingsManager;
}

- (id)init {
    if (self = [super init]) {
        //someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
        
//        [self _loadSettings];
    }
    return self;
}*/



/*
- (NSString *) advertisingIdentifier
{
    if (!NSClassFromString(@"ASIdentifierManager")) {
        SEL selector = NSSelectorFromString(@"uniqueIdentifier");
        if ([[UIDevice currentDevice] respondsToSelector:selector]) {
            return [[UIDevice currentDevice] performSelector:selector];
        }
    }
    return nil; //[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}
*/

// Checks if values contains nil valu, and returns true if if does. Else returns false
+ (Boolean) checkForNils: (NSObject *) firstArg, ...
{
    va_list myargs;
    va_start(myargs, firstArg);
    for (NSObject *arg = firstArg; arg != nil; arg = va_arg(myargs, NSObject*))
    {
        if(arg == nil)
            return true;
    }
    va_end(myargs);
    return false;
}


+ (void) printFileToConsole: (NSString*) filePath
{
/*    FILE *file = fopen([filePath UTF8String], "r");
    char buffer[256];
    while (fgets(buffer, 256, file) != NULL){
        NSString* result = [NSString stringWithUTF8String:buffer];
        NSLog(@"%@",result);
    }
*/
    NSString *jscode = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSLog(jscode);
}


+ (NSString *) writeFile: (NSString *) fileName
{

    return nil;
}



@end