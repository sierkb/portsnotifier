/*
 *  PortsHelper.c
 *  PortsNotifier
 *
 *  Created by lei.xu@gmail.com on 07-5-25.
 *  Copyright 2007 xulei.org All rights reserved.
 *
 *  PortsNotifier is released under BSD License
 */

#include <CoreFoundation/CoreFoundation.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

#define PN_PORT_PATH "/opt/local/bin/port"

int pn_is_ports_installed(void)
{
	return access(PN_PORT_PATH, F_OK) < 0 ? 0 : 1;
}

int pn_sync_ports(void)
{
	if(!pn_is_ports_installed())
		return 1;
		
	return system("/opt/local/bin/port selfupdate");
}

int pn_write_plist(int interval)
{
	if(interval < 0) 
		return -1;
		
	//CFStringRef names[2];
	return 0;
}

void pn_usage(void)
{
	printf("PortsHelper -- Helper for PortsNotifier\n");
	printf("Usage: PortsHelper [OPTIONS]\n");
	printf("Options:\n");
	printf("-i <minutes>\t\tsetting the interval of calling helper by launchd\n");
	printf("-h\t\t\tdisplay this help\n");
	printf("\nIf no options be provided, PortsHelper will do \"port sync\"\n");
}

int main(int argc, char * const argv[])
{
	int ch, ret;
	
	while((ch = getopt(argc, argv, "hi:")) != -1){
		switch (ch) {
		case 'h':
			pn_usage();
			exit(0);
			break;
		case 'i':
			ret = pn_write_plist(atoi(optarg));
			return ret;	
			break;
		case '?':
		default:
			pn_usage();
			exit(0);
			break;
		}
	}
	
	argc -= optind;
	argv += optind;
	
	return pn_sync_ports();
}

