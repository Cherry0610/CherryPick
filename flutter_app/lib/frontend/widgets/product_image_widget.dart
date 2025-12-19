import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Utility class for validating and cleaning image URLs
class ImageUrlHelper {
  /// Validates if an image URL is valid and can be displayed
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url.contains('placeholder')) return false;
    if (url.contains('data:image')) return true; // Base64 images are valid
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }
    
    // Check if URL is well-formed
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cleans and normalizes an image URL
  static String? cleanImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Remove whitespace
    url = url.trim();
    
    // Handle protocol-relative URLs
    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    
    // Handle relative URLs (try to make them absolute based on common patterns)
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // Try to detect store and add base URL
      if (url.startsWith('/')) {
        // This is a relative path, but we don't know the base URL here
        // Return null so the caller can handle it
        return null;
      }
      return null;
    }
    
    // Remove query parameters that might cause issues (but keep some useful ones)
    try {
      final uri = Uri.parse(url);
      // Rebuild URL without problematic query params
      final cleanUrl = '${uri.scheme}://${uri.host}${uri.path}';
      return cleanUrl;
    } catch (e) {
      return url; // Return as-is if parsing fails
    }
  }

  /// Gets the best available image URL from a list of URLs
  static String? getBestImageUrl(List<String?> urls) {
    for (var url in urls) {
      final cleaned = cleanImageUrl(url);
      if (cleaned != null && isValidImageUrl(cleaned)) {
        return cleaned;
      }
    }
    return null;
  }
}

/// Reusable widget for displaying product images with proper error handling
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath; // Local asset path
  final String productName;
  final String? brand; // Product brand for asset lookup
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const ProductImageWidget({
    super.key,
    this.imageUrl,
    this.assetPath,
    required this.productName,
    this.brand,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.fallbackIcon = Icons.shopping_bag,
    this.fallbackIconSize = 40,
  });

  /// Get product image asset path based on product name and brand
  String? _getProductImageAsset(String productName, String? brand) {
    // Normalize product name for matching
    final normalizedName = productName.toLowerCase().trim();
    final normalizedBrand = brand?.toLowerCase().trim() ?? '';
    
    // Map products to their image assets
    // Check for exact matches first
    if (normalizedName.contains('minced beef') || 
        (normalizedName.contains('beef') && normalizedName.contains('minced'))) {
      return 'assets/images/products/minced_beef.png';
    }
    
    if (normalizedName.contains('butter') && 
        (normalizedBrand.contains('anchor') || normalizedName.contains('anchor'))) {
      return 'assets/images/products/anchor_butter.png';
    }
    
    if ((normalizedName.contains('cornflakes') || normalizedName.contains('corn flakes')) &&
        (normalizedBrand.contains('kellogg') || normalizedName.contains('kellogg'))) {
      return 'assets/images/products/kellogg\'s_cornflakes.png';
    }
    
    if ((normalizedName.contains('ikan kembung') || normalizedName.contains('kembung')) &&
        (normalizedName.contains('fresh') || normalizedName.contains('1kg'))) {
      return 'assets/images/products/fresh_ikan_kembung.png';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Priority: 1. assetPath (explicit), 2. _getProductImageAsset (auto-detect), 3. imageUrl (network)
    final localAssetPath = assetPath ?? _getProductImageAsset(productName, brand);
    final cleanedUrl = ImageUrlHelper.cleanImageUrl(imageUrl);
    final isValid = ImageUrlHelper.isValidImageUrl(cleanedUrl);
    
    final bgColor = backgroundColor ?? Colors.grey[100]!;
    final iconSize = kIsWeb ? (fallbackIconSize * 0.75) : fallbackIconSize;

    // Try local asset first
    if (localAssetPath != null && localAssetPath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          localAssetPath,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: width != null 
              ? (width! * (kIsWeb ? 1.0 : MediaQuery.of(context).devicePixelRatio)).toInt() 
              : null,
          cacheHeight: height != null 
              ? (height! * (kIsWeb ? 1.0 : MediaQuery.of(context).devicePixelRatio)).toInt() 
              : null,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to network image or icon
            if (kDebugMode) {
              debugPrint('❌ Error loading asset: $localAssetPath - $error');
            }
            // Try network image if available
            if (isValid && cleanedUrl != null) {
              return _buildNetworkImage(cleanedUrl, bgColor, iconSize);
            }
            return _buildFallbackIcon(bgColor, iconSize);
          },
        ),
      );
    }

    // Try network image if no local asset
    if (!isValid || cleanedUrl == null) {
      return _buildFallbackIcon(bgColor, iconSize);
    }

    return _buildNetworkImage(cleanedUrl, bgColor, iconSize);
  }

  Widget _buildFallbackIcon(Color bgColor, double iconSize) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        fallbackIcon,
        size: iconSize,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildNetworkImage(String url, Color bgColor, double iconSize) {
    return Builder(
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          headers: kIsWeb ? {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Referer': 'https://www.google.com/',
          } : null,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: bgColor,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Only log errors in debug mode to reduce console noise
            if (kDebugMode) {
              debugPrint('❌ Image load error for "$productName": $error');
            }
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                fallbackIcon,
                size: iconSize,
                color: Colors.grey[400],
              ),
            );
          },
          // Optimize cache dimensions - use device pixel ratio for better quality
          cacheWidth: width != null 
              ? (width! * (kIsWeb ? 1.0 : MediaQuery.of(context).devicePixelRatio)).toInt() 
              : null,
          cacheHeight: height != null 
              ? (height! * (kIsWeb ? 1.0 : MediaQuery.of(context).devicePixelRatio)).toInt() 
              : null,
        // Enable frame scheduling for smoother animations
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: child,
          );
        },
        // Reduce memory usage with lower quality for thumbnails
        filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

