// Shared data models for the admin dashboard

class AdminUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final bool emailVerified;
  final String language;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final int totalConversations;
  final int totalEmergencyAssessments;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.emailVerified,
    required this.language,
    required this.createdAt,
    this.lastLogin,
    this.totalConversations = 0,
    this.totalEmergencyAssessments = 0,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        fullName: json['full_name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String,
        isActive: json['is_active'] as bool,
        emailVerified: json['email_verified'] as bool? ?? false,
        language: json['language'] as String? ?? 'en',
        createdAt: DateTime.parse(json['created_at'] as String),
        lastLogin: json['last_login'] != null
            ? DateTime.parse(json['last_login'] as String)
            : null,
        totalConversations: json['total_conversations'] as int? ?? 0,
        totalEmergencyAssessments:
            json['total_emergency_assessments'] as int? ?? 0,
      );
}

class DashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int totalChatbotConversations;
  final int chatbotConversationsToday;
  final int totalEmergencyAssessments;
  final int emergencyAssessmentsToday;
  final int highRiskEmergencies;
  final int totalHealthArticles;
  final int publishedArticles;
  final int totalSymptomChecks;
  final int totalSosEvents;

  const DashboardStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.totalChatbotConversations,
    required this.chatbotConversationsToday,
    required this.totalEmergencyAssessments,
    required this.emergencyAssessmentsToday,
    required this.highRiskEmergencies,
    required this.totalHealthArticles,
    required this.publishedArticles,
    required this.totalSymptomChecks,
    required this.totalSosEvents,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        totalUsers: j['total_users'] as int? ?? 0,
        activeUsers: j['active_users'] as int? ?? 0,
        newUsersToday: j['new_users_today'] as int? ?? 0,
        newUsersThisWeek: j['new_users_this_week'] as int? ?? 0,
        totalChatbotConversations:
            j['total_chatbot_conversations'] as int? ?? 0,
        chatbotConversationsToday:
            j['chatbot_conversations_today'] as int? ?? 0,
        totalEmergencyAssessments:
            j['total_emergency_assessments'] as int? ?? 0,
        emergencyAssessmentsToday:
            j['emergency_assessments_today'] as int? ?? 0,
        highRiskEmergencies: j['high_risk_emergencies'] as int? ?? 0,
        totalHealthArticles: j['total_health_articles'] as int? ?? 0,
        publishedArticles: j['published_articles'] as int? ?? 0,
        totalSymptomChecks: j['total_symptom_checks'] as int? ?? 0,
        totalSosEvents: j['total_sos_events'] as int? ?? 0,
      );

  static DashboardStats get empty => const DashboardStats(
        totalUsers: 0,
        activeUsers: 0,
        newUsersToday: 0,
        newUsersThisWeek: 0,
        totalChatbotConversations: 0,
        chatbotConversationsToday: 0,
        totalEmergencyAssessments: 0,
        emergencyAssessmentsToday: 0,
        highRiskEmergencies: 0,
        totalHealthArticles: 0,
        publishedArticles: 0,
        totalSymptomChecks: 0,
        totalSosEvents: 0,
      );
}

class EmergencyItem {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final int? age;
  final String? gender;
  final List<String> symptoms;
  final String riskLevel;
  final int riskScore;
  final bool isEmergency;
  final String? emergencyType;
  final String? possibleEmergency;
  final bool sosRequired;
  final int sosCount;
  final DateTime createdAt;

  const EmergencyItem({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.age,
    this.gender,
    required this.symptoms,
    required this.riskLevel,
    required this.riskScore,
    required this.isEmergency,
    this.emergencyType,
    this.possibleEmergency,
    required this.sosRequired,
    required this.sosCount,
    required this.createdAt,
  });

