/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */


#import "../AmazonServiceRequestConfig.h"



/**
 * Copy Image Request
 */

@interface EC2CopyImageRequest:AmazonServiceRequestConfig

{
    NSString *sourceRegion;
    NSString *sourceImageId;
    NSString *name;
    NSString *descriptionValue;
    NSString *clientToken;
}




/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;

/**
 * The value of the SourceRegion property for this object.
 */
@property (nonatomic, retain) NSString *sourceRegion;

/**
 * The value of the SourceImageId property for this object.
 */
@property (nonatomic, retain) NSString *sourceImageId;

/**
 * The value of the Name property for this object.
 */
@property (nonatomic, retain) NSString *name;

/**
 * The value of the Description property for this object.
 */
@property (nonatomic, retain) NSString *descriptionValue;

/**
 * The value of the ClientToken property for this object.
 */
@property (nonatomic, retain) NSString *clientToken;

/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;


@end
