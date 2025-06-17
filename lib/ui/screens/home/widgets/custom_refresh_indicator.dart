import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatefulWidget {
  const CustomRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> {
  bool _showCompleteIcon = false;
  bool _hasError = false;

  Future<void> _handleRefresh() async {
    final stopwatch = Stopwatch()..start();

    await Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        HelperUtils.showSnackBarMessage(
          context,
          'noInternet'.translate(context),
        );
        _hasError = true;
        return;
      }
    });

    try {
      await widget.onRefresh();
      // Explicitly set no error on success
      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    } catch (e) {
      // Set error state on exception
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      // Wait at least for minimum duration for smoother UX
      final elapsed = stopwatch.elapsed;
      const minDuration = Duration(milliseconds: 800);
      if (elapsed < minDuration && mounted) {
        await Future<dynamic>.delayed(minDuration - elapsed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomMaterialIndicator(
      displacement: 20,
      onRefresh: _handleRefresh,
      backgroundColor: context.color.brightness == Brightness.light
          ? Color.lerp(
              context.color.tertiaryColor,
              Colors.white,
              0.7,
            )
          : Color.lerp(
              context.color.tertiaryColor,
              Colors.black,
              0.7,
            ),
      onStateChanged: (change) {
        if (change.didChange(to: IndicatorState.complete)) {
          if (mounted) {
            setState(() {
              _showCompleteIcon = true;
            });
          }
        } else if (change.didChange(to: IndicatorState.idle)) {
          if (mounted) {
            setState(() => _showCompleteIcon = false);
          }
        }
      },
      indicatorBuilder: (context, controller) {
        final isRefreshing = controller.state == IndicatorState.loading;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _showCompleteIcon
              ? Icon(
                  _hasError ? Icons.close : Icons.check,
                  color: _hasError ? Colors.red : context.color.tertiaryColor,
                  size: 30,
                  key: ValueKey(_hasError ? 'error' : 'success'),
                )
              : SizedBox(
                  height: 50,
                  width: 50,
                  key: const ValueKey('progress'),
                  child: Center(
                    child: UiUtils.progress(
                      width: 24,
                      height: 24,
                      normalProgressColor:
                          Theme.of(context).colorScheme.secondary,
                      play: isRefreshing,
                    ),
                  ),
                ),
        );
      },
      durations: const RefreshIndicatorDurations(
        completeDuration: Duration(milliseconds: 500),
      ),
      child: widget.child,
    );
  }
}
