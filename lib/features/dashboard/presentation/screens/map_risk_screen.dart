import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:legalx/core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:legalx/core/utils/platform_utils_stub.dart'
    if (dart.library.html) 'package:legalx/core/utils/platform_utils_web.dart';

class MapRiskScreen extends StatefulWidget {
  const MapRiskScreen({super.key});

  @override
  State<MapRiskScreen> createState() => _MapRiskScreenState();
}

class _MapRiskScreenState extends State<MapRiskScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      registerWebView('google-3d-map', _buildCesiumHtml());
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..loadHtmlString(_buildCesiumHtml());
    }
  }

  String _buildCesiumHtml() {
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <script src="https://ajax.googleapis.com/ajax/libs/cesiumjs/1.105/Build/Cesium/Cesium.js"></script>
    <link href="https://ajax.googleapis.com/ajax/libs/cesiumjs/1.105/Build/Cesium/Widgets/widgets.css" rel="stylesheet">
    <style>
        body, html, #cesiumContainer {
            width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden;
            background-color: #f9f9ff;
        }
        .cesium-viewer-bottom { display: none !important; }
    </style>
</head>
<body>
    <div id="cesiumContainer"></div>
    <script>
        const viewer = new Cesium.Viewer('cesiumContainer', {
            imageryProvider: false,
            baseLayerPicker: false,
            requestRenderMode: true,
            geocoder: false,
            homeButton: false,
            infoBox: false,
            selectionIndicator: false,
            navigationHelpButton: false,
            sceneModePicker: false,
            timeline: false,
            animation: false,
            fullscreenButton: false
        });

        const tileset = viewer.scene.primitives.add(new Cesium.Cesium3DTileset({
            url: "https://tile.googleapis.com/v1/3dtiles/root.json?key=AIzaSyCJnCtWnxs6G1dNcejQltIQbNzncdHz5l8",
            showCreditsOnScreen: false,
        }));

        viewer.scene.globe.show = false;
        
        // Initial view focus (New York area for demo)
        viewer.camera.setView({
            destination: Cesium.Cartesian3.fromDegrees(-74.0060, 40.7128, 500),
            orientation: {
                heading: Cesium.Math.toRadians(0),
                pitch: Cesium.Math.toRadians(-25),
                roll: 0.0
            }
        });

        // Add Risk Entities (Simulated 3D Markers)
        viewer.entities.add({
            position: Cesium.Cartesian3.fromDegrees(-73.935242, 40.730610, 10),
            point: { pixelSize: 20, color: Cesium.Color.RED.withOpacity(0.8) },
            label: { text: "CRITICAL RISK", font: "bold 14px Inter", verticalOrigin: Cesium.VerticalOrigin.BOTTOM, pixelOffset: new Cesium.Cartesian2(0, -20) }
        });

        viewer.entities.add({
            position: Cesium.Cartesian3.fromDegrees(-74.0060, 40.7128, 10),
            point: { pixelSize: 20, color: Cesium.Color.GREEN.withOpacity(0.8) },
            label: { text: "OPTIMAL ZONE", font: "bold 14px Inter", verticalOrigin: Cesium.VerticalOrigin.BOTTOM, pixelOffset: new Cesium.Cartesian2(0, -20) }
        });

    </script>
</body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '3D JURISDICTION INTELLIGENCE',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // 3D Engine
          kIsWeb 
            ? const HtmlElementView(viewType: 'google-3d-map')
            : WebViewWidget(controller: _controller),
          
          if (_isLoading && !kIsWeb)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    SizedBox(height: 24),
                    Text(
                      'INITIALIZING 3D LEDGER MAPPING...',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

          // Header Overlay
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.view_in_ar_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PHOTOREALISTIC 3D THEATER',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2, color: AppColors.primary),
                        ),
                        Text(
                          'Mapping Spatial Legal Risk Vectors',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Legend
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, -5)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _MapLegendItem(color: Colors.red, label: 'CRITICAL SECTOR'),
                  _MapLegendItem(color: Colors.green, label: 'OPTIMAL SECTOR'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _MapLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }
}