  factory EmergencyItem.fromJson(Map<String, dynamic> j) => EmergencyItem(
        id: j['id'] as String,
        userId: j['user_id'] as String?,
        userName: j['user_name'] as String?,
        userEmail: j['user_email'] as String?,
        age: j['age'] as int?,
        gender: j['gender'] as String?,
        symptoms: (j['symptoms'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        riskLevel: j['risk_level'] as String? ?? 'LOW',
        riskScore: j['risk_score'] as int? ?? 0,
        isEmergency: j['is_emergency'] as bool? ?? false,
        emergencyType: j['emergency_type'] as String?,
        possibleEmergency: j['possible_emergency'] as String?,
        sosRequired: j['sos_required'] as bool? ?? false,
        sosCount: j['sos_count'] as int? ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class HealthArticle {
  final String id;
  final String title;
  final String? summary;
  final String content;
  final String? categoryId;
  final String? categoryName;
  final String language;
  final String? author;
  final int readTimeMin;
  final List<String> tags;
  final bool isFeatured;
  final bool isPublished;
  final int viewCount;
  final int bookmarkCount;
  final String? emoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HealthArticle({
    required this.id,
    required this.title,
    this.summary,
    required this.content,
    this.categoryId,
    this.categoryName,
    required this.language,
    this.author,
    required this.readTimeMin,
    required this.tags,
    required this.isFeatured,
    required this.isPublished,
    required this.viewCount,
    required this.bookmarkCount,
    this.emoji,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HealthArticle.fromJson(Map<String, dynamic> j) => HealthArticle(
        id: j['id'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String?,
        content: j['content'] as String,
        categoryId: j['category_id'] as String?,
        categoryName: j['category_name'] as String?,
        language: j['language'] as String? ?? 'en',
        author: j['author'] as String?,
        readTimeMin: j['read_time_min'] as int? ?? 3,
        tags: (j['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        isFeatured: j['is_featured'] as bool? ?? false,
        isPublished: j['is_published'] as bool? ?? true,
        viewCount: j['view_count'] as int? ?? 0,
        bookmarkCount: j['bookmark_count'] as int? ?? 0,
        emoji: j['emoji'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}

class ActivityLog {
  final String id;
  final String? adminId;
  final String? adminName;
  final String action;
  final String module;
  final String? targetId;
  final String? description;
  final String? ipAddress;
  final String severity;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    this.adminId,
    this.adminName,
    required this.action,
    required this.module,
    this.targetId,
    this.description,
    this.ipAddress,
    required this.severity,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> j) => ActivityLog(
        id: j['id'] as String,
        adminId: j['admin_id'] as String?,
        adminName: j['admin_name'] as String?,
        action: j['action'] as String,
        module: j['module'] as String,
        targetId: j['target_id'] as String?,
        description: j['description'] as String?,
        ipAddress: j['ip_address'] as String?,
        severity: j['severity'] as String? ?? 'info',
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class SystemSetting {
  final String id;
  final String key;
  final String? value;
  final String valueType;
  final String category;
  final String? description;
  final bool isPublic;

  const SystemSetting({
    required this.id,
    required this.key,
    this.value,
    required this.valueType,
    required this.category,
    this.description,
    required this.isPublic,
  });

  factory SystemSetting.fromJson(Map<String, dynamic> j) => SystemSetting(
        id: j['id'] as String,
        key: j['key'] as String,
        value: j['value'] as String?,
        valueType: j['value_type'] as String? ?? 'string',
        category: j['category'] as String? ?? 'general',
        description: j['description'] as String?,
        isPublic: j['is_public'] as bool? ?? false,
      );
}

class ChatConversation {
  final int id;
  final String userId;
  final String? userName;
  final String title;
  final String language;
  final int messageCount;
  final int emergencyCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.userId,
    this.userName,
    required this.title,
    required this.language,
    required this.messageCount,
    required this.emergencyCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> j) =>
      ChatConversation(
        id: j['id'] as int,
        userId: j['user_id'] as String,
        userName: j['user_name'] as String?,
        title: j['title'] as String,
        language: j['language'] as String? ?? 'en',
        messageCount: j['message_count'] as int? ?? 0,
        emergencyCount: j['emergency_count'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}
