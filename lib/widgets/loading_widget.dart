import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 40,
  });

  // Factory pour le chargement des prospects
  factory LoadingWidget.prospects() {
    return const LoadingWidget(
      message: 'Chargement des prospects...',
      color: Color(0xFF219ebc),
    );
  }

  // Factory pour le chargement de l'authentification
  factory LoadingWidget.auth() {
    return const LoadingWidget(
      message: 'Connexion en cours...',
      color: Color(0xFF023047),
    );
  }

  // Factory pour le chargement d'une action
  factory LoadingWidget.action(String actionMessage) {
    return LoadingWidget(
      message: actionMessage,
      color: const Color(0xFF219ebc),
      size: 32,
    );
  }

  // Factory pour le chargement d'une page
  factory LoadingWidget.page() {
    return const LoadingWidget(
      message: 'Chargement...',
      color: Color(0xFF219ebc),
      size: 48,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicateur de chargement
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),

          // Message (optionnel)
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (overlayColor ?? Colors.black).withOpacity(0.3),
            child: LoadingWidget(
              message: loadingMessage,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  // Factory pour une carte de prospect
  factory ShimmerLoading.prospectCard() {
    return ShimmerLoading(
      width: double.infinity,
      height: 100,
      borderRadius: BorderRadius.circular(12),
    );
  }

  // Factory pour un avatar
  factory ShimmerLoading.avatar() {
    return const ShimmerLoading(
      width: 56,
      height: 56,
    );
  }

  // Factory pour une ligne de texte
  factory ShimmerLoading.text({double? width}) {
    return ShimmerLoading(
      width: width ?? 200,
      height: 16,
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159),
            ),
          ),
        );
      },
    );
  }
}