class EventUserModel {
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? barcode;
  final bool? isCheckin;
  final String? allowedGuests;
  final String? checkinTime;
  final String? eventTitle;
  final String? registeredGuests;
  final String? phoneNumber;

  EventUserModel({
    this.email,
    this.firstName,
    this.lastName,
    this.barcode,
    this.isCheckin,
    this.allowedGuests,
    this.checkinTime,
    this.eventTitle,
    this.registeredGuests,
    this.phoneNumber,
  });

  factory EventUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final event = json['event'];

    return EventUserModel(
      email: user['email'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      barcode: event['barcode'] ?? '',
      isCheckin: event['is_checkin'] ?? false,
      allowedGuests: event['allowed_guests'] != null
          ? event['allowed_guests'].toString()
          : '',
      checkinTime: event['checkin_datetime'] ?? '',
      eventTitle: event['event_title'] ?? '',
      registeredGuests: event['guest'] != null ? event['guest'].toString() : '',
      phoneNumber: user['mobile'] ?? '',
    );
  }

  factory EventUserModel.fromUsersList(Map<String, dynamic> json) {
    return EventUserModel(
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      barcode: json['barcode'] ?? '',
      isCheckin: json['is_checkin'] ?? false,
      allowedGuests: json['allowed_guests'] != null
          ? json['allowed_guests'].toString()
          : '',
      checkinTime: json['checkin_datetime'] ?? '',
      eventTitle: json['event_title'] ?? '',
      registeredGuests: json['guest'] != null ? json['guest'].toString() : '',
      phoneNumber: json['mobile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'barcode': barcode,
      'isCheckin': isCheckin,
      'allowedGuests': allowedGuests,
      'checkinTime': checkinTime,
      'eventTitle': eventTitle,
      'guest': registeredGuests,
      'mobile': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'EventUserModel(email: $email, firstName: $firstName, lastName: $lastName, barcode: $barcode, isCheckin: $isCheckin, allowedGuests: $allowedGuests, checkinTime: $checkinTime, eventTitle: $eventTitle, guest: $registeredGuests, phoneNumber: $phoneNumber)';
  }
}
