import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustachi/application/theme_provider.dart';
import 'package:ustachi/core/di/service_locator.dart';
import 'package:ustachi/core/router/app_router.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/services/app_update/app_update_gate.dart';
import 'package:ustachi/core/services/snackbar_service.dart';
import 'package:ustachi/core/utils/localization/fallback_localizations.dart';
import 'package:ustachi/core/utils/localization/lib/gen/strings.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustachi/core/utils/uikit/registan_uikit.dart' as uikit;
import 'package:ustachi/features/profile/presentation/bloc/profile_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = sl<AppRouter>();
    ScriptProvider().addListener(_onScriptChanged);
    ThemeProvider().loadThemeMode();
  }

  @override
  void dispose() {
    ScriptProvider().removeListener(_onScriptChanged);
    super.dispose();
  }

  void _onScriptChanged() {
    if (mounted) rebuildAllWidgets(context);
  }

  @override
  Widget build(BuildContext context) {
    return _withWebPhoneFrame(
      context,
      ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>(
                create: (_) => sl<ProfileBloc>(),
              ),
            ],

            child: ChangeNotifierProvider<ThemeProvider>.value(
              value: ThemeProvider(),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: MaterialApp.router(
                      title: context.t.applicationName,
                      debugShowCheckedModeBanner: false,
                      scaffoldMessengerKey: sl<SnackbarService>().messengerKey,
                      scrollBehavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(
                        physics: const ClampingScrollPhysics(),
                      ),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaler: TextScaler.noScaling),
                          child: AppUpdateGate(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        );
                      },
                      theme: _buildTheme(context, Brightness.light),
                      darkTheme: _buildTheme(context, Brightness.dark),
                      themeMode: themeProvider.mode,
                      routerConfig: _router.config(
                        deepLinkBuilder: _resolveAppLink,
                      ),
                      localizationsDelegates: appLocalizationsDelegates,
                      supportedLocales: AppLocaleUtils.supportedLocales,
                      locale: TranslationProvider.of(context).flutterLocale,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  DeepLink _resolveAppLink(PlatformDeepLink link) {
    final match = RegExp(r'^/app/order/(\d+)/?$').firstMatch(link.uri.path);
    if (match == null) return link;
    return DeepLink.single(
      OrderRequestPageRoute(requestId: match.group(1)!),
    );
  }

  Widget _withWebPhoneFrame(BuildContext context, Widget app) {
    if (!kIsWeb) return app;
    final media = MediaQuery.maybeOf(context);
    if (media == null || media.size.width <= 600) return app; 
    const phoneWidth = 428.0;
    return ColoredBox(
      color: const Color(0xFF0E0E0E), 
      child: Center(
        child: SizedBox(
          width: phoneWidth,
          child: MediaQuery(
            data: media.copyWith(
              size: Size(phoneWidth, media.size.height),
            ),
            child: app,
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? uikit.OpenColors.dark : uikit.OpenColors.light;
    final neutralColors =
        isDark ? uikit.DarkNeutralColor() : uikit.LightNeutralColor();
    final uncategorizedColors = isDark
        ? uikit.DarkUncategorizedColor()
        : uikit.LightUncategorizedColor();

    final typography =
        uikit.OpenTypographies.fromColors(neutralColors, uncategorizedColors);
    final cat = colors.categorizedColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'SfProDisplay',
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      scaffoldBackgroundColor: cat.scaffoldColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cat.primary,
        brightness: brightness,
        primary: cat.primary,
        onPrimary: cat.onPrimary,
        secondary: cat.accent,
        error: cat.error,
        surface: colors.neutral.surface,
      ),
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.neutral.surface,
        foregroundColor: colors.neutral.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: typography.h3Black1,
      ),
      dividerTheme: DividerThemeData(
        color: colors.neutral.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.neutral.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.neutral.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cat.primary,
          foregroundColor: cat.onPrimary,
          elevation: 0,
          textStyle: typography.button1,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cat.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: typography.subtitle6Black4,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: colors.neutral.surface2,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: cat.info, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: cat.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: cat.error, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: colors.neutral.borderStrong, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: colors.neutral.borderStrong,
            width: 1,
          ),
        ),
      ),
      textTheme: TextTheme(bodyLarge: typography.subtitle6Black1),
      extensions: [colors, typography],
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: cat.primary.withValues(alpha: 0.24),
        selectionHandleColor: cat.primary,
        cursorColor: cat.primary,
      ),
    );
  }
}
