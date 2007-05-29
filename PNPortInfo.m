#import "PNPortInfo.h"

@implementation PNPortInfo

-(id)initWithTitle:(NSString*)aTitle oldVersion:(NSString*)aOldVersion 
	newVersion:(NSString *)aNewVersion
{
	[super init];
	title = aTitle;
	oldVersion = aOldVersion;
	newVersion = aNewVersion;
	return self;
}

-(id)initWithString:(NSString*)aLine
{
	[super init];
	//NSArray *arr = [aLine componentsSeparatedByString:@"\n"];
	NSRange portNameRange = [aLine rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSRange titleRange = {0, portNameRange.location};
	@try {
		title = [aLine substringWithRange:titleRange];
		[title retain];
	}
	@catch (NSException * e) {
		title = nil;
		return self;
	}
	@finally {
		
	}
		
	NSLog(@"Title: [%@]", title);
	
	NSString *versionString = [aLine substringFromIndex:portNameRange.location];
	NSRange oldVersionStart = [versionString rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
	NSRange oldVersionEnd = [versionString rangeOfString:@" < "];
	NSRange oldVersionRange = {oldVersionStart.location, oldVersionEnd.location - oldVersionStart.location};
	@try{
		oldVersion = [versionString substringWithRange:oldVersionRange];
		NSLog(@"[%@]", oldVersion);
		[oldVersion retain];
	}@catch(NSException *e){
		oldVersion = nil;
		return self;
	}
	
	NSString * newVersionString = [versionString substringFromIndex: oldVersionEnd.location + oldVersionEnd.length];
	newVersion = [newVersionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSLog(@"[%@]", newVersion);
	[newVersion retain];
	
	return self;
}

- (void) dealloc {
	[title release];
	[oldVersion release];
	[newVersion release];
	[super dealloc];
}


-(NSString*) title
{
	return title;
}

- (void) setTitle:(NSString*) aTitle
{
	if(title != aTitle)
		[title release];
	
	title = aTitle;
}

-(NSString*) oldVersion
{
	return oldVersion;
}

- (void) setOldVersion:(NSString*) aOldVersion
{
	if(oldVersion != aOldVersion)
		[oldVersion release];
		
	oldVersion = aOldVersion;
}

-(NSString*) newVersion
{
	return newVersion;
}

- (void) setNewVersion:(NSString*) aNewVersion
{
	if(newVersion != aNewVersion)
		[newVersion release];
		
	newVersion = aNewVersion;
}

- (BOOL) isAvailable
{
	return title != nil && newVersion != nil && oldVersion != nil;
}

@end
