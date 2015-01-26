//
//  IQLog.h
//  IQ 300
//
//  Created by Tayphoon on 16.01.15.
//
//

#import "lcl.h"

#define IQLogComponent lcl_cApp

#define IQLogCritical(...)                                                              \
lcl_log(IQLogComponent, lcl_vCritical, @"" __VA_ARGS__)

#define IQLogError(...)                                                                 \
lcl_log(IQLogComponent, lcl_vError, @"" __VA_ARGS__)

#define IQLogWarning(...)                                                               \
lcl_log(IQLogComponent, lcl_vWarning, @"" __VA_ARGS__)

#define IQLogInfo(...)                                                                  \
lcl_log(IQLogComponent, lcl_vInfo, @"" __VA_ARGS__)

#define IQLogDebug(...)                                                                 \
lcl_log(IQLogComponent, lcl_vDebug, @"" __VA_ARGS__)

#define IQLogTrace(...)                                                                 \
lcl_log(IQLogComponent, lcl_vTrace, @"" __VA_ARGS__)

/**
 Log Level Aliases
 
 These aliases simply map the log levels defined within LibComponentLogger to something more friendly
 */
#define IQLogLevelOff       lcl_vOff
#define IQLogLevelCritical  lcl_vCritical
#define IQLogLevelError     lcl_vError
#define IQLogLevelWarning   lcl_vWarning
#define IQLogLevelInfo      lcl_vInfo
#define IQLogLevelDebug     lcl_vDebug
#define IQLogLevelTrace     lcl_vTrace

/**
 Alias the LibComponentLogger logging configuration method. Also ensures logging
 is initialized for the framework.
 
 Expects the name of the component and a log level.
 
 Examples:
 
 // Log debugging messages from the Network component
 RKLogConfigureByName("App", RKLogLevelDebug);
 
 // Log only critical messages from the Object Mapping component
 RKLogConfigureByName("App", RKLogLevelCritical);
 */
#define IQLogConfigureByName(name, level)                                               \
lcl_configure_by_name(name, level);

/**
 Alias for configuring the LibComponentLogger logging component for the App. This
 enables the end-user of Teameter to leverage IQLog() to log messages inside of
 their apps.
 */
#define IQLogSetAppLoggingLevel(level)                                                  \
lcl_configure_by_name("App", level);
