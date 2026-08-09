/// health_records_home_page.dart
///
/// Backwards-compatibility shim.
///
/// The old [HealthRecordsHomePage] static prototype has been replaced by the
/// fully-functional [HealthRecordsPage]. This file makes [HealthRecordsHomePage]
/// a typedef alias for [HealthRecordsPage] so every existing call-site
/// (`const HealthRecordsHomePage()`, imports, barrel exports) keeps working
/// without any changes, and the user always sees the dynamic live page.
library;

import 'health_records_page.dart';

export 'health_records_page.dart';

/// Drop-in alias — [HealthRecordsHomePage] is now identical to [HealthRecordsPage].
typedef HealthRecordsHomePage = HealthRecordsPage;
