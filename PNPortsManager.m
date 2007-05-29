#import "PNPortsManager.h"
#import "PNPortWrapper.h"

@implementation PNPortsManager

-(id)init
{
	[super init];
	
	ports =	[[NSMutableArray alloc] init];
	lock = [[NSRecursiveLock alloc] init];
	return self;
}

- (void) dealloc {
	[lock lock];
	[ports release];
	[lock unlock];
	
	[lock release];
	[super dealloc];
}

- (void) lock
{
	[lock lock];
}

- (void) unlock
{
	[lock unlock];
}

-(BOOL) isMacPortsInstalled
{
	return [PNPortWrapper isMacPortsInstalled];
}

-(NSArray*) ports
{
	return ports;
}

-(unsigned) portsCount
{
	unsigned pc = 0;
	if(ports){
		[lock lock];
		pc = [ports count];
		[lock unlock];
	}
	
	return pc;
}

-(void) updatePorts
{
	NSArray *outdatedPorts = [PNPortWrapper getAllOutdatedPorts];
	[self clearPorts];
	
	[lock lock];
	[ports addObjectsFromArray:outdatedPorts];
	[lock unlock];
	[outdatedPorts release];
}

- (void) clearPorts
{
	
	[lock lock];
	unsigned totalPorts = [ports count];
	unsigned i;
	
	
	for( i=0 ; i < totalPorts; i++){
		PNPortInfo *info = [ports objectAtIndex:i];
		[info release];
	}
	
	[ports removeAllObjects];
	[lock unlock];
}

@end
