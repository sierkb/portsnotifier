#import "PNController.h"
#import "PNPortWrapper.h"
#import "PNPortsManager.h"
#import "PNPortInfo.h"
#import "PNDefines.h"
#import "SecurityFoundation/SFAuthorization.h"
#import "PNPrefsWindowController.h"

#import "stdio.h"

@implementation PNController

- (id)init
{
	[super init];
	portsManager = [[PNPortsManager alloc] init];
	queryPortsTimer = nil;
	return self;
}

- (void) dealloc
{
	[portsManager release];
	if(queryPortsTimer)
		[queryPortsTimer release];
		
	[super dealloc];
}

- (void) awakeFromNib
{
	// set status bar icon
	NSLog(@"PCController awakeFromNib: set status bar.");
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem retain];

    //[statusItem setTitle: NSLocalizedString(@"Tablet",@"")];
	[statusItem setImage:[NSImage imageNamed:@"StatusBarLogo.png"]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:statusMenu];

	// set interval NSPopUpButton in Preferences window
	[intervalMenu selectItemWithTag:[self queryOutdatedIntervalAsMinutes]];
	
	// set About menu item target and action
	// doing this here avoids having to create a NSApplication delegate in MainMenu.nib
	[[statusMenu itemWithTag:1002] setTarget:NSApp];
	[[statusMenu itemWithTag:1002] setAction:@selector(orderFrontStandardAboutPanel:)];
	
	// query for start up
	[self queryByTimer:nil];
	unsigned intervalSeconds = [self queryOutdatedIntervalAsMinutes] * 60;
	[self doQueryPortsLoop:intervalSeconds];
	//[self queryOutdatedPortsInThread:nil];
}	

- (void)doQueryPortsLoop:(NSTimeInterval)interval
{
	if(queryPortsTimer != nil){
		[queryPortsTimer invalidate];
		[queryPortsTimer release];
	}
	
	queryPortsTimer = [[NSTimer scheduledTimerWithTimeInterval:interval 
		target:self selector:@selector(queryByTimer:) 
		userInfo:nil repeats:YES] retain];
}

- (void)queryByTimer:(id)anObject
{
	[NSThread detachNewThreadSelector:@selector(queryOutdatedPortsInThread:) 
			toTarget:self withObject:nil];
}

- (void)queryOutdatedPortsInThread:(id)argument
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"get outdated ports in thread\n");

	[self queryPortsAndSetMenu];
	[pool release];
}

- (void)queryPortsAndSetMenu
{
	BOOL isInstalled = [PNPortWrapper isMacPortsInstalled];
	if(isInstalled == FALSE){
		[statusItem setImage:[NSImage imageNamed:@"StatusBarLogoNoAvailable"]];
		[[statusMenu itemAtIndex:0] setAction:NULL];
	}else{
		[portsManager updatePorts];
		unsigned portsCount;
		portsCount = [portsManager portsCount];
		NSLog(@"set status item's title");
		if(portsCount > 0)
			[statusItem setTitle:[NSString stringWithFormat:@"%d", portsCount]];
		else
			[statusItem setTitle:@""];
	
		[self updateStatusMenuWithPorts];
	}
}

- (IBAction)syncPorts:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(doSyncInThread:) toTarget:self withObject:nil];
}

- (void)doSyncInThread:(id)anObject
{
	NSLog(@"In thread sync");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *syncing = @"Syncing...";
	NSMenuItem *syncMenuItem = [statusMenu itemAtIndex:0];
	if([[syncMenuItem title] isEqualToString:syncing]){
		NSLog(@"It is being synced");
		goto finish;
	}
	
	[syncMenuItem setTitle:syncing];
	[portsManager lock];
	char const *arguments[] = {NULL};
	NSApplicationDirectory;
	[PNPortWrapper executeByRoot:PN_HELPER_PATH withArgs:arguments];
	[portsManager unlock];
	[syncMenuItem setTitle:@"Sync now"];
	
	[self queryPortsAndSetMenu];
	
finish:
	[pool release];
}

