import 'package:flutter/material.dart';

class GlowingLogoCircle extends StatefulWidget {
  const GlowingLogoCircle({
    super.key,
    required this.child,
    required this.primaryGlow,
    required this.secondaryGlow,
    required this.glowStrength,
    required this.scale,
    required this.rotation,
    required this.shimmerPosition,
  });

  final Widget child;
  final Color primaryGlow;
  final Color secondaryGlow;
  final double glowStrength; // 0..1
  final double scale;
  final double rotation; // radians
  final double shimmerPosition; // -0.8..1.8 expected

  @override
  State<GlowingLogoCircle> createState() => _GlowingLogoCircleState();
}

class _GlowingLogoCircleState extends State<GlowingLogoCircle> {
  Offset _tilt = Offset.zero; // -0.05..0.05 per axis

  void _updateTilt(Offset localPosition, Size size) {
    final double nx = (localPosition.dx / size.width) * 2 - 1;
    final double ny = (localPosition.dy / size.height) * 2 - 1;
    setState(() {
      _tilt = Offset(nx.clamp(-1.0, 1.0), ny.clamp(-1.0, 1.0)) * 0.05;
    });
  }

  void _resetTilt() {
    setState(() => _tilt = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final double effectiveGlow = isLight
        ? widget.glowStrength * 0.5
        : widget.glowStrength;

    return Opacity(
      opacity: 0.7 + 0.3 * effectiveGlow,
      child: Transform.rotate(
        angle: widget.rotation + _tilt.dx * 0.2,
        child: Transform.scale(
          scale: widget.scale + (_tilt.distance * 0.05),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final Size size = Size(
                constraints.maxWidth.isFinite ? constraints.maxWidth : 140,
                constraints.maxHeight.isFinite ? constraints.maxHeight : 140,
              );
              return MouseRegion(
                onHover: (e) => _updateTilt(e.localPosition, size),
                onExit: (_) => _resetTilt(),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (d) => _updateTilt(d.localPosition, size),
                  onTapUp: (_) => _resetTilt(),
                  onTapCancel: _resetTilt,
                  onPanStart: (d) => _updateTilt(d.localPosition, size),
                  onPanUpdate: (d) => _updateTilt(d.localPosition, size),
                  onPanEnd: (_) => _resetTilt(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.95,
                        colors: <Color>[
                          // Slight base vignette so the colored glow reads on both themes
                          Colors.black.withValues(alpha: isLight ? 0.10 : 0.50),
                          Colors.black.withValues(alpha: isLight ? 0.06 : 0.35),
                          Colors.transparent,
                        ],
                        stops: const <double>[0.0, 0.4, 1.0],
                      ),
                      border: Border.all(
                        // Tint the rim subtly with the provided glow color
                        color: Color.alphaBlend(
                          widget.secondaryGlow.withValues(
                            alpha: (isLight ? 0.10 : 0.14) * effectiveGlow,
                          ),
                          Colors.white.withValues(alpha: isLight ? 0.06 : 0.10),
                        ),
                        width: 1.2,
                      ),
                      // Soft outer glow so the chosen color is actually visible
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: widget.primaryGlow.withValues(
                            alpha: (isLight ? 0.18 : 0.28) * effectiveGlow,
                          ),
                          blurRadius: 30 * (0.6 + effectiveGlow * 0.8),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: widget.secondaryGlow.withValues(
                            alpha: (isLight ? 0.12 : 0.20) * effectiveGlow,
                          ),
                          blurRadius: 18 * (0.6 + effectiveGlow * 0.8),
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Subtle color tint across the circle so brand color reads
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.95,
                                colors: <Color>[
                                  widget.primaryGlow.withValues(
                                    alpha:
                                        (isLight ? 0.10 : 0.16) * effectiveGlow,
                                  ),
                                  widget.secondaryGlow.withValues(
                                    alpha:
                                        (isLight ? 0.06 : 0.10) * effectiveGlow,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const <double>[0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Subtle inner highlight ring for a refined look
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.9,
                                colors: <Color>[
                                  Colors.white.withOpacity(
                                    isLight ? 0.04 : 0.08,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const <double>[0.22, 0.78],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Glass-like fill that adapts to theme
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.95,
                              colors: <Color>[
                                Colors.white.withValues(
                                  alpha: isLight ? 0.35 : 0.10,
                                ),
                                Colors.white.withValues(
                                  alpha: isLight ? 0.18 : 0.06,
                                ),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const <double>[0.0, 0.55, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: isLight ? 0.22 : 0.18,
                              ),
                              width: 1.0,
                            ),
                            boxShadow: const <BoxShadow>[],
                          ),
                          child: ClipOval(child: widget.child),
                        ),
                        // Shimmer effect with proper circular clipping
                        Positioned.fill(
                          child: ClipOval(
                            child: Transform.translate(
                              offset: Offset(
                                180 * (widget.shimmerPosition - 0.5),
                                0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: <Color>[
                                      Colors.transparent,
                                      Colors.white.withValues(
                                        alpha: isLight ? 0.03 : 0.06,
                                      ),
                                      widget.secondaryGlow.withValues(
                                        alpha: isLight ? 0.1 : 0.14,
                                      ),
                                      Colors.transparent,
                                    ],
                                    stops: const <double>[
                                      0.38,
                                      0.52,
                                      0.66,
                                      0.82,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Very subtle center vignette to draw focus
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.35,
                                colors: <Color>[
                                  Colors.white.withOpacity(
                                    isLight ? 0.02 : 0.04,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const <double>[0.0, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Soft glassy sheen at the top arc - properly circular
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ClipOval(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0, -0.7),
                                    radius: 0.8,
                                    colors: <Color>[
                                      Colors.white.withValues(
                                        alpha: isLight ? 0.05 : 0.08,
                                      ),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                    stops: const <double>[0.0, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
