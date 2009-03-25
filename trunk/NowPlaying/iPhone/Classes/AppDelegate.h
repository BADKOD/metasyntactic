// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@interface AppDelegate : NSObject<UIApplicationDelegate> {
@private
    IBOutlet UIWindow* window;
    ApplicationTabBarController* tabBarController;
    NotificationCenter* notificationCenter;

    Pulser* minorRefreshPulser;
    Pulser* majorRefreshPulser;

    UIView* globalActivityView;
}

@property (readonly, nonatomic, retain) UIWindow* window;
@property (readonly, retain) ApplicationTabBarController* tabBarController;
@property (readonly, retain) NotificationCenter* notificationCenter;

+ (AppDelegate*) appDelegate;

+ (void) minorRefresh;
+ (void) majorRefresh;
+ (void) majorRefresh:(BOOL) force;

+ (UIWindow*) window;
+ (UIView*) globalActivityView;

+ (NotificationCenter*) notificationCenter;

+ (void) addNotification:(NSString*) notification;
+ (void) addNotifications:(NSArray*) notifications;
+ (void) removeNotification:(NSString*) notification;
+ (void) removeNotifications:(NSArray*) notifications;

@end