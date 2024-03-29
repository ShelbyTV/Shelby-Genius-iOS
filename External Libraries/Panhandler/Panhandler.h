//
//  Panhandler.h
//  Panhandler
//
//  Created by Arthur Ariel Sabintsev at Shelby.tv on 4/15/12.
//  Copyright (c) 2012 ArtSabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 

 Panhandler Configuttion Instructions
 
 - Add #import "Panhandler.h" to your class(es).
 
 - Configure the following macros in Panhandler.h:
 
 PanhandlerAppleID, 
 PanhandlerTrigger, 
 PanhandlerRetrigger, 
 PanhandlerDebugMode
 
 - Optionally, you may want to customize the following UIAlertView strings in Panhandler.h:
 
 PanhandlerAlertTitle
 PanhandlerAlertMessage
 PanhandlerNoMessage
 PanhandlerYesMessage
 PanhandlerRemindMeLaterMessage
 
 - Record an event by adding one of the following messages to a signficant event:
 
 // Event tracking method (adds +1 towards goals defined by trigger macros)
 [Panhandler sharedInstance] recordEvent]; 
 
 // Weighted event tracking method (adds value of 'weight' towards goals defined by triggers)
 [Panhandler sharedInstance] recordEventWithWeight:(NSUInteger)weight]; 
 
 - Once your users has performed enough of these events (condition defined by triggers), a UIAlertView will pop up, asking your users to rate and review your app.
*/


/* Required Configuration */
#define PanhandlerAppleID       @"556665733"        // Apple ID for your app
#define PanhandlerTrigger       20                  // Number (integer) of events needed for ratings reminder alert
#define PanhandlerRetrigger     20                  // Number (integer) of events needed to retrigger ratings reminder alert
#define PanhandlerDebugMode     NO                  // Set YES to show the alert every time. Set NO when shipping to App Store.

/* Optional Customization */
#define PanhandlerAlertTitle                    @"Thoughts to share?"
#define PanhandlerAlertMessage                  @"Please take a second to\nrate this app and tell us why\nyou enjoy Shelby Genius.\nYour feedback helps us improve. "
#define PanhandlerNoMessage                     @"No, thanks"
#define PanhandlerYesMessage                    @"Rate Shelby Genius"
#define PanhandlerRemindMeLaterMessage          @"I'll do it later"

@interface Panhandler : NSObject

- (void)recordEvent;                                // Event tracking method (adds +1 towards goals defined by trigger macros)
- (void)recordEventWithWeight:(NSUInteger)weight;   // Weighted event tracking method (adds value of weight towards goals defined by trigger macros)
+ (Panhandler*)sharedInstance;                      // Singleton class method

@end