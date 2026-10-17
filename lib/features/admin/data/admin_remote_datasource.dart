import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalbala_admin/core/config/supabase_config.dart';
import 'package:kalbala_admin/core/constants/app_constants.dart';
import 'package:kalbala_admin/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminListPage {
  const AdminListPage({
    required this.items,
    required this.total,
  });

  final List<Map<String, dynamic>> items;
  final int total;
}

class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client);

  final SupabaseClient _client;

  // ── Users ──────────────────────────────────────────────────────────

  Future<AdminListPage> listUsers({
    String? search,
    bool? isBlocked,
    bool? isSeller,
    String? sort,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_users', {
      'p_search': search,
      'p_is_blocked': isBlocked,
      'p_is_seller': isSeller,
      'p_sort': sort,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getUserDetail(String userId) =>
      _map('admin_get_user_detail', {'p_user_id': userId});

  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    bool? isSeller,
  }) =>
      _map('admin_update_user_profile', {
        'p_user_id': userId,
        'p_full_name': fullName,
        'p_is_seller': isSeller,
      });

  Future<void> setUserBlocked({
    required String userId,
    required bool blocked,
  }) =>
      _void('admin_set_user_blocked', {
        'p_user_id': userId,
        'p_is_blocked': blocked,
      });

  Future<Map<String, dynamic>> softDeleteUser(String userId) =>
      _map('admin_soft_delete_user', {'p_user_id': userId});

  // ── Products ────────────────────────────────────────────────────────

  Future<AdminListPage> listProducts({
    String? search,
    bool? isBlocked,
    String? categoryId,
    String? approvalStatus,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_products', {
      'p_search': search,
      'p_is_blocked': isBlocked,
      'p_category_id': categoryId,
      'p_approval_status': approvalStatus,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getProductDetail(String productId) =>
      _map('admin_get_product_detail', {'p_product_id': productId});

  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    String? description,
    String? brand,
    String? categoryId,
    bool clearCategory = false,
  }) =>
      _map('admin_update_product', {
        'p_product_id': productId,
        'p_name': name,
        'p_description': description,
        'p_brand': brand,
        'p_category_id': categoryId,
        'p_clear_category': clearCategory,
      });

  Future<void> setProductBlocked({
    required String productId,
    required bool blocked,
  }) =>
      _void('admin_set_product_blocked', {
        'p_product_id': productId,
        'p_is_blocked': blocked,
      });

  Future<Map<String, dynamic>> reviewProduct({
    required String productId,
    required String status,
    String? rejectionReason,
  }) =>
      _map('admin_review_product', {
        'p_product_id': productId,
        'p_status': status,
        'p_rejection_reason': rejectionReason,
      });

  // ── Listings ────────────────────────────────────────────────────────

  Future<AdminListPage> listListings({
    String? search,
    String? status,
    String? boothId,
    bool? isFeatured,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_listings', {
      'p_search': search,
      'p_status': status,
      'p_booth_id': boothId,
      'p_is_featured': isFeatured,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getListingDetail(String listingId) =>
      _map('admin_get_listing_detail', {'p_listing_id': listingId});

  Future<void> setListingStatus({
    required String listingId,
    required String status,
  }) =>
      _void('admin_set_listing_status', {
        'p_listing_id': listingId,
        'p_status': status,
      });

  Future<Map<String, dynamic>> setListingFeatured({
    required String listingId,
    required bool featured,
    int? featuredOrder,
  }) =>
      _map('admin_set_listing_featured', {
        'p_listing_id': listingId,
        'p_is_featured': featured,
        'p_featured_order': featuredOrder,
      });

  // ── Booths ──────────────────────────────────────────────────────────

  Future<AdminListPage> listBooths({
    String? search,
    String? approvalStatus,
    bool? isBlocked,
    bool? isActive,
    String? ownershipType,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_booths', {
      'p_search': search,
      'p_approval_status': approvalStatus,
      'p_is_blocked': isBlocked,
      'p_is_active': isActive,
      'p_ownership_type': ownershipType,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getBoothDetail(String boothId) =>
      _map('admin_get_booth_detail', {'p_booth_id': boothId});

  Future<Map<String, dynamic>> updateBooth({
    required String boothId,
    String? name,
    String? description,
    String? city,
    String? phone,
    String? address,
    bool? isActive,
    bool? isFeatured,
  }) =>
      _map('admin_update_booth', {
        'p_booth_id': boothId,
        'p_name': name,
        'p_description': description,
        'p_city': city,
        'p_phone': phone,
        'p_address': address,
        'p_is_active': isActive,
        'p_is_featured': isFeatured,
      });

  Future<void> setBoothBlocked({
    required String boothId,
    required bool blocked,
  }) =>
      _void('admin_set_booth_blocked', {
        'p_booth_id': boothId,
        'p_is_blocked': blocked,
      });

  Future<Map<String, dynamic>> setBoothFeatured({
    required String boothId,
    required bool featured,
    int? featuredOrder,
  }) =>
      _map('admin_set_booth_featured', {
        'p_booth_id': boothId,
        'p_is_featured': featured,
        'p_featured_order': featuredOrder,
      });

  Future<AdminListPage> listBoothApplications({
    String? status,
    String? search,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_booth_applications', {
      'p_status': status,
      'p_search': search,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> approveBoothApplication({
    required String applicationId,
    DateTime? rentalStart,
    DateTime? rentalEnd,
  }) =>
      _map('approve_booth_application', {
        'p_application_id': applicationId,
        'p_rental_start': rentalStart?.toIso8601String().substring(0, 10),
        'p_rental_end': rentalEnd?.toIso8601String().substring(0, 10),
      });

  Future<Map<String, dynamic>> rejectBoothApplication({
    required String applicationId,
    required String reason,
  }) =>
      _map('reject_booth_application', {
        'p_application_id': applicationId,
        'p_reason': reason,
      });

  Future<AdminListPage> listSellerVerifications({
    String? status,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_seller_verifications', {
      'p_status': status,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> reviewSellerVerification({
    required String verificationId,
    required String status,
    String? rejectionReason,
  }) =>
      _map('review_seller_verification', {
        'p_verification_id': verificationId,
        'p_status': status,
        'p_rejection_reason': rejectionReason,
      });

  // ── Orders ──────────────────────────────────────────────────────────

  Future<AdminListPage> listOrders({
    String? search,
    String? status,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_orders', {
      'p_search': search,
      'p_status': status,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getOrderDetail(String orderId) =>
      _map('admin_get_order_detail', {'p_order_id': orderId});

  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String reason,
  }) =>
      _map('admin_cancel_order', {
        'p_order_id': orderId,
        'p_reason': reason,
      });

  // ── Categories ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listCategories() async {
    final page = await _list('admin_list_categories', {});
    return page.items;
  }

  Future<Map<String, dynamic>> upsertCategory({
    String? id,
    required String name,
    String? slug,
    String? parentId,
    bool clearParent = false,
    String? iconUrl,
    int? sortOrder,
    bool? isActive,
  }) =>
      _map('admin_upsert_category', {
        'p_id': id,
        'p_name': name,
        'p_slug': slug,
        'p_parent_id': parentId,
        'p_clear_parent': clearParent,
        'p_icon_url': iconUrl,
        'p_sort_order': sortOrder,
        'p_is_active': isActive,
      });

  // ── Banners ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> listBanners({bool? isActive}) async {
    final page = await _list('admin_list_banners', {'p_is_active': isActive});
    return page.items;
  }

  Future<Map<String, dynamic>> upsertBanner({
    String? id,
    String? title,
    String? imageUrl,
    String? linkType,
    String? linkUrl,
    String? linkTargetId,
    bool clearLinkTarget = false,
    int? displayOrder,
    bool? isActive,
  }) =>
      _map('admin_upsert_banner', {
        'p_id': id,
        'p_title': title,
        'p_image_url': imageUrl,
        'p_link_type': linkType,
        'p_link_url': linkUrl,
        'p_link_target_id': linkTargetId,
        'p_clear_link_target': clearLinkTarget,
        'p_display_order': displayOrder,
        'p_is_active': isActive,
        'p_starts_at': null,
        'p_ends_at': null,
        'p_clear_starts_at': false,
        'p_clear_ends_at': false,
      });

  Future<void> deleteBanner(String id) =>
      _void('admin_delete_banner', {'p_id': id});

  // ── Reviews ─────────────────────────────────────────────────────────

  Future<AdminListPage> listReviews({
    String? search,
    bool? isVisible,
    int? rating,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_reviews', {
      'p_search': search,
      'p_is_visible': isVisible,
      'p_rating': rating,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getReviewDetail(String reviewId) =>
      _map('admin_get_review_detail', {'p_review_id': reviewId});

  Future<void> hideReview({
    required String reviewId,
    required bool isVisible,
  }) =>
      _void('admin_hide_review', {
        'p_review_id': reviewId,
        'p_is_visible': isVisible,
      });

  // ── Reports ─────────────────────────────────────────────────────────

  Future<AdminListPage> listReports({
    String? status,
    String? targetType,
    String? search,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_reports', {
      'p_status': status,
      'p_target_type': targetType,
      'p_search': search,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getReportDetail(String reportId) =>
      _map('admin_get_report_detail', {'p_report_id': reportId});

  Future<Map<String, dynamic>> moderateReport({
    required String reportId,
    required String action,
    String? note,
  }) =>
      _map('admin_moderate_report', {
        'p_report_id': reportId,
        'p_action': action,
        'p_note': note,
      });

  Future<void> resolveReport({
    required String reportId,
    required String status,
    String? note,
  }) =>
      _void('admin_resolve_report', {
        'p_report_id': reportId,
        'p_status': status,
        'p_note': note,
      });

  // ── Support tickets ─────────────────────────────────────────────────

  Future<AdminListPage> listTickets({
    String? status,
    String? search,
    bool? needsReply,
    bool? unassignedOnly,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_tickets', {
      'p_status': status,
      'p_search': search,
      'p_needs_reply': needsReply,
      'p_unassigned_only': unassignedOnly,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getTicketDetail(String ticketId) =>
      _map('admin_get_ticket_detail', {'p_ticket_id': ticketId});

  Future<String> replyTicket({
    required String ticketId,
    required String content,
    String? attachmentPath,
  }) async {
    try {
      final data = await _client.rpc<dynamic>(
        'admin_reply_ticket',
        params: {
          'p_ticket_id': ticketId,
          'p_content': content,
          'p_attachment_path': attachmentPath,
        },
      );
      return data?.toString() ?? '';
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) =>
      _void('admin_update_ticket_status', {
        'p_ticket_id': ticketId,
        'p_status': status,
      });

  Future<void> assignTicket({
    required String ticketId,
    required String assignedTo,
  }) =>
      _void('admin_assign_ticket', {
        'p_ticket_id': ticketId,
        'p_assigned_to': assignedTo,
      });

  // ── Payments / refunds / settlements ────────────────────────────────

  Future<AdminListPage> listPayments({
    String? search,
    String? status,
    String? gateway,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_payments', {
      'p_search': search,
      'p_status': status,
      'p_gateway': gateway,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getPaymentDetail(String paymentId) =>
      _map('admin_get_payment_detail', {'p_payment_id': paymentId});

  Future<AdminListPage> listRefunds({
    String? status,
    String? search,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_refunds', {
      'p_status': status,
      'p_search': search,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<AdminListPage> listSettlements({
    String? status,
    String? search,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_settlements', {
      'p_status': status,
      'p_search': search,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> getSettlementDetail(String settlementId) =>
      _map('admin_get_settlement_detail', {'p_settlement_id': settlementId});

  Future<void> processSettlementStatus({
    required String settlementId,
    required String status,
    String? rejectionReason,
  }) =>
      _void('process_settlement_status', {
        'p_settlement_id': settlementId,
        'p_status': status,
        'p_rejection_reason': rejectionReason,
      });

  Future<AdminListPage> listSellerBalances({
    String? search,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_seller_balances', {
      'p_search': search,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<AdminListPage> listBankAccounts({
    String? search,
    bool? isVerified,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_bank_accounts', {
      'p_search': search,
      'p_is_verified': isVerified,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<void> verifyBankAccount(String bankAccountId) =>
      _void('verify_bank_account', {'p_bank_account_id': bankAccountId});

  // ── Commission / shipping ───────────────────────────────────────────

  Future<Map<String, dynamic>> getCommissionConfig() =>
      _map('admin_get_commission_config', {});

  Future<Map<String, dynamic>> updateCommissionConfig({
    required bool enabled,
    required num defaultRate,
  }) =>
      _map('admin_update_commission_config', {
        'p_commission_enabled': enabled,
        'p_default_commission_rate': defaultRate,
      });

  Future<AdminListPage> listCommissionRules({
    String? search,
    bool? isActive,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_commission_rules', {
      'p_search': search,
      'p_is_active': isActive,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> upsertCommissionRule({
    String? id,
    String? boothId,
    required num ratePercent,
    bool? isActive,
  }) =>
      _map('admin_upsert_commission_rule', {
        'p_id': id,
        'p_booth_id': boothId,
        'p_rate_percent': ratePercent,
        'p_is_active': isActive,
        'p_effective_from': null,
      });

  Future<void> deleteCommissionRule(String id) =>
      _void('admin_delete_commission_rule', {'p_id': id});

  Future<AdminListPage> listShippingRates({
    String? city,
    bool? isActive,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_shipping_rates', {
      'p_city': city,
      'p_is_active': isActive,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<Map<String, dynamic>> upsertShippingRate({
    String? id,
    required String city,
    required int minWeightGrams,
    required int maxWeightGrams,
    required num rateAmount,
    bool? isActive,
  }) =>
      _map('admin_upsert_shipping_rate', {
        'p_id': id,
        'p_city': city,
        'p_min_weight_grams': minWeightGrams,
        'p_max_weight_grams': maxWeightGrams,
        'p_rate_amount': rateAmount,
        'p_is_active': isActive,
      });

  Future<void> deleteShippingRate(String id) =>
      _void('admin_delete_shipping_rate', {'p_id': id});

  // ── Settings / notifications / admins / audit ───────────────────────

  Future<Map<String, dynamic>> getSettings() =>
      _map('admin_get_settings', {});

  Future<Map<String, dynamic>> updateSettings({
    String? marketplaceName,
    String? supportPhone,
    String? supportEmail,
    bool? maintenanceMode,
    String? maintenanceMessage,
    bool? requireProductModeration,
  }) =>
      _map('admin_update_settings', {
        'p_marketplace_name': marketplaceName,
        'p_support_phone': supportPhone,
        'p_support_email': supportEmail,
        'p_maintenance_mode': maintenanceMode,
        'p_maintenance_message': maintenanceMessage,
        'p_require_product_moderation': requireProductModeration,
      });

  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String body,
    required String targetType,
    List<String>? targetIds,
    String? notificationType,
    String? deepLink,
  }) =>
      _map('admin_send_notification', {
        'p_title': title,
        'p_body': body,
        'p_target_type': targetType,
        'p_target_ids': targetIds,
        'p_notification_type': notificationType,
        'p_deep_link': deepLink,
      });

  Future<AdminListPage> listNotificationCampaigns({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_notification_campaigns', {
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  Future<List<Map<String, dynamic>>> listAdminAccounts() async {
    final page = await _list('admin_list_admin_accounts', {});
    return page.items;
  }

  Future<Map<String, dynamic>> updateAdminRole({
    required String userId,
    required String role,
  }) =>
      _map('update_admin_role', {
        'p_user_id': userId,
        'p_role': role,
      });

  Future<AdminListPage> listAuditLogs({
    String? adminId,
    String? action,
    String? resourceType,
    String? search,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) {
    return _list('admin_list_audit_logs', {
      'p_admin_id': adminId,
      'p_action': action,
      'p_resource_type': resourceType,
      'p_search': search,
      'p_limit': pageSize,
      'p_offset': (page - 1) * pageSize,
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  Future<AdminListPage> _list(
    String rpc,
    Map<String, dynamic> params,
  ) async {
    try {
      final data = await _client.rpc<dynamic>(rpc, params: params);
      return _parsePage(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> _map(
    String rpc,
    Map<String, dynamic> params,
  ) async {
    try {
      final data = await _client.rpc<dynamic>(rpc, params: params);
      if (data is Map) return Map<String, dynamic>.from(data);
      if (data is List && data.isNotEmpty && data.first is Map) {
        return Map<String, dynamic>.from(data.first as Map);
      }
      return {'raw': data};
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> _void(String rpc, Map<String, dynamic> params) async {
    try {
      await _client.rpc<void>(rpc, params: params);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  AdminListPage _parsePage(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final rawItems = map['items'] ?? map['data'] ?? map['rows'] ?? [];
      final items = <Map<String, dynamic>>[];
      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map) items.add(Map<String, dynamic>.from(item));
        }
      } else if (map.values.any((v) => v is List)) {
        // Some RPCs return a bare object wrapping a list under another key.
        for (final value in map.values) {
          if (value is List) {
            for (final item in value) {
              if (item is Map) items.add(Map<String, dynamic>.from(item));
            }
            break;
          }
        }
      }
      final total =
          map['total_count'] ?? map['total'] ?? map['count'] ?? items.length;
      return AdminListPage(
        items: items,
        total: total is int ? total : int.tryParse('$total') ?? items.length,
      );
    }

    if (data is List) {
      final items = <Map<String, dynamic>>[];
      for (final item in data) {
        if (item is Map) items.add(Map<String, dynamic>.from(item));
      }
      return AdminListPage(items: items, total: items.length);
    }

    return const AdminListPage(items: [], total: 0);
  }
}

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource?>((ref) {
  if (!SupabaseConfig.isInitialized) return null;
  return AdminRemoteDataSource(SupabaseConfig.client);
});
