class User {
  final int? id;
  String? firstName;
  String? lastName;
  final String? avatar;
  final DateTime? dob;
  String email;
  String mobile;
  final bool? isActive;
  final int? roleId;
  bool? termsAndConditions = true;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  String? street;
  String? state;
  String? city;
  String? zipCode;
  String? authProviderId;
  bool? enableEmailNotifications;
  bool? enablePushNotifications;
  final String paymentSetup;
  final String kycStatus;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.avatar,
    this.dob,
    required this.email,
    required this.mobile,
    this.isActive,
    this.roleId,
    this.termsAndConditions = true,
    this.createdAt,
    this.updatedAt,
    this.street,
    this.state,
    this.city,
    this.zipCode,
    this.authProviderId,
    this.enableEmailNotifications,
    this.enablePushNotifications,
    required this.paymentSetup,
    required this.kycStatus,
  });

  // Factory method to create an instance of User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatar: json['avatar'] as String?,
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      isActive: json['is_active'] as bool?,
      roleId: json['role_id'] as int?,
      termsAndConditions: json['terms_and_conditions'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      street: json['street'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      zipCode: json['zip_code'] as String?,
      authProviderId: json['auth_provider_id'] as String?,
      enableEmailNotifications:
          json['enable_email_notifications'] as bool? ?? true,
      enablePushNotifications:
          json['enable_push_notifications'] as bool? ?? true,
      paymentSetup: json['payment_setup'] != null
          ? json['payment_setup'] as String
          : 'incomplete',
      kycStatus: json['kyc_status'] != null
          ? json['kyc_status'] as String
          : 'incomplete',
    );
  }

  // Convert User instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'dob': dob?.toIso8601String(),
      'email': email,
      'mobile': mobile,
      'is_active': isActive,
      'role_id': roleId,
      'terms_and_conditions': termsAndConditions,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'street': street,
      'state': state,
      'city': city,
      'zip_code': zipCode,
      'auth_provider_id': authProviderId,
      'enable_email_notifications': enableEmailNotifications,
      'enable_push_notifications': enablePushNotifications,
      'payment_setup': paymentSetup,
      'kyc_status': kycStatus,
    };
  }

  // toString method for better readability when printing User objects
  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, avatar: $avatar, dob: $dob, email: $email, mobile: $mobile, isActive: $isActive, roleId: $roleId, termsAndConditions: $termsAndConditions, createdAt: $createdAt, updatedAt: $updatedAt, street: $street, state: $state, city: $city, zipCode: $zipCode, authProviderId: $authProviderId, enableEmailNotification: $enableEmailNotifications, enablePushNotification: $enablePushNotifications, paymentSetup: $paymentSetup, kycStatus: $kycStatus)';
  }

  // Equality override for comparing User objects
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.avatar == avatar &&
        other.dob == dob &&
        other.email == email &&
        other.mobile == mobile &&
        other.isActive == isActive &&
        other.roleId == roleId &&
        other.termsAndConditions == termsAndConditions &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.street == street &&
        other.state == state &&
        other.city == city &&
        other.zipCode == zipCode &&
        other.authProviderId == authProviderId &&
        other.enableEmailNotifications == enableEmailNotifications &&
        other.enablePushNotifications == enablePushNotifications &&
        other.paymentSetup == paymentSetup &&
        other.kycStatus == kycStatus;
  }

  // Generate hash code for User instance
  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        avatar.hashCode ^
        dob.hashCode ^
        email.hashCode ^
        mobile.hashCode ^
        isActive.hashCode ^
        roleId.hashCode ^
        termsAndConditions.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        street.hashCode ^
        state.hashCode ^
        city.hashCode ^
        zipCode.hashCode ^
        authProviderId.hashCode ^
        enableEmailNotifications.hashCode ^
        enablePushNotifications.hashCode ^
        paymentSetup.hashCode ^
        kycStatus.hashCode;
  }

  // Create a copyWith method to clone the object with new values
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? avatar,
    DateTime? dob,
    String? email,
    String? password,
    String? mobile,
    bool? isActive,
    int? roleId,
    bool? termsAndConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? street,
    String? state,
    String? city,
    String? zipCode,
    String? authProviderId,
    bool? enableEmailNotifications,
    bool? enablePushNotifications,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      isActive: isActive ?? this.isActive,
      roleId: roleId ?? this.roleId,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      street: street ?? this.street,
      state: state ?? this.state,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      authProviderId: authProviderId ?? this.authProviderId,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      paymentSetup: paymentSetup,
      kycStatus: kycStatus,
    );
  }
}
