/*
 * MyM: Map Your Moments "A Digital Travelogue"
 *
 * Developed using iOS and AWS for CSC Special Topics: Cloud Computing, Spring 2013 by
 * Adam Cumiskey, Dave Hand, Tim Honeywell, Marcelo Mazzotti, Justin Wagner, and Steven Zilberberg
 *
 * Constants.h
 * 
 *
 */

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
    kUIAlertDeleteAccount,
    kUIAlertConfirmDeleteAccount
}kUIAlertSetting;

enum{
    kUIAlertViewMomentNoCamera = -999
}kUIAlertViewMoment;

@interface Constants : NSObject

@end
