import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../logger.dart';

class ImageService {
  static Widget buildNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        httpHeaders: const {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
        },
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) {
          AppLogger.i.e('CachedNetworkImage error: $error');
          
          // Fallback to regular Image.network with custom timeout
          return FutureBuilder<ImageProvider>(
            future: _loadImageWithRetry(url),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: borderRadius ?? BorderRadius.circular(8),
                    image: DecorationImage(
                      image: snapshot.data!,
                      fit: fit,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return _buildErrorWidget(width, height, borderRadius);
              } else {
                return Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: borderRadius ?? BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  static Future<ImageProvider> _loadImageWithRetry(String url, {int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);
        client.idleTimeout = const Duration(seconds: 30);
        
        final request = await client.getUrl(Uri.parse(url));
        request.headers.set('User-Agent', 'Mozilla/5.0 (compatible; Flutter)');
        
        final response = await request.close();
        if (response.statusCode == 200) {
          // Convert response stream to bytes
          final List<int> bytes = [];
          await for (var data in response) {
            bytes.addAll(data);
          }
          client.close();
          return MemoryImage(Uint8List.fromList(bytes));
        }
        client.close();
      } catch (e) {
        AppLogger.i.w('Image load attempt ${i + 1} failed: $e');
        if (i == maxRetries - 1) {
          throw Exception('Failed to load image after $maxRetries attempts: $e');
        }
        await Future.delayed(Duration(seconds: (i + 1) * 2)); // Progressive delay
      }
    }
    throw Exception('Failed to load image');
  }

  static Widget _buildErrorWidget(double width, double height, BorderRadius? borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            'Gambar tidak\ndapat dimuat',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
