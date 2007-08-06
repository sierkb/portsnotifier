/* PNController */

#import <Cocoa/Cocoa.h>

/*
	Main Controller for Ports Notifier App
*/
@interface PNController : NSObject
{
    IBOutlet id portsManager;	
    IBOutlet NSStatusItem *statusItem;
    IBOutlet NSMenu *statusMenu;
	IBOutlet NSPanel *preferencePanel;
	IBOutlet NSPopUpButton *intervalMenu;
	
	NSTimer *queryPortsTimer;
	
	unsigned _queryOutdatedIntervalInMinutes;
}

- (void)doSyncInThread:(id)anObject;
- (void)queryByTimer:(id)anObject;
- (void)queryOutdatedPortsInThread:(id)argument;
- (void)queryPortsAndSetMenu;
- (void)doQueryPortsLoop:(NSTimeInterval)interval;

- (IBAction)syncPorts:(id)sender;
- (void) updateStatusMenuWithPorts;

/// go to associated sites
- (IBAction)goPortsNotifierSite:(id)sender;
- (IBAction)goDonateSite:(id)sender;
- (IBAction)goMacPortsOrg:(id)sender;

- (unsigned)queryOutdatedIntervalAsMinutes;
- (NSString *)queryOutdatedIntervalAsString;
- (IBAction)savePreferences:(id)sender;
- (NSArray *)availableIntervals;

@end
