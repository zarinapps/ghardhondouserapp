import 'dart:developer';

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/advertisement/my_advertisment_screen.dart';
import 'package:ebroker/ui/screens/agents/agent_verification_form.dart';
import 'package:ebroker/ui/screens/agents/agents_details_screen.dart';
import 'package:ebroker/ui/screens/agents/agents_list_screen.dart';
import 'package:ebroker/ui/screens/auth/email_registration_form.dart';
import 'package:ebroker/ui/screens/auth/otp_screen.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/ui/screens/home/widgets/city_list_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/compare_property_screen.dart';
import 'package:ebroker/ui/screens/settings/faqs_screen.dart';

class Routes {
  //private constructor
  Routes._();
  static const comparePropertiesScreen = '/comparePropertiesScreen';
  static const agentVerificationForm = '/agentVerificationForm';
  static const agentDetailsScreen = '/agentDetailsScreen';
  static const agentListScreen = '/agentListScreen';
  static const splash = '/';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const otpScreen = 'otpScreen';
  static const emailRegistrationForm = 'emailRegistrationForm';
  static const completeProfile = 'complete_profile';
  static const main = 'main';
  static const home = 'home_screen';
  static const addProperty = 'addProperty';
  static const waitingScreen = 'waitingScreen';
  static const categories = 'Categories';
  static const cityListScreen = 'cityListScreen';
  static const addresses = 'address';
  static const chooseAdrs = 'chooseAddress';
  static const propertiesList = 'propertiesList';
  static const propertyDetails = 'PropertyDetails';
  static const contactUs = 'ContactUs';
  static const profileSettings = 'profileSettings';
  static const myEnquiry = 'MyEnquiry';
  static const filterScreen = 'filterScreen';
  static const notificationPage = 'notificationpage';
  static const notificationDetailPage = 'notificationdetailpage';
  static const addPropertyScreenRoute = 'addPropertyScreenRoute';
  static const articlesScreenRoute = 'articlesScreenRoute';
  static const subscriptionPackageListRoute = 'subscriptionPackageListRoute';
  static const subscriptionScreen = 'subscriptionScreen';
  static const maintenanceMode = '/maintenanceMode';
  static const favoritesScreen = '/favoritescreen';
  static const articleDetailsScreenRoute = '/articleDetailsScreenRoute';
  static const areaConvertorScreen = '/areaCalculatorScreen';
  // static const mortgageCalculatorScreen = '/mortgageCalculatorScreen';
  static const languageListScreenRoute = '/languageListScreenRoute';
  static const searchScreenRoute = '/searchScreenRoute';
  static const chooseLocaitonMap = '/chooseLocationMap';
  static const propertyMapScreen = '/propertyMap';
  static const dashboard = '/dashboard';

  static const myAdvertisment = '/myAdvertisment';
  static const transactionHistory = '/transactionHistory';
  // static const nearbyAllProperties = '/nearbyAllProperties';
  static const personalizedPropertyScreen = '/personalizedPropertyScreen';
  static const allProjectsScreen = '/allProjectsScreen';
  static const faqsScreen = '/faqsScreen';

  ///Project section routes
  static const String addProjectDetails = '/addProjectDetails';
  static const String projectMetaDataScreens = '/projectMetaDataScreens';
  static const String manageFloorPlansScreen = '/manageFloorPlansScreen';

  ///Add property screens
  static const selectPropertyTypeScreen = '/selectPropertyType';
  static const addPropertyDetailsScreen = '/addPropertyDetailsScreen';
  static const setPropertyParametersScreen = '/setPropertyParametersScreen';
  static const selectOutdoorFacility = '/selectOutdoorFacility';

  ///View project
  static const projectDetailsScreen = '/projectDetailsScreen';
  static const myProjects = '/myProjects';

  //Sandbox[test]
  static const playground = 'playground';

