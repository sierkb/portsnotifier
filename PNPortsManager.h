/* PNPortsManager */

#import <Cocoa/Cocoa.h>
#import "PNPortInfo.h"

@interface PNPortsManager : NSObject
{
		NSMutableArray *ports;
		NSRecursiveLock *lock;
}
- (unsigned) portsCount;
- (NSArray*) ports;
- (void)updatePorts;
- (void)clearPorts;
- (void)lock;
- (void)unlock;
@end
