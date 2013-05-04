//
//  Constants.h
//  MyM
//
//  Created by Steven Zilberberg on 3/30/13.
//  Copyright (c) 2013 MyM Co. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kS3BUCKETNAME;

enum{
    kTAGMOMENTTEXT = 1,
    kTAGMOMENTPICTURE = 2,
    kTAGMOMENTVIDEO = 3,
    kTAGMOMENTAUDIO = 4
}kTagMomentType;

enum{
    kUIACTIONSHEETTAGSTANDARD,
    kUIACTIONSHEETTAGPICTURE,
    kUIACTIONSHEETTAGVIDEO,
    kUIACTIONSHEETTAGAUDIO
}kUIActionSheetTag;

enum{
    kSAVEDBUTTONINDEX,
    kTAKEMEDIA
}kUIActionSheetButtonIndexes;

enum{
    kUIAlertSettingsStandard,
    kUIAlertSettingsConfirmChangePassword,
    kUIAlertSettingsConfirmChangeEmail,
    kUIAlertSettingsVerifyPassword,
    kUIAlertSettingsVerifyEmail,
    kUIAlertDeleteAccount
}kUIAlertSetting;

enum{
    kUIAlertViewMomentNoCamera = -999
}kUIAlertViewMoment;

@interface Constants : NSObject

@end
