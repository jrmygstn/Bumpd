//
//  GMSPlaceFeature.h
//  Google Maps SDK for iOS
//
//  Copyright 2022 Google LLC
//
//  Usage of this SDK is subject to the Google Maps/Google Earth APIs Terms of
//  Service: https://cloud.google.com/maps-platform/terms
//
/**
 *   This product or feature is in pre-GA. Pre-GA products and features might have limited support,
 *   and changes to pre-GA products and features might not be compatible with other pre-GA versions.
 *   Pre-GA Offerings are covered by the Google Maps Platform Service Specific Terms
 *   (https://cloud.google.com/maps-platform/terms/maps-service-terms).
 */

#import <Foundation/Foundation.h>


#import "GMSFeature.h"

NS_ASSUME_NONNULL_BEGIN

/** An interface representing a place feature (a feature with a Place ID). */
NS_SWIFT_NAME(PlaceFeature)
@interface GMSPlaceFeature : NSObject <GMSFeature>

@property(nonatomic, readonly) GMSFeatureType featureType;

@property(nonatomic, readonly) NSString *placeID;

/**
 * Create a place feature instance for testing uses.
 *
 * This method should be used for testing purposes only; GMSPlaceFeature instances should only be
 * created by the SDK in production code.
 */
- (instancetype)initWithFeatureType:(GMSFeatureType)featureType placeID:(NSString *)placeID;

- (instancetype)init NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
