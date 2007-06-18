//
//  PNConsole.h
//  PortsNotifier
//
//  Created by eddyxu@gmail.com on 07-6-19.
//  Copyright 2007 PortsNotifier.sourceforge.net . All rights reserved.
//

#import <Cocoa/Cocoa.h>

// store the result and output data of a unix command
@interface PNConsoleResult : NSObject {
	OSStatus status;
	NSMutableData *outputData;
}

-(id) initWithValue:(OSStatus)aStatus andData:(NSData*)aData;
-(OSStatus) status;
-(void) setStatus:(OSStatus)aStatus;
-(NSData*) outputData;
-(void) setOutputData:(NSData*)aNewData;

@end

// Unix console wrapper
@interface PNConsole : NSObject {

}

+(PNConsoleResult *) execute:(NSString*)aCommand withArgs:(NSArray*)args;
+(PNConsoleResult *) executeWithPrivileges:(NSString*)aCommand withArgs:(NSArray *)args;
@end
