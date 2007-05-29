/* PNPerferencesPanel */

#import <Cocoa/Cocoa.h>
#import "PNController.h"

@interface PNPerferencesPanel : NSPanel
{
    IBOutlet NSComboBox *intervalBox;
	IBOutlet PNController *controller;
}
@end
