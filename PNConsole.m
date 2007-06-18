//
//  PNConsole.m
//  PortsNotifier
//
//  Created by eddyxu@gmail.com on 07-6-19.
//  Copyright 2007 portsnotifier.sourceforge.net. All rights reserved.
//

#import "PNConsole.h"

@implementation PNConsoleResult 

- (id) init
{
	[super init];
	status = 0;
	outputData = [NSMutableData data];
	[outputData retain];
	return self;
}

- (id) initWithValue:(int)aValue andData:(NSData*)aData
{
	[super init];
	status = aValue;
	outputData = [NSMutableData dataWithData:aData];
	[outputData retain];
	return self;
}

@end

@implementation PNConsole

@end
