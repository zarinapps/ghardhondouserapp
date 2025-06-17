import 'package:country_picker/country_picker.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/auth/country_picker.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/utils/login/apple_login/apple_login.dart';
import 'package:ebroker/utils/login/google_login/google_login.dart';
import 'package:ebroker/utils/login/lib/login_status.dart';
import 'package:ebroker/utils/login/lib/login_system.dart';
import 'package:ebroker/utils/strings.dart';
import 'package:ebroker/utils/validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

// UI Constants
class UIConstants {
  static const double buttonHeight = 50;
  static const double borderRadius = 10;
  static const double borderWidth = 1.5;
  static const double sidePadding = 16;
  static const double iconSize = 20;
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 10;
  static const double spacingL = 14;
  static const double spacingXL = 20;
  static const double fontSize = 20;
  static const double countryPickerHeight = 50;
  static const int phoneMaxLength = 16;
}

// Form validator to encapsulate form validation logic
class FormValidator {
  static bool validateEmailForm(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    if (!formKey.currentState!.validate()) {
      HelperUtils.showSnackBarMessage(
        context,
        'enterValidEmailPassword'.translate(context),
        messageDuration: 1,
        type: MessageType.error,
        isFloating: true,
      );
      return false;
    }
    return true;
  }

  static bool validatePhoneForm(
    GlobalKey<FormState> formKey,
    BuildContext context,
    String phoneNumber,
  ) {
    if (!formKey.currentState!.validate() || phoneNumber.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'enterValidNumber'.translate(context),
        messageDuration: 1,
        type: MessageType.error,
        isFloating: true,
      );
      return false;
    }
    return true;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isDeleteAccount, this.popToCurrent});

  final bool? isDeleteAccount;
  final bool? popToCurrent;

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static CupertinoPageRoute<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
        ],
        child: LoginScreen(
          isDeleteAccount: args?['isDeleteAccount'] as bool? ?? false,
          popToCurrent: args?['popToCurrent'] as bool? ?? false,
        ),
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumController = TextEditingController(
    text: Constant.isDemoModeOn ? Constant.demoMobileNumber : '',
  );

  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<Widget> list = [];
  String otpVerificationId = '';
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false; //to swap between login & OTP screen
  bool isChecked = false; //Privacy policy checkbox value check
  String? phone;
  String? otp;
  String? countryCode;
  String? countryName;
  String? flagEmoji;

  int backPressedTimes = 0;
  late Size size;

  TextEditingController otpController = TextEditingController();
  bool isLoginButtonDisabled = false;
  String otpIs = '';
  bool isEmailSelected = false;
  bool isResendOtpButtonVisible = false;
  bool isForgotPasswordVisible = false;
  bool isPasswordVisible = false;

  MMultiAuthentication loginSystem = MMultiAuthentication({
    'google': GoogleLogin(),
    'apple': AppleLogin(),
  });
  // Text change listener

  @override
  void initState() {
    super.initState();

    loginSystem
      ..init()
      ..setContext(context)
      ..listen((MLoginState state) {
        if (state is MProgress) {
          unawaited(Widgets.showLoader(context));
        }

        if (state is MSuccess) {
          Widgets.hideLoder(context);
          if (widget.isDeleteAccount ?? false) {
            context.read<DeleteAccountCubit>().deleteUserAccount(
                  context,
                );
          } else {
            context.read<LoginCubit>().login(
                  type: LoginType.values
                      .firstWhere((element) => element.name == state.type),
                  name: state.credentials.user?.displayName ??
                      state.credentials.user?.providerData.first.displayName,
                  email: state.credentials.user?.providerData.first.email,
                  phoneNumber:
                      state.credentials.user?.providerData.first.phoneNumber,
                  uniqueId: state.credentials.user!.uid,
                  countryCode: countryCode,
                );
          }
        }

        if (state is MFail) {
          Widgets.hideLoder(context);
          if (state.error.toString() != 'google-terminated') {
            HelperUtils.showSnackBarMessage(
              context,
              state.error.toString(),
              type: MessageType.error,
            );
            Widgets.hideLoder(context);
          }
        }
      });
    context.read<FetchSystemSettingsCubit>();
    mobileNumController.addListener(
      () {
        if (mobileNumController.text.isEmpty &&
            Constant.isDemoModeOn == true &&
            Constant.demoMobileNumber.isNotEmpty) {
          isLoginButtonDisabled = true;
          setState(() {});
        } else {
          isLoginButtonDisabled = false;
          setState(() {});
        }
      },
    );

    HelperUtils.getSimCountry().then((value) {
      countryCode = value.phoneCode;
      flagEmoji = value.flagEmoji;
      setState(() {});
    });
  }

  @override
  void dispose() {
    isResendOtpButtonVisible = false;

    mobileNumController.dispose();
    if (isOtpSent) {
      SmsAutoFill().unregisterListener();
    }
    super.dispose();
  }

  Future<void> _onGoogleTap() async {
    try {
      // No loader is shown here to prevent app crashes
      await loginSystem.setActive('google');
      await loginSystem.login();
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        'googleLoginFailed'.translate(context),
        type: MessageType.error,
      );
    }
  }

  Future<void> _onTapAppleLogin() async {
    try {
      // No loader is shown here to prevent app crashes
      await loginSystem.setActive('apple');
      await loginSystem.login();
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        'appleLoginFailed'.translate(context),
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (context.watch<FetchSystemSettingsCubit>().state
        is FetchSystemSettingsSuccess) {
      Constant.isDemoModeOn = context
              .watch<FetchSystemSettingsCubit>()
              .getSetting(SystemSetting.demoMode) as bool? ??
          false;
    }

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: _handleBackPress,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: context.color.backgroundColor,
          appBar: _buildAppBar(),
          bottomNavigationBar: _buildBottomBar(),
          body: _buildScrollableContent(),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return ScrollConfiguration(
      behavior: RemoveGlow().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        physics: Constant.scrollPhysics,
        child: buildLoginFields(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      clipBehavior: Clip.none,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [_buildSkipButton(), const SizedBox(width: 10)],
    );
  }

  Widget buildEmailOnly() {
    return Column(
      children: [
        Column(
          children: [
            CustomTextFormField(
              validator: CustomTextFieldValidator.email,
              textDirection: TextDirection.ltr,
              scrollPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom * 4,
              ),
              prefix: Icon(
                Icons.email,
                color: context.color.tertiaryColor,
                size: 20,
              ),
              hintText: 'email'.translate(context),
              onChange: (value) {
                setState(() {});
                isResendOtpButtonVisible = false;
              },
              keyboard: TextInputType.emailAddress,
              controller: emailAddressController,
              formaters: [
                FilteringTextInputFormatter.singleLineFormatter,
              ],
            ),
            if (!isForgotPasswordVisible) ...[
              const SizedBox(height: 8),
              TextFormField(
                validator: Validator.validatePassword,
                textDirection: TextDirection.ltr,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 4,
                ),
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (isPasswordVisible == true) {
                        isPasswordVisible = false;
                      } else {
                        isPasswordVisible = true;
                      }
                      setState(() {});
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    color: context.color.inverseSurface,
                  ),
                  errorMaxLines: 1,
                  errorText: '',
                  errorStyle: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 0,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.color.tertiaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.color.tertiaryColor),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.color.tertiaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.color.tertiaryColor),
                  ),
                  hintText: 'password'.translate(context),
                  hintStyle: TextStyle(
                    color: context.color.inverseSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.lock,
                      color: context.color.tertiaryColor,
                      size: 20,
                    ),
                  ),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(
                  fontSize: 20,
                  color: context.color.textColorDark,
                ),
                cursorColor: context.color.tertiaryColor,
                cursorErrorColor: context.color.tertiaryColor,
                cursorHeight: 20,
                keyboardType: TextInputType.visiblePassword,
                controller: passwordController,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
              ),
            ],
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        if (!isForgotPasswordVisible) buildForgotPasswordText(),
        if (isForgotPasswordVisible)
          GestureDetector(
            onTap: () {
              isForgotPasswordVisible = false;
              setState(() {});
            },
            child: Container(
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsetsDirectional.only(
                end: sidePadding,
                bottom: 10,
              ),
              child: CustomText(
                'goBackToLogin'.translate(context),
                fontSize: context.font.normal,
                color: context.color.tertiaryColor,
              ),
            ),
          ),
        if (isForgotPasswordVisible)
          buildSubmitButton(context: context)
        else
          isResendOtpButtonVisible
              ? buildResendOtpButton(context: context, isEmail: true)
              : buildNextButton(context: context, isEmail: true),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText('registerWith'.translate(context)),
            const SizedBox(width: 5),
            CustomText('appName'.translate(context)),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.emailRegistrationForm,
                  arguments: {
                    'email': emailAddressController.text,
                  },
                );
              },
              child: CustomText(
                'signUp'.translate(context),
                fontWeight: FontWeight.w600,
                color: context.color.tertiaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSkipButton() {
    return FittedBox(
      fit: BoxFit.none,
      child: MaterialButton(
        color: context.color.secondaryColor.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          side: BorderSide(
            color: context.color.borderColor,
            width: UIConstants.borderWidth,
          ),
        ),
        elevation: 0,
        onPressed: () {
          GuestChecker.set('login_screen', isGuest: true);
          HiveUtils.setIsGuest();
          APICallTrigger.trigger();
          HiveUtils.setUserIsNotNew();
          HiveUtils.setUserIsNotAuthenticated();
          Navigator.pushReplacementNamed(
            context,
            Routes.main,
            arguments: {
              'from': 'login',
              'isSkipped': true,
            },
          );
        },
        child: CustomText('Skip'.translate(context)),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      height: kBottomNavigationBarHeight,
      padding: EdgeInsets.zero,
      child: buildTermsAndPrivacyWidget(),
    );
  }

  Future<bool> _handleBackPress(bool didPop, dynamic _) async {
    if (didPop) return false;
    if (widget.isDeleteAccount ?? false) {
      Navigator.pop(context);
    } else if (isOtpSent == true) {
      setState(() {
        isOtpSent = false;
      });
    } else {
      Future.delayed(Duration.zero, () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    }
    return Future.value(false);
  }

  Widget buildLoginFields(BuildContext context) {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: _handleDeleteAccountState,
      builder: (context, state) {
        return BlocListener<LoginCubit, LoginState>(
          listener: _handleLoginState,
          child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
            listener: _handleDeleteAccountProgress,
            child: BlocListener<SendOtpCubit, SendOtpState>(
              listener: _handleSendOtpState,
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {});
                },
                child: buildLoginScreen(context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteAccountState(
    BuildContext context,
    DeleteAccountState state,
  ) {
    if (state is AccountDeleted) {
      context.read<UserDetailsCubit>().clear();
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, Routes.login);
      });
    }
  }

  Future<void> _handleLoginState(BuildContext context, LoginState state) async {
    if (state is LoginInProgress) {
      unawaited(Widgets.showLoader(context));
    } else {
      if (widget.isDeleteAccount ?? false) {
      } else {
        Widgets.hideLoder(context);
      }
    }
    if (state is LoginFailure) {
      await HelperUtils.showSnackBarMessage(
        context,
        state.errorMessage,
        type: MessageType.error,
      );
    }
    if (state is LoginSuccess) {
      await _handleLoginSuccess(context, state);
    }
  }

  Future<void> _handleLoginSuccess(
    BuildContext context,
    LoginSuccess state,
  ) async {
    try {
      unawaited(Widgets.showLoader(context));
      GuestChecker.set('login_screen', isGuest: false);
      HiveUtils.setIsNotGuest();
      await LoadAppSettings().load(initBox: true);
      context.read<UserDetailsCubit>().fill(HiveUtils.getUserDetails());

      APICallTrigger.trigger();

      await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: false,
            forceRefresh: true,
          );
      final settings = context.read<FetchSystemSettingsCubit>();

      if (!const bool.fromEnvironment(
        'force-disable-demo-mode',
      )) {
        Constant.isDemoModeOn =
            settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
      }
      if (state.isProfileCompleted) {
        await _handleCompletedProfile(context);
      } else {
        await _handleIncompleteProfile(context);
      }
    } catch (e) {
      Widgets.hideLoder(context);
      await HelperUtils.showSnackBarMessage(
        context,
        'somethingWentWrong'.translate(context),
        type: MessageType.error,
      );
    }
  }

  Future<void> _handleCompletedProfile(BuildContext context) async {
    HiveUtils.setUserIsAuthenticated();
    await HiveUtils.setUserIsNotNew();
    await context.read<AuthCubit>().updateFCM(
          context,
        );
    await Navigator.pushReplacementNamed(
      context,
      Routes.main,
      arguments: {'from': 'login'},
    );
    Widgets.hideLoder(context);
  }

  Future<void> _handleIncompleteProfile(BuildContext context) async {
    await HiveUtils.setUserIsNotNew();
    await context.read<AuthCubit>().updateFCM(
          context,
        );

    if (widget.popToCurrent ?? false) {
      //Navigate to Edit profile field
      // await Navigator.pushNamed(
      //   context,
      //   Routes.completeProfile,
      //   arguments: {
      //     'from': 'login',
      //     'popToCurrent': widget.popToCurrent,
      //     'phoneNumber': mobileNumController.text,
      //   },
      // );
      Widgets.hideLoder(context);
    } else {
      //Navigate to Edit profile field
      Widgets.hideLoder(context);
      await Navigator.pushReplacementNamed(
        context,
        Routes.completeProfile,
        arguments: {
          'from': 'login',
          'popToCurrent': widget.popToCurrent,
          'phoneNumber': mobileNumController.text,
        },
      );
    }
  }

  void _handleDeleteAccountProgress(
    BuildContext context,
    DeleteAccountState state,
  ) {
    if (state is DeleteAccountProgress) {
      Widgets.hideLoder(context);
      Widgets.showLoader(context);
    }
    if (state is AccountDeleted) {
      Widgets.hideLoder(context);
    }
  }

  void _handleSendOtpState(BuildContext context, SendOtpState state) {
    {
      if (widget.isDeleteAccount ?? false) {
        // Skip hiding loader for delete account flow
      } else {
        Widgets.hideLoder(context);
      }
    }
    if (state is SendOtpInProgress) {
      unawaited(Widgets.showLoader(context));
    }

    if (state is SendOtpSuccess) {
      Widgets.hideLoder(context);
      _handleSendOtpSuccess(context, state);
    }
    if (state is SendOtpFailure) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        state.errorMessage,
        type: MessageType.error,
      );
    }
  }

  void _handleSendOtpSuccess(BuildContext context, SendOtpSuccess state) {
    isOtpSent = true;
    if (isForgotPasswordVisible) {
      HelperUtils.showSnackBarMessage(
        context,
        state.message ?? 'forgotPasswordSuccess'.translate(context),
        type: MessageType.success,
      );
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(
          context,
          'optsentsuccessflly',
        ),
        type: MessageType.success,
      );
    }
    otpVerificationId = state.verificationId ?? '';
    setState(() {});

    if (!isForgotPasswordVisible) {
      Navigator.pushNamed(
        context,
        Routes.otpScreen,
        arguments: {
          'isDeleteAccount': widget.isDeleteAccount ?? false,
          'phoneNumber': mobileNumController.text,
          'email': emailAddressController.text,
          'otpVerificationId': otpVerificationId,
          'countryCode': countryCode ?? '',
          'otpIs': otpIs,
          'isEmailSelected': isEmailSelected,
        },
      );
    }
  }

  String demoOTP() {
    if (Constant.isDemoModeOn &&
        Constant.demoMobileNumber == mobileNumController.text) {
      return Constant.demoModeOTP; // If true, return the demo mode OTP.
    } else {
      return ''; // If false, return an empty string.
    }
  }

  Widget buildLoginScreen(BuildContext context) {
    return BlocConsumer<FetchSystemSettingsCubit, FetchSystemSettingsState>(
      listener: (context, state) {
        if (state is FetchSystemSettingsInProgress) {
          unawaited(Widgets.showLoader(context));
        }
        if (state is FetchSystemSettingsSuccess) {
          Widgets.hideLoder(context);
        }
      },
      builder: (context, state) {
        final phoneLogin = context
                .read<FetchSystemSettingsCubit>()
                .getSetting(SystemSetting.numberWithOtpLogin)
                ?.toString() ??
            '';
        final socialLogin = context
                .read<FetchSystemSettingsCubit>()
                .getSetting(SystemSetting.socialLogin)
                ?.toString() ??
            '';
        if (state is FetchSystemSettingsSuccess) {
          return Column(
            children: [
              _buildLoginShapeContainer(context, phoneLogin, socialLogin),
              _buildLoginContent(context, phoneLogin, socialLogin),
            ],
          );
        } else if (state is FetchSystemSettingsFailure) {
          return const Center(child: SomethingWentWrong());
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildLoginShapeContainer(
    BuildContext context,
    String phoneLogin,
    String socialLogin,
  ) {
    final isSocialLogin = socialLogin == '1';
    final isPhoneLogin = phoneLogin == '1';
    final height = isSocialLogin && isPhoneLogin
        ? MediaQuery.of(context).size.height * 0.5
        : MediaQuery.of(context).size.height * 0.55;
    return Stack(
      children: [
        Center(
          child: ClipPath(
            clipper: VShapeClipper(context: context),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: height,
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          child: Center(
            child: ClipPath(
              clipper: VShapeClipper(context: context),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: height,
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -20,
          child: Center(
            child: ClipPath(
              clipper: VShapeClipper(context: context),
              child: Image.asset(
                height: height,
                width: MediaQuery.of(context).size.width,
                'assets/login_background.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginContent(
    BuildContext context,
    String phoneLogin,
    String socialLogin,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          SizedBox(height: 20.rh(context)),
          if (socialLogin == '0') ...[
            buildMobileEmailField(),
          ],
          if (socialLogin == '1') _buildSocialLoginSection(context, phoneLogin),
          const SizedBox(
            height: kBottomNavigationBarHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) => Center(
        child: Column(
          children: [
            CustomText(
              UiUtils.translate(context, 'loginNow'),
              fontWeight: FontWeight.w700,
              fontSize: context.font.extraLarge,
              color: context.color.textColorDark,
            ),
            const SizedBox(
              height: 8,
            ),
            CustomText(
              UiUtils.translate(context, 'loginToYourAccount'),
              fontWeight: FontWeight.w500,
              fontSize: context.font.large,
              color: context.color.textColorDark,
            ),
          ],
        ),
      );

  Widget _buildSocialLoginSection(BuildContext context, String phoneLogin) {
    if (phoneLogin == '0') {
      return Column(
        children: [
          buildEmailOnly(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Platform.isIOS) ...[
                _buildSocialButton(
                  context: context,
                  text: 'signInWithApple'.translate(context),
                  icon: AppIcons.apple,
                  onTap: _onTapAppleLogin,
                ),
                const SizedBox(width: UIConstants.spacingM),
              ],
              _buildSocialButton(
                text: 'signInWithGoogle'.translate(context),
                context: context,
                icon: AppIcons.google,
                onTap: _onGoogleTap,
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildMobileEmailField(),
          const SizedBox(height: UIConstants.spacingS),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: context.color.inverseSurface.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingM,
                ),
                child: CustomText('or'.translate(context)),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: context.color.inverseSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                context: context,
                text: 'signInWithApple'.translate(context),
                icon: isEmailSelected ? AppIcons.phone : AppIcons.email,
                onTap: () {
                  setState(() {
                    isEmailSelected = !isEmailSelected;
                    isForgotPasswordVisible = false;
                    setState(() {});
                  });
                },
              ),
              const SizedBox(width: UIConstants.spacingM),
              if (Platform.isIOS) ...[
                _buildSocialButton(
                  context: context,
                  text: 'signInWithApple'.translate(context),
                  icon: AppIcons.apple,
                  onTap: _onTapAppleLogin,
                ),
                const SizedBox(width: UIConstants.spacingM),
              ],
              _buildSocialButton(
                context: context,
                text: 'signInWithGoogle'.translate(context),
                icon: AppIcons.google,
                onTap: _onGoogleTap,
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required VoidCallback onTap,
    required String text,
  }) {
    return GestureDetector(
      onTap: () {
        HelperUtils.unfocus();
        onTap();
      },
      child: Container(
        height: UIConstants.buttonHeight,
        width: UIConstants.buttonHeight,
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
          border: Border.all(
            color: context.color.borderColor,
            width: UIConstants.borderWidth,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: UiUtils.getSvg(
            icon,
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }

  Widget buildMobileEmailField() => Column(
        children: [
          if (isEmailSelected)
            Column(
              children: [
                CustomTextFormField(
                  controller: emailAddressController,
                  validator: CustomTextFieldValidator.email,
                  hintText: 'email'.translate(context),
                  prefix: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.email,
                      color: context.color.tertiaryColor,
                      size: 20,
                    ),
                  ),
                  onChange: (value) {
                    setState(() {});
                    isResendOtpButtonVisible = false;
                  },
                ),
                if (!isForgotPasswordVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CustomTextFormField(
                      controller: passwordController,
                      validator: CustomTextFieldValidator.nullCheck,
                      hintText: 'password'.translate(context),
                      isPassword: !isPasswordVisible,
                      suffix: IconButton(
                        onPressed: () {
                          if (isPasswordVisible == true) {
                            isPasswordVisible = false;
                          } else {
                            isPasswordVisible = true;
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        color: context.color.inverseSurface,
                      ),
                    ),
                  ),
              ],
            )
          else
            CustomTextFormField(
              controller: mobileNumController,
              validator: CustomTextFieldValidator.phoneNumber,
              maxLine: 1,
              hintText: ' +${countryCode ?? ''} 0000000000',
              prefix: CountryPickerWidget(
                flagEmoji: flagEmoji,
                onTap: showCountryCode,
              ),
              keyboard: TextInputType.phone,
              formaters: [FilteringTextInputFormatter.digitsOnly],
              onChange: (value) {
                setState(() {
                  phone = '${countryCode!} $value';
                });
              },
            ),
          const SizedBox(
            height: 8,
          ),
          if (!isForgotPasswordVisible && isEmailSelected)
            buildForgotPasswordText(),
          if (isForgotPasswordVisible)
            GestureDetector(
              onTap: () {
                isForgotPasswordVisible = false;
                setState(() {});
              },
              child: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(
                  end: sidePadding,
                  bottom: 10,
                ),
                child: CustomText(
                  'goBackToLogin'.translate(context),
                  fontSize: context.font.normal,
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
          if (isForgotPasswordVisible)
            buildSubmitButton(context: context)
          else
            isResendOtpButtonVisible
                ? buildResendOtpButton(context: context, isEmail: true)
                : buildNextButton(context: context, isEmail: isEmailSelected),
          const SizedBox(
            height: 10,
          ),
          if (isEmailSelected)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText('registerWith'.translate(context)),
                const SizedBox(width: 5),
                CustomText('appName'.translate(context)),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.emailRegistrationForm,
                      arguments: {
                        'email': emailAddressController.text,
                      },
                    );
                  },
                  child: CustomText(
                    'signUp'.translate(context),
                    fontWeight: FontWeight.w600,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ],
            ),
        ],
      );

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(11),
        backgroundColor: context.color.backgroundColor,
        textStyle: TextStyle(color: context.color.textColorDark),
        inputDecoration: InputDecoration(
          hintStyle: TextStyle(color: context.color.textColorDark),
          helperStyle: TextStyle(color: context.color.textColorDark),
          prefixIcon: const Icon(Icons.search),
          iconColor: context.color.tertiaryColor,
          prefixIconColor: context.color.tertiaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.color.tertiaryColor),
          ),
          floatingLabelStyle: TextStyle(color: context.color.tertiaryColor),
          labelText: 'Search',
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: context.color.textColorDark),
        ),
      ),
      onSelect: (Country value) {
        flagEmoji = value.flagEmoji;
        countryCode = value.phoneCode;
        setState(() {});
      },
    );
  }

  Widget buildForgotPasswordText() {
    return GestureDetector(
      onTap: () {
        isForgotPasswordVisible = true;
        setState(() {});
      },
      child: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: sidePadding, bottom: 10),
        child: CustomText(
          'forgotPassword'.translate(context),
          fontSize: context.font.normal,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  Widget buildSubmitButton({required BuildContext context}) {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        await context.read<SendOtpCubit>().sendForgotPasswordEmail(
              email: emailAddressController.text.trim(),
            );
      },
      disabled: emailAddressController.text.trim().isEmpty,
      disabledColor: Colors.grey,
      height: 50,
      radius: 10,
      border: BorderSide(
        color: context.color.borderColor,
      ),
      buttonTitle: 'submit'.translate(context),
    );
  }

  Widget buildResendOtpButton({
    required BuildContext context,
    required bool isEmail,
  }) {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        await context.read<SendOtpCubit>().resendEmailOTP(
              email: emailAddressController.text.trim(),
              password: passwordController.text.trim(),
            );
      },
      buttonTitle: UiUtils.translate(context, 'resendOtpBtnLbl'),
    );
  }

  Widget buildNextButton({
    required BuildContext context,
    required bool isEmail,
  }) {
    return UiUtils.buildButton(
      context,
      disabled: (isEmail && emailAddressController.text.isEmpty) ||
          (!isEmail && mobileNumController.text.isEmpty),
      disabledColor: Colors.grey,
      height: UIConstants.buttonHeight,
      onPressed:
          isEmail ? sendEmailVerificationCode : sendPhoneVerificationCode,
      buttonTitle: 'continue'.translate(context),
      border: BorderSide(
        color: context.color.borderColor,
      ),
      radius: UIConstants.borderRadius,
    );
  }

  Future<void> sendEmailVerificationCode() async {
    if (FormValidator.validateEmailForm(_formKey, context)) {
      unawaited(Widgets.showLoader(context));
      await context.read<LoginCubit>().loginWithEmail(
            email: emailAddressController.text.trim(),
            password: passwordController.text.trim(),
            type: LoginType.email,
          );

      final state = context.read<LoginCubit>().state;
      if (state is LoginFailure &&
          state.errorMessage.toLowerCase().contains('not verified')) {
        Widgets.hideLoder(context);
        isResendOtpButtonVisible = true;
        setState(() {});
      } else if (state is LoginSuccess) {
        Widgets.hideLoder(context);
      } else {
        Widgets.hideLoder(context);
      }
    }
  }

  Future<void> sendPhoneVerificationCode({String? number}) async {
    if (!FormValidator.validatePhoneForm(
      _formKey,
      context,
      mobileNumController.text,
    )) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null) return;
    form.save();

    try {
      if (form.validate()) {
        if (widget.isDeleteAccount ?? false) {
          if (AppSettings.otpServiceProvider == 'twilio') {
            await context
                .read<SendOtpCubit>()
                .sendTwilioOTP(phoneNumber: '+$number');
          } else if (AppSettings.otpServiceProvider == 'firebase') {
            await context
                .read<SendOtpCubit>()
                .sendFirebaseOTP(phoneNumber: '+$number');
          }
        } else if (AppSettings.otpServiceProvider == 'firebase') {
          await context.read<SendOtpCubit>().sendFirebaseOTP(
                phoneNumber: '+${countryCode!}${mobileNumController.text}',
              );
        } else if (AppSettings.otpServiceProvider == 'twilio') {
          await context.read<SendOtpCubit>().sendTwilioOTP(
                phoneNumber: '+${countryCode!}${mobileNumController.text}',
              );
        }
      }
    } catch (e) {
      Widgets.hideLoder(context);
      await HelperUtils.showSnackBarMessage(
        context,
        Strings.invalidPhoneMessage,
        type: MessageType.error,
      );
    }
  }

  Widget buildTermsAndPrivacyWidget() {
    return Container(
      padding: EdgeInsetsDirectional.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "${UiUtils.translate(context, "policyAggreementStatement")}\n",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.textColorDark,
                      ),
                ),
                TextSpan(
                  text: UiUtils.translate(context, 'termsConditions'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.tertiaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() {
                      HelperUtils.goToNextPage(
                        Routes.profileSettings,
                        context,
                        false,
                        args: {
                          'title':
                              UiUtils.translate(context, 'termsConditions'),
                          'param': Api.termsAndConditions,
                        },
                      );
                    }),
                ),
                TextSpan(
                  text: " ${UiUtils.translate(context, "and")} ",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.textColorDark,
                      ),
                ),
                TextSpan(
                  text: UiUtils.translate(context, 'privacyPolicy'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.tertiaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() {
                      HelperUtils.goToNextPage(
                        Routes.profileSettings,
                        context,
                        false,
                        args: {
                          'title': UiUtils.translate(context, 'privacyPolicy'),
                          'param': Api.privacyPolicy,
                        },
                      );
                    }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VShapeClipper extends CustomClipper<Path> {
  VShapeClipper({required this.context});
  final BuildContext context;
  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;
    final path = Path();
    final shortestSide = MediaQuery.of(context).size.width;

    final useMobileLayout = shortestSide < 550;

    final pad = useMobileLayout ? 12.0 : 25.0;
    path
      ..lineTo(0, h - (pad * 10))
      ..quadraticBezierTo(0, h - (pad * 10) + 5, 5, h - (pad * 10) + 10)
      ..lineTo(w / 2 - pad, h - pad / 2)
      ..cubicTo(w / 2, h, w / 2, h, w / 2 + pad, h - pad / 2)
      ..lineTo(w - 5, h - (pad * 10) + 10)
      ..quadraticBezierTo(w, h - (pad * 10) + 5, w, h - (pad * 10))
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