- (void) updateStatusMenuWithPorts
{
	//unsigned startPos = 2;
	unsigned i;
	while(1){
		NSMenuItem *item = [statusMenu itemAtIndex:1];
		if(item == nil)
			break;
		if([item tag] == 1)
			break;
		
		NSMenu *submenu = [item submenu];
		if(submenu != nil){
				NSArray *itemArray = [submenu itemArray];
				unsigned subCount = [itemArray count];
				for( i = 0; i < subCount ; i++){
					[submenu removeItem:[itemArray objectAtIndex:i]];
				}
		}
		NSLog(@"Delete menu");
		//NSLog(@"%@",[item title]);
		[statusMenu removeItemAtIndex:1];
		//[item release];
	}
	
	
	NSArray *outdatedPorts = [portsManager ports];
	unsigned maxMenuItem = 3;
	unsigned startInsertPos = 2;
	unsigned count = [outdatedPorts count];
	
	if(count == 0)
		return;
		
	unsigned displayCount = count > maxMenuItem ? maxMenuItem : count;
	unsigned leftCount = count - displayCount;
	

	NSMenuItem *sp = [NSMenuItem separatorItem];
	[statusMenu insertItem:sp atIndex:1];	
	for( i = 0; i < displayCount; i++){
		PNPortInfo *port = [outdatedPorts objectAtIndex:i];
		NSMutableString *title = [NSMutableString stringWithFormat:@"%@ %@ < %@",
						[port title],
						[port oldVersion],
						[port newVersion]];
						
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
		[statusMenu insertItem:item atIndex:startInsertPos];
	}
	
	if(leftCount > 0){
		NSMenuItem *viewMoreMenuItem = [[NSMenuItem alloc] initWithTitle:@"View more outdated" action:NULL keyEquivalent:@""];
		NSMenu *subMenu = [[NSMenu alloc] init];
		[viewMoreMenuItem setSubmenu:subMenu];
		[statusMenu insertItem:viewMoreMenuItem atIndex: maxMenuItem + startInsertPos];
		
		for( ; i < count; i++ ){
			PNPortInfo *port = [outdatedPorts objectAtIndex:i];
			NSMutableString *title = [NSMutableString stringWithFormat:@"%@ %@ < %@",
				[port title],
				[port oldVersion],
				[port newVersion]];
			
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
			[subMenu insertItem:item atIndex:0];
		}
	}
}

- (IBAction)goPortsNotifierSite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://portsnotifier.sourceforge.net"]];
}

- (IBAction)goDonateSite:(id)sender
{

}

- (IBAction)goMacPortsOrg:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.macports.org"]];
}

- (NSString *)queryOutdatedIntervalAsString
{
	return [intervalMenu itemTitleAtIndex:[intervalMenu indexOfItemWithTag:[self queryOutdatedIntervalAsMinutes]]];
}

- (unsigned)queryOutdatedIntervalAsMinutes
{
	unsigned defaultInterval = 30; // minutes;
	
	NSString *path = [NSString stringWithCString:PN_LAUNCHD_PLIST]; // Assume this is a path to a valid plist.
	NSData *plistData;
	NSString *error;
	NSPropertyListFormat format;
	id plist;
	plistData = [NSData dataWithContentsOfFile:path];
	
	plist = [NSPropertyListSerialization propertyListFromData:plistData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&error];
	if(!plist)
	{
		NSLog(@"Error reading plist");
		NSLog(error);
		[error release];
	}
	
	NSNumber *interval = [plist valueForKey:@"StartInterval"];
	//NSLog(@"Interval: %d", [interval intValue]);
	if(interval == nil)
		return defaultInterval;
	
	return [interval intValue] / 60;
}

- (IBAction) savePreferences:(id)sender
{
	NSLog(@"Save preferences");
	NSLog(@"Get interval: %@", [[intervalMenu selectedItem] title]);

	char const*argv[] = {"-i", [[NSString stringWithFormat:@"%d", [intervalMenu selectedTag]] cString], NULL};
	[PNPortWrapper executeByRoot:PN_HELPER_PATH withArgs:argv];
}

- (NSArray*) availableIntervals
{
	return [NSArray arrayWithObjects:@"10 minutes", @"20 minutes", @"30 minutes", @"1 hour",
		@"2 hours", @"1 day", nil];
}

- (IBAction)orderFrontPreferencePanel:(id)sender {
	[[PNPrefsWindowController sharedPrefsWindowController] showWindow:self];
}

@end
