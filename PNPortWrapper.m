#import "PNPortWrapper.h"
#import "PNPortInfo.h"
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

static NSString * PNPortPath = @"/opt/local/bin/port";

@implementation PNWrapperResult

- (id) init
{
	[super init];
	returnValue = 0;
	outputData = [NSMutableData data];
	[outputData retain];
	return self;
}

- (id) initWithValue:(int)aValue andData:(NSData*)aData
{
	[super init];
	returnValue = aValue;
	outputData = [NSMutableData dataWithData:aData];
	[outputData retain];
	return self;
}

- (void) dealloc {
	[outputData release];
	[super dealloc];
}

-(int)returnValue
{
	return returnValue;
}

- (void) setReturnValue:(int)aValue
{
	returnValue = aValue;
}

- (NSData*) outputData
{
	return outputData;
}

- (void) setOutputData:(NSMutableData*)aData
{
	if(outputData && outputData != aData)
		[outputData release];
		
	outputData = aData;
}

- (void) appendData:(NSData*)newData
{
	if(outputData == nil)
		outputData = [[NSMutableData alloc] init];
		
	[outputData appendData:newData];
}

- (unsigned) dataLength
{
	if(outputData)
		return [outputData length];
		
	return 0;
}

@end

@implementation PNPortWrapper

+ (PNWrapperResult *)executeCommand:(NSString*)aCommand  withArgs:(NSArray*)args
{
	NSTask *pipeTask = [[NSTask alloc] init];
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    NSData *inData = nil;
 
    // write handle is closed to this process
    [pipeTask setStandardOutput:newPipe];
    [pipeTask setLaunchPath: aCommand];
	if(args)
		[pipeTask setArguments:args];
    [pipeTask launch];
	[pipeTask waitUntilExit];
	
	PNWrapperResult *result = [[PNWrapperResult alloc] init];
    while ((inData = [readHandle availableData]) && [inData length]) {
        [result appendData:inData];
    }
	
	[result setReturnValue:[pipeTask terminationStatus]];
	
    [pipeTask release];
	
	return result;
}

+ (OSStatus)executeByRoot:(char const*)aCommand  withArgs:(char**)arguments
{
	OSStatus myStatus;
    AuthorizationFlags myFlags = kAuthorizationFlagDefaults;
    AuthorizationRef myAuthorizationRef;
	
	myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,// 3
                myFlags, &myAuthorizationRef);// 4
    if (myStatus != errAuthorizationSuccess)
        return myStatus;
	
	do
    {
        {
            AuthorizationItem myItems = {kAuthorizationRightExecute, 0,// 5
                    NULL, 0};// 6
            AuthorizationRights myRights = {1, &myItems};// 7
 
            myFlags = kAuthorizationFlagDefaults |// 8
                    kAuthorizationFlagInteractionAllowed |// 9
                    kAuthorizationFlagPreAuthorize |// 10
                    kAuthorizationFlagExtendRights;// 11
            myStatus = AuthorizationCopyRights (myAuthorizationRef,                     &myRights, NULL, myFlags, NULL );// 12
        }
		
		if (myStatus != errAuthorizationSuccess) break;
		
        {
            FILE *myCommunicationsPipe = NULL;
            char myReadBuffer[128];
			
            myFlags = kAuthorizationFlagDefaults;// 13
				myStatus = AuthorizationExecuteWithPrivileges(myAuthorizationRef, 
															  aCommand, myFlags, arguments, &myCommunicationsPipe);// 16
					
				if (myStatus == errAuthorizationSuccess)
					for(;;)
					{
						int bytesRead = read (fileno (myCommunicationsPipe),
											  myReadBuffer, sizeof (myReadBuffer));
						if (bytesRead < 1) break;
						write (fileno (stdout), myReadBuffer, bytesRead);
					}
        }
    } while (0);
		
    AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults);// 17
 
    return myStatus;

}

+ (BOOL) isMacPortsInstalled
{
	NSString *command = @"/bin/test";
	NSArray *args = [NSArray arrayWithObjects:@"-f", PNPortPath, nil];
	
	PNWrapperResult *result = [PNPortWrapper executeCommand:command withArgs:args];
	
	BOOL installed = FALSE;
	if([result returnValue] == 0)
		installed = TRUE;
		
	[result release];
	
	return installed;
}

+ (NSArray*) getAllOutdatedPorts
{
	NSArray *args = [NSArray arrayWithObjects:@"outdated", nil];
	PNWrapperResult *result = [PNPortWrapper executeCommand:PNPortPath withArgs:args];
	NSMutableArray *ports = [[NSMutableArray alloc] init];
	
	NSString *pipeBuffer = [NSString stringWithCString:[[result outputData] bytes]];
	NSArray *bufferLines = [pipeBuffer componentsSeparatedByString:@"\n"];
	[result release];
	
	NSLog(pipeBuffer);
	int portsCount = [bufferLines count] - 2;
	NSLog(@"Total %d outdated", portsCount);
	if(portsCount > 0){
		unsigned i; 
		for(i = 1; i <= portsCount; i++){
			NSLog(@"Add line at %d", i);
			NSString *aLine = [bufferLines objectAtIndex:i];
			PNPortInfo *info = [[PNPortInfo alloc] initWithString:aLine];
			if([info isAvailable])
				[ports addObject:info];
			else{
				[info release];
				break;
			}
		}
	}
		
	//[bufferLines release];
	NSLog(@"Ports count: %d", [ports count]);
	return ports;
}

@end
