//
//  PNPrefsWindowController.h
//  PortsNotifier
//
//  Created by Lei Xu on 09-5-7.
//  Copyright 2009 Quarkware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"


@interface PNPrefsWindowController : DBPrefsWindowController {
	IBOutlet NSView *generalPreferences;
	IBOutlet NSView *pluginsPreferences;
	
	NSString *currentPanel;
}

@end
