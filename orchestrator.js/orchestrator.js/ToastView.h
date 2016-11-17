//
//  ToastView.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 9.12.2015.
//  Copyright © 2015 Niko Mäkitalo. All rights reserved.
//
//  Usage: [ToastView showToastInParentView:self.view withText:@"What a toast!" withDuaration:5.0];
//
//


#import <UIKit/UIKit.h>

@interface ToastView : UIView

extern const float TOAST_DURATION_LONG;
extern const float TOAST_DURATION_SHORT;

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;

@end