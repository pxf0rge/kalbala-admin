import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalbala_admin/core/routing/route_names.dart';
import 'package:kalbala_admin/features/approvals/presentation/screens/approvals_screens.dart';
import 'package:kalbala_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:kalbala_admin/features/auth/presentation/screens/login_screen.dart';
import 'package:kalbala_admin/features/auth/presentation/screens/unauthorized_screen.dart';
import 'package:kalbala_admin/features/booths/presentation/screens/booth_detail_screen.dart';
import 'package:kalbala_admin/features/booths/presentation/screens/booths_screen.dart';
import 'package:kalbala_admin/features/catalog/presentation/screens/banners_screen.dart';
import 'package:kalbala_admin/features/catalog/presentation/screens/categories_screen.dart';
import 'package:kalbala_admin/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kalbala_admin/features/finance/presentation/screens/finance_screens.dart';
import 'package:kalbala_admin/features/listings/presentation/screens/listing_detail_screen.dart';
import 'package:kalbala_admin/features/listings/presentation/screens/listings_screen.dart';
import 'package:kalbala_admin/features/moderation/presentation/screens/reports_screens.dart';
import 'package:kalbala_admin/features/moderation/presentation/screens/reviews_screens.dart';
import 'package:kalbala_admin/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:kalbala_admin/features/orders/presentation/screens/orders_screen.dart';
import 'package:kalbala_admin/features/products/presentation/screens/product_detail_screen.dart';
import 'package:kalbala_admin/features/products/presentation/screens/products_screen.dart';
import 'package:kalbala_admin/features/support/presentation/screens/tickets_screens.dart';
import 'package:kalbala_admin/features/system/presentation/screens/system_screens.dart';
import 'package:kalbala_admin/features/users/presentation/screens/user_detail_screen.dart';
import 'package:kalbala_admin/features/users/presentation/screens/users_screen.dart';
import 'package:kalbala_admin/shared/widgets/admin_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authStatusProvider);
      final loc = state.matchedLocation;
      final isAuthRoute =
          loc == RouteNames.login || loc == RouteNames.unauthorized;

      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated) {
        return isAuthRoute && loc != RouteNames.unauthorized
            ? null
            : RouteNames.login;
      }

      if (status == AuthStatus.unauthorized || status == AuthStatus.blocked) {
        return loc == RouteNames.unauthorized ? null : RouteNames.unauthorized;
      }

      if (isAuthRoute) return RouteNames.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.users,
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: RouteNames.userDetail,
            builder: (context, state) =>
                UserDetailScreen(userId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.products,
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: RouteNames.productDetail,
            builder: (context, state) =>
                ProductDetailScreen(productId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.listings,
            builder: (context, state) => const ListingsScreen(),
          ),
          GoRoute(
            path: RouteNames.listingDetail,
            builder: (context, state) =>
                ListingDetailScreen(listingId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.booths,
            builder: (context, state) => const BoothsScreen(),
          ),
          GoRoute(
            path: RouteNames.boothDetail,
            builder: (context, state) =>
                BoothDetailScreen(boothId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: RouteNames.orderDetail,
            builder: (context, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.categories,
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: RouteNames.banners,
            builder: (context, state) => const BannersScreen(),
          ),
          GoRoute(
            path: RouteNames.reviews,
            builder: (context, state) => const ReviewsScreen(),
          ),
          GoRoute(
            path: RouteNames.reviewDetail,
            builder: (context, state) =>
                ReviewDetailScreen(reviewId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: RouteNames.reportDetail,
            builder: (context, state) =>
                ReportDetailScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.tickets,
            builder: (context, state) => const TicketsScreen(),
          ),
          GoRoute(
            path: RouteNames.ticketDetail,
            builder: (context, state) =>
                TicketDetailScreen(ticketId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.approvals,
            builder: (context, state) => const ApprovalsScreen(),
          ),
          GoRoute(
            path: RouteNames.pendingVerifications,
            builder: (context, state) => const PendingVerificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.pendingBoothApps,
            builder: (context, state) => const PendingBoothAppsScreen(),
          ),
          GoRoute(
            path: RouteNames.pendingProducts,
            builder: (context, state) => const PendingProductsScreen(),
          ),
          GoRoute(
            path: RouteNames.pendingBankAccounts,
            builder: (context, state) => const PendingBankAccountsScreen(),
          ),
          GoRoute(
            path: RouteNames.pendingSettlements,
            builder: (context, state) => const PendingSettlementsScreen(),
          ),
          GoRoute(
            path: RouteNames.payments,
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: RouteNames.paymentDetail,
            builder: (context, state) =>
                PaymentDetailScreen(paymentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: RouteNames.refunds,
            builder: (context, state) => const RefundsScreen(),
          ),
          GoRoute(
            path: RouteNames.settlements,
            builder: (context, state) => const SettlementsScreen(),
          ),
          GoRoute(
            path: RouteNames.settlementDetail,
            builder: (context, state) => SettlementDetailScreen(
              settlementId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteNames.balances,
            builder: (context, state) => const BalancesScreen(),
          ),
          GoRoute(
            path: RouteNames.bankAccounts,
            builder: (context, state) => const BankAccountsScreen(),
          ),
          GoRoute(
            path: RouteNames.commission,
            builder: (context, state) => const CommissionScreen(),
          ),
          GoRoute(
            path: RouteNames.shipping,
            builder: (context, state) => const ShippingScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.admins,
            builder: (context, state) => const AdminsScreen(),
          ),
          GoRoute(
            path: RouteNames.audit,
            builder: (context, state) => const AuditScreen(),
          ),
        ],
      ),
    ],
  );
});
