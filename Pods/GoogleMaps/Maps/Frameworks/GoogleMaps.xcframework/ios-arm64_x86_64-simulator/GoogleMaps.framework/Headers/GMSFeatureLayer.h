//
//  GMSFeatureLayer.h
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

#import "GMSFeature.h"

@class GMSFeatureStyle;

NS_ASSUME_NONNULL_BEGIN

/** Styling block to return a deterministic style for any given feature. */
typedef GMSFeatureStyle *_Nullable (^GMSFeatureLayerStyleBlock)(id<GMSFeature>)
    NS_SWIFT_NAME(FeatureLayerStyle);

/**
 * A class representing a collection of all features of the same GMSFeatureType, whose style can be
 * overridden on the client. Each GMSFeatureType will have one corresponding GMSFeatureLayer.
 */
NS_SWIFT_NAME(FeatureLayer)
@interface GMSFeatureLayer : NSObject

/**
 * The feature type associated with this layer. All features associated with the layer will be of
 * this type.
 */
@property(nonatomic, readonly) GMSFeatureType featureType;

/**
 * Determines if the data-driven GMSFeatureLayer is available. Data-driven styling requires
 * the Metal Framework, a valid map ID and that the feature type be applied.
 * If false, styling for the GMSFeatureLayer returns to the default and events are not triggered.
 */
@property(nonatomic, readonly, getter=isAvailable) BOOL available;

/**
 * Styling block to be applied to all features in this layer.
 *
 * The style block is applied to all visible features in the viewport when the setter is called, and
 * will be run multiple times for the subsequent features entering the viewport.
 *
 * This function should be deterministic and return consistent results when it is applied over the
 * map tiles. If any styling specs of any feature would be changed, @c style must be set again.
 * Changing behavior of the style block without calling the @c style setter will result in undefined
 * behavior, including stale and/or shattered map renderings. See the example below:
 * @code{.swift}
 * let selectedPlaceIDs = Set()
 * let style = GMSDDSFeatureStyle(fill: UIColor.red, stroke: UIColor.clear, strokeWidth: 0)
 * layer.style = { feature in
 *   return selectedPlaceIDs.contains((feature as? PlaceFeature)?.placeID) ? style : nil
 * }
 *
 *
 * selectedPlaceIDs.insert("foo")
 *
 * style.strokeWidth = 1.5
 *
 *
 * layer.style = { feature in
 *   return selectedPlaceIDs.contains((feature as? PlaceFeature)?.placeID) ? style : nil
 * }
 * @endcode
 */
@property(nonatomic, nullable) GMSFeatureLayerStyleBlock style;

/**
 * Create a feature layer instance for testing uses.
 *
 * This method should be used for testing purposes only; @c GMSFeatureLayer instances should only be
 * created by the SDK in production code.
 */
- (instancetype)initWithFeatureType:(GMSFeatureType)featureType;

- (instancetype)init NS_DESIGNATED_INITIALIZER NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
