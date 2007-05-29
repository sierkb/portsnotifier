/* PNPortWrapper */

#import <Cocoa/Cocoa.h>

@interface PNWrapperResult : NSObject
{
	OSStatus returnValue;
	NSMutableData *outputData;
}
- (id)initWithValue: (int)aValue andData:(NSData*) aData;

- (int) returnValue;
- (void) setReturnValue:(int)aValue;
- (NSData *)outputData;
- (void) setOutputData:(NSMutableData*)aData;
- (void) appendData:(NSData*)newData;
- (unsigned) dataLength;

@end


@interface PNPortWrapper : NSObject
{
}
+ (PNWrapperResult *)executeCommand:(NSString*)aCommand  withArgs:(NSArray*)arguments;
+ (OSStatus)executeByRoot:(char const*)aCommand withArgs:(char const**)arguments;
+ (BOOL) isMacPortsInstalled;
+ (NSArray*) getAllOutdatedPorts;

@end
