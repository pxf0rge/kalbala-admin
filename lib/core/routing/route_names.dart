abstract final class RouteNames {
  static const String login = '/login';
  static const String unauthorized = '/unauthorized';

  static const String dashboard = '/';

  // Content
  static const String users = '/users';
  static const String userDetail = '/users/:id';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String listings = '/listings';
  static const String listingDetail = '/listings/:id';
  static const String booths = '/booths';
  static const String boothDetail = '/booths/:id';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String categories = '/categories';
  static const String banners = '/banners';

  // Trust
  static const String reviews = '/reviews';
  static const String reviewDetail = '/reviews/:id';
  static const String reports = '/reports';
  static const String reportDetail = '/reports/:id';
  static const String tickets = '/tickets';
  static const String ticketDetail = '/tickets/:id';

  // Approvals queue
  static const String approvals = '/approvals';
  static const String pendingVerifications = '/approvals/verifications';
  static const String pendingBoothApps = '/approvals/booth-applications';
  static const String pendingProducts = '/approvals/products';
  static const String pendingBankAccounts = '/approvals/bank-accounts';
  static const String pendingSettlements = '/approvals/settlements';

  // Finance
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/:id';
  static const String refunds = '/refunds';
  static const String settlements = '/settlements';
  static const String settlementDetail = '/settlements/:id';
  static const String balances = '/balances';
  static const String bankAccounts = '/bank-accounts';
  static const String commission = '/commission';
  static const String shipping = '/shipping';

  // System
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String admins = '/admins';
  static const String audit = '/audit';

  static String userDetailPath(String id) => '/users/$id';
  static String productDetailPath(String id) => '/products/$id';
  static String listingDetailPath(String id) => '/listings/$id';
  static String boothDetailPath(String id) => '/booths/$id';
  static String orderDetailPath(String id) => '/orders/$id';
  static String reviewDetailPath(String id) => '/reviews/$id';
  static String reportDetailPath(String id) => '/reports/$id';
  static String ticketDetailPath(String id) => '/tickets/$id';
  static String paymentDetailPath(String id) => '/payments/$id';
  static String settlementDetailPath(String id) => '/settlements/$id';
}
