enum DeploymentEnvironment { local, dev, prod }

class AppConstants {
  static const DeploymentEnvironment deploymentEnvironment =
      DeploymentEnvironment.dev;
  static final Roles roles = Roles();
  static final AuctionStatuses auctionStatuses = AuctionStatuses();
  static final ImagesSectionIds imagesSectionIds = ImagesSectionIds();
  static final TabBarWidgetControllerTags tabBarWidgetControllerTags =
      TabBarWidgetControllerTags();
  static final HomeScreenSections homeScreenSections = HomeScreenSections();
  static const List<String> indianStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
  ];
  static const _localConfiguration = _EnvConfig(
    deploymentEnvironmentName: 'local',
    renderBaseUrl: 'http://192.168.100.99:4000/api/',
    oneSignalAppId: 'a6697fe1-be34-420f-9aa7-1fa369e1b07c',
  );
  static const _devConfiguration = _EnvConfig(
    deploymentEnvironmentName: 'dev',
    renderBaseUrl: 'https://otobix-app-backend-development.onrender.com/api/',
    oneSignalAppId: 'a6697fe1-be34-420f-9aa7-1fa369e1b07c',
  );
  static const _prodConfiguration = _EnvConfig(
    deploymentEnvironmentName: 'prod',
    // renderBaseUrl: 'https://otobix-app-backend-rq8m.onrender.com/api/',
    renderBaseUrl: 'https://ob-dealerapp-kong.onrender.com/api/',
    oneSignalAppId: 'a6697fe1-be34-420f-9aa7-1fa369e1b07c',
  );
  static _EnvConfig get env =>
      deploymentEnvironment == DeploymentEnvironment.prod
      ? _prodConfiguration
      : deploymentEnvironment == DeploymentEnvironment.dev
      ? _devConfiguration
      : _localConfiguration;
  static String get envName => env.deploymentEnvironmentName; // 'dev' | 'prod'
  static bool get isProd => deploymentEnvironment == DeploymentEnvironment.prod;
  static String get renderBaseUrl => env.renderBaseUrl;
  static String get oneSignalAppId => env.oneSignalAppId;
  static String externalIdForNotifications(String mongoUserId) =>
      '$envName:$mongoUserId';
}

class Roles {
  final String dealer = 'Dealer';
  final String customer = 'Customer';
  final String salesManager = 'Sales Manager';
  final String admin = 'Admin';

  final String userStatusPending = 'Pending';
  final String userStatusApproved = 'Approved';
  final String userStatusRejected = 'Rejected';

  List<String> get all => [dealer, customer, salesManager, admin];
}

class AuctionStatuses {
  final String all = 'all';
  final String upcoming = 'upcoming';
  final String live = 'live';
  final String otobuy = 'otobuy';
  final String marketplace = 'marketplace';
  final String liveAuctionEnded = 'liveAuctionEnded';
  final String sold = 'sold';
  final String otobuyEnded = 'otobuyEnded';
  final String removed = 'removed';
}

class ImagesSectionIds {
  final String exterior = 'exterior';
  final String interior = 'interior';
  final String engine = 'engine';
  final String suspension = 'suspension';
  final String ac = 'ac';
  final String tyres = 'tyres';
  final String damages = 'damages';

  List<String> get all => [exterior, interior, engine, suspension, ac];
}

class TabBarWidgetControllerTags {
  final String homeTabs = 'home_tabs';
  final String myCarsTabs = 'mycars_tabs';

  List<String> get all => [homeTabs, myCarsTabs];
}

class HomeScreenSections {
  // final String liveBidsSectionScreen = 'live_bids';
  final String liveBidsSectionScreen = 'live';
  final String upcomingSectionScreen = 'upcoming';
  final String otobuySectionScreen = 'otobuy';
  final String marketplaceSectionScreen = 'marketplace';
}

class _EnvConfig {
  final String deploymentEnvironmentName; // 'dev' or 'prod'
  final String renderBaseUrl;
  final String oneSignalAppId;
  const _EnvConfig({
    required this.deploymentEnvironmentName,
    required this.renderBaseUrl,
    required this.oneSignalAppId,
  });
}
