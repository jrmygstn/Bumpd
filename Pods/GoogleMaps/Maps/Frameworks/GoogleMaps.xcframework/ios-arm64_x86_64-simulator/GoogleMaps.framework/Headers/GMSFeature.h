//
//  GMSFeature.h
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

NS_ASSUME_NONNULL_BEGIN

/** Identifiers for feature types of data-driven styling features. */
NS_SWIFT_NAME(FeatureType) typedef NSString *GMSFeatureType NS_TYPED_EXTENSIBLE_ENUM;

FOUNDATION_EXPORT GMSFeatureType const GMSFeatureTypeAdministrativeAreaLevel1;
FOUNDATION_EXPORT GMSFeatureType const GMSFeatureTypeAdministrativeAreaLevel2;
FOUNDATION_EXPORT GMSFeatureType const GMSFeatureTypeCountry;
FOUNDATION_EXPORT GMSFeatureType const GMSFeatureTypeLocality;
FOUNDATION_EXPORT GMSFeatureType const GMSFeatureTypePostalCode;

/**
 * An interface representing a feature's metadata.
 *
 * Do not save a reference to a particular feature object because the reference will not be stable.
 */
NS_SWIFT_NAME(Feature)
@protocol GMSFeature <NSObject>

/** Type of this feature. */
- (GMSFeatureType)featureType;

@end

NS_ASSUME_NONNULL_END