  static String currentRoute = '';
  static String previousCustomerRoute = '';
  static String globalProviderSlugForDeeplink = '';

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    if (routeSettings.name!.contains('/properties-details/')) {
      final splitURL = routeSettings.name!.split('/');
      final providerSlug = splitURL[splitURL.length - 2];

      // If app is already initialized, let the DeepLinkManager handle it
      if (Constant.navigatorKey.currentState != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Use deeplink manager to handle the link when navigatorKey is available
          final uri = Uri.parse(routeSettings.name!);
          DeepLinkManager.handleDeepLinks(
            Constant.navigatorKey.currentContext!,
            uri,
            providerSlug,
          );
        });
        return null;
      } else {
        // If app is not initialized yet, store the slug for later use
        globalProviderSlugForDeeplink = providerSlug;
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      }
    }

    if (currentRoute.startsWith('https')) {
      if (currentRoute == splash) {
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      }
      return null;
    }
    previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? '';
    log('CURRENT ROUTE $currentRoute');

    ///This is to prevent infinity loading while login browser
    if (currentRoute.contains('/link?')) {
      return null;
    }

    switch (routeSettings.name) {
      case '':
        break;

      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case onboarding:
        return CupertinoPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case home:
        return CupertinoPageRoute(
          builder: (context) => const HomeScreen(from: 'main'),
        );
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case otpScreen:
        return OtpScreen.route(routeSettings);
      case emailRegistrationForm:
        return EmailRegistrationForm.route(routeSettings);
      case completeProfile:
        return UserProfileScreen.route(routeSettings);
      // case addProperty:
      //   return AddEditProperty.route(routeSettings);
      //return AddProperty.route(routeSettings);

      case categories:
        return CategoryList.route(routeSettings);
      case cityListScreen:
        return CityListScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case propertiesList:
        return PropertiesList.route(routeSettings);
      case propertyDetails:
        return PropertyDetails.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case profileSettings:
        return ProfileSettings.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case chooseLocaitonMap:
        return ChooseLocationMap.route(routeSettings);
      case articlesScreenRoute:
        return ArticlesScreen.route(routeSettings);
      case areaConvertorScreen:
        return AreaCalculator.route(routeSettings);
      // case mortgageCalculatorScreen:
      //   return MortgageCalculatorScreen.route(routeSettings);
      case articleDetailsScreenRoute:
        return ArticleDetails.route(routeSettings);
      case subscriptionPackageListRoute:
        return SubscriptionPackageListScreen.route(routeSettings);
      case subscriptionScreen:
        return SubscriptionScreen.route(routeSettings);
      case favoritesScreen:
        return FavoritesScreen.route(routeSettings);
      case selectPropertyTypeScreen:
        return SelectPropertyType.route(routeSettings);

      case transactionHistory:
        return TransactionHistory.route(routeSettings);
      case myAdvertisment:
        return MyAdvertisementScreen.route(routeSettings);
      case personalizedPropertyScreen:
        return PersonalizedPropertyScreen.route(routeSettings);
      case addPropertyDetailsScreen:
        return AddPropertyDetails.route(routeSettings);
      case setPropertyParametersScreen:
        return SetProeprtyParametersScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);

      case propertyMapScreen:
        return PropertyMapScreen.route(routeSettings);
      // case nearbyAllProperties:
      //   return NearbyAllPropertiesScreen.route(routeSettings);
      case selectOutdoorFacility:
        return SelectOutdoorFacility.route(routeSettings);

      case addProjectDetails:
        return AddProjectDetails.route(routeSettings);

      case projectMetaDataScreens:
        return ProjectMetaDetails.route(routeSettings);

      case projectDetailsScreen:
        return ProjectDetailsScreen.route(routeSettings);

      case manageFloorPlansScreen:
        return ManageFloorPlansScreen.route(routeSettings);
      case myProjects:
        return MyProjects.route(routeSettings);
      case allProjectsScreen:
        return AllProjectsScreen.route(routeSettings);
      case agentListScreen:
        return AgentListScreen.route(routeSettings);

      case agentDetailsScreen:
        return AgentDetailsScreen.route(routeSettings);
      case agentVerificationForm:
        return AgentVerificationForm.route(routeSettings);
      case faqsScreen:
        return FaqsScreen.route(routeSettings);
      case comparePropertiesScreen:
        return ComparePropertyScreen.route(routeSettings);
      //sandBox//Playground
      // case playground:
      //   return PlayGround.route(routeSettings);

      default:
        return null;
    }
    return null;
  }
}
