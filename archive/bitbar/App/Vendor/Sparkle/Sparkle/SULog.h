/*
 *  SULog.h
 *  EyeTV
 *
 *  Created by Uli Kusterer on 12/03/2009.
 *  Copyright 2008 Elgato Systems GmbH. All rights reserved.
 *
 */

/*
	Log output for troubleshooting Sparkle failures on end-user machines.
	Your tech support will hug you if you tell them about this.
*/

#ifndef SULOG_H
#define SULOG_H

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#include <Foundation/Foundation.h>


// -----------------------------------------------------------------------------
//	Prototypes:
// -----------------------------------------------------------------------------

void SUClearLog(void);
void SULog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

#endif
