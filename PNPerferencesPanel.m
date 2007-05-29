#import "PNPerferencesPanel.h"

@implementation PNPerferencesPanel

-(void) awakeFromNib
{
	unsigned interval = [controller intervalMinutes];
	int comboIndex = 0;
	switch (interval) {
	case 10:
		comboIndex = 0;
		break;
	case 20:
		comboIndex = 1;
		break;
	case 30:
		comboIndex = 2;
		break;
	case 60:
		comboIndex = 3;
		break;
	case 120:
		comboIndex = 4;
		break;
	case 24*60:
		comboIndex = 5;
	default:
		break;
	}
	
	NSLog(@"select interval at index:%d", comboIndex);
	[intervalBox selectItemAtIndex:comboIndex];
}
@end
