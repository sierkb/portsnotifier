/* PNController */

#import <Cocoa/Cocoa.h>

@interface PNController : NSObject
{
    IBOutlet id portsManager;
    IBOutlet NSStatusItem *statusItem;
    IBOutlet NSMenu *statusMenu;
	IBOutlet NSPanel *preferencePanel;
	IBOutlet NSTextField *intervalField;
	
	NSTimer *queryPortsTimer;
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
- (void)goURL:(NSString *)urlString;

- (unsigned) intervalMinutes;
- (NSString *) intervalMinutesString;
- (IBAction) savePreferences:(id)sender;
- (NSArray *)availableIntervals;
@end
