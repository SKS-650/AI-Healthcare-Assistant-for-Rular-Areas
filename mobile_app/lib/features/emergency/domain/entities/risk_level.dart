/// Risk classification returned by the AI assessment pipeline.
enum RiskLevel {
  low,
  moderate,
  high,
  critical;

  /// Parse the raw string values returned by the backend API.
  static RiskLevel fromString(String value) {
    return switch (value.toUpperCase()) {
      'LOW'      => RiskLevel.low,
      'MODERATE' => RiskLevel.moderate,
      'HIGH'     => RiskLevel.high,
      'CRITICAL' => RiskLevel.critical,
      _          => RiskLevel.low,
    };
  }

  String get label => switch (this) {
    RiskLevel.low      => 'LOW',
    RiskLevel.moderate => 'MODERATE',
    RiskLevel.high     => 'HIGH',
    RiskLevel.critical => 'CRITICAL',
  };

  String get displayName => switch (this) {
    RiskLevel.low      => 'Low Risk',
    RiskLevel.moderate => 'Moderate Risk',
    RiskLevel.high     => 'High Risk',
    RiskLevel.critical => 'Critical Risk',
  };

  String get emoji => switch (this) {
    RiskLevel.low      => '🟢',
    RiskLevel.moderate => '🟡',
    RiskLevel.high     => '🟠',
    RiskLevel.critical => '🔴',
  };

  String get advice => switch (this) {
    RiskLevel.low      => 'Home care may be sufficient. Monitor symptoms.',
    RiskLevel.moderate => 'Consult a doctor as soon as possible.',
    RiskLevel.high     => 'Go to a hospital immediately.',
    RiskLevel.critical => 'Call ambulance NOW — life-threatening emergency!',
  };

  bool get isEmergency => this == RiskLevel.high || this == RiskLevel.critical;
  bool get requiresSos  => this == RiskLevel.critical;
}
