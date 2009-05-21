//
//  PNPrefsWindowController.m
//  PortsNotifier
//
//  Created by Lei Xu on 09-5-7.
//  Copyright 2009 Quarkware.com. All rights reserved.
//

#import "PNPrefsWindowController.h"

@implementation PNPrefsWindowController

-(void) setupToolbar
{
	[self addView:generalPreferences label:@"General"];
	//[self addView:pluginsPreferences label:@"Advanced"];
	
	currentPanel = @"General";
}


- (NSString *)currentPaneIdentifier
{
	return currentPanel;
}

- (void)setCurrentPaneIdentifier:(NSString *)identifier
{
	currentPanel = identifier;
}

@end
