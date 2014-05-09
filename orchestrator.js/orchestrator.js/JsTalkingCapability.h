//
//  JsTalkingCapability.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 16.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//
#import <JavaScriptCore/JavaScriptCore.h>
#import <Foundation/Foundation.h>

@protocol JsTalkingCapabilityJSExports <JSExport>
@property (nonatomic, copy) NSString *name;
@end

@interface JsTalkingCapability : NSObject <JsTalkingCapabilityJSExports>

@property (nonatomic, copy) NSString *say;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger number;

@end


@implementation JsTalkingCapability
- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %d", self.name, self.number];
}

- (NSString *)say:(NSString*)line {
 NSLog(@"saying..");
 return @"jepulis";
}
@end



