# AI Healthcare Assistant — Admin Dashboard

Complete reference for every module, control, API endpoint, and role permission
in the admin dashboard (`admin_dashboard/`) and its FastAPI backend (`backend/app/admin/`).

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Authentication & Access](#3-authentication--access)
4. [Dashboard (Overview)](#4-dashboard-overview)
5. [User Management](#5-user-management)
6. [Authentication Management](#6-authentication-management)
7. [Doctors](#7-doctors)
8. [User Profiles](#8-user-profiles)
9. [Emergency Detection](#9-emergency-detection)
10. [AI Chatbot](#10-ai-chatbot)
11. [Symptom Checker / Disease Prediction](#11-symptom-checker--disease-prediction)
12. [Health Records](#12-health-records)
13. [Medical History](#13-medical-history)
14. [Health Education](#14-health-education)
15. [Feedback](#15-feedback)
16. [Analytics](#16-analytics)
17. [Reports](#17-reports)
18. [Datasets](#18-datasets)
19. [Activity Logs](#19-activity-logs)
20. [Notifications](#20-notifications)
21. [System Settings](#21-system-settings)
22. [API Reference Summary](#22-api-reference-summary)
23. [Role Permission Matrix](#23-role-permission-matrix)
24. [Running the Admin Dashboard](#24-running-the-admin-dashboard)

---

## 1. Overview

The Admin Dashboard is a **Flutter Web application** that gives admins and super admins
complete control over every module in the AI Healthcare Assistant platform.

| Item | Value |
|---|---|
| Framework | Flutter Web |
| State management | Riverpod (`StateNotifierProvider`) |
| HTTP client | Dio with JWT Bearer + auto-refresh |
| Navigation | GoRouter (declarative, auth-guarded) |
| Backend | FastAPI — all routes under `/api/v1/admin/` |
| Authentication | JWT access token + refresh token (stored in FlutterSecureStorage) |

**Sidebar sections**

| Section | Modules |
|---|---|
| OVERVIEW | Dashboard |
| USER MANAGEMENT | Users, Doctors, Authentication, User Profiles |
| MODULES | Emergency, AI Chatbot, Disease Prediction, Health Records, Medical History, Education, Feedback |
| DATA & INSIGHTS | Analytics, Reports, Datasets |
| SYSTEM | Activity Logs, Notifications, Settings |

---

## 2. Architecture

```
admin_dashboard/
  lib/
    core/
      api.dart          # Dio singleton, JWT interceptor, token refresh
      models.dart       # Shared Dart models (AdminUser, EmergencyItem, …)
      router.dart       # GoRouter — 19 routes, auth redirect
      theme.dart        # AppColors, AppTheme (light + dark)
      constants.dart    # API base URL, storage keys
    features/
      dashboard/        # KPI stats, system health, trend charts
      users/            # Full CRUD + bulk actions + export
      authentication/   # Sessions, tokens, OTP logs
      doctors/          # Doctor accounts management
      profile/          # User profiles, addresses, emergency contacts, medical info
      emergency/        # Assessments, risk config
      chatbot/          # Conversations, config
      disease_prediction/ # Model stats, history, config
      health_records/   # Profiles, prescriptions, images, timeline
      health_records/   # medical_history_page.dart — Medical History tab
      education/        # Articles CRUD
      feedback/         # Feedback CRUD
      analytics/        # Symptom analytics charts
      reports/          # Time-range reports
      dataset/          # Dataset version management
      logs/             # Activity audit log
      notifications/    # Admin notifications
      settings/         # System settings key-value editor
    shared/widgets/
      sidebar.dart      # Collapsible nav with notification badge
      top_bar.dart      # Search, theme toggle, notifications, user menu
      stat_card.dart    # Reusable KPI card
      data_table_card.dart # Paginated table with search + filters
      app_shell.dart    # Sidebar + top bar shell wrapper

backend/app/admin/
  routes.py   # ~2,500 lines — all admin API endpoints
  service.py  # Business logic for dashboard, users, emergency, chatbot, education, …
  models.py   # AdminActivityLog, SystemSetting, DatasetVersion, AdminNotification
  schemas.py  # Pydantic request/response schemas
  seed.py     # Seeds super_admin account + default SystemSettings

backend/app/feedback/
  models.py   # UserFeedback table
  schemas.py  # FeedbackCreate, FeedbackItem, FeedbackStatsResponse
  service.py  # CRUD + stats
  routes.py   # Public POST /feedback + admin CRUD endpoints
```

---

## 3. Authentication & Access

### Login
- URL: `/login`
- Calls `POST /api/v1/auth/login`
- Stores `access_token` + `refresh_token` in FlutterSecureStorage
- Auto-redirects unauthenticated users to `/login` via GoRouter redirect

### Token refresh
- Dio interceptor catches HTTP 401, calls `POST /api/v1/auth/refresh` automatically
- On refresh failure: clears tokens, redirects to login

### Roles

| Role | Level | Key permissions |
|---|---|---|
| `patient` | 0 | Mobile app only — no dashboard access |
| `doctor` | 1 | Mobile app only — no dashboard access |
| `admin` | 2 | Full read + most write actions |
| `super_admin` | 3 | All admin actions + role changes + delete + config changes |

All admin routes require at minimum `admin` or `super_admin` role.
Actions marked **Super Admin only** require `super_admin`.

---

## 4. Dashboard (Overview)

**Route:** `/dashboard`

### KPI Stats Cards (real-time from backend)
| Card | Value |
|---|---|
| Total Users | All registered users |
| Active Users | `is_active = true` |
| New Today | Created today |
| New This Week | Created in last 7 days |
| Total Chatbot Conversations | All-time |
| Conversations Today | Created today |
| Total Emergency Assessments | All-time |
| Emergency Today | Created today |
| High Risk Emergencies | Risk level HIGH or CRITICAL |
| Total Articles | Health education articles |
| Published Articles | `is_published = true` |
| Total SOS Events | SOS triggers all-time |

### Charts
- **User Growth** — daily new users for past 30 days (line chart)
- **Emergency Trend** — daily total + high-risk count for past 14 days
- **Chatbot Trend** — daily new conversations for past 14 days

### System Health
Real-time status badges: Database · API · Chatbot · Emergency System

### Quick Actions
Links directly to: Add User, Create Article, View Emergency Alerts, Analytics

### API endpoints used
```
GET /api/v1/admin/dashboard
GET /api/v1/admin/dashboard/stats
GET /api/v1/admin/system/health
GET /api/v1/admin/system/metrics
```

---

## 5. User Management

**Route:** `/users`

### Controls

| Control | Action | Role |
|---|---|---|
| Search | Filter by name or email (live, 2+ chars) | Admin |
| Role filter | All / patient / doctor / admin / super_admin | Admin |
| Status filter | All / Active / Inactive | Admin |
| View Detail | Full dialog: name, email, phone, role, status, email verified, language, chat count, emergency count, join date, last login | Admin |
| Activate / Deactivate | Toggle `is_active` per user | Admin |
| Change Role | Dropdown → patient / doctor / admin / super_admin | Super Admin |
| Delete User | Confirmation dialog → permanent delete | Super Admin |
| Add User | Dialog: full name, email, password, phone, role → `POST /admin/users` (email auto-verified) | Admin |
| Bulk Select | Checkbox per row + Select All | Admin |
| Bulk Activate | All selected → `is_active = true` | Admin |
| Bulk Deactivate | All selected → `is_active = false` | Admin |
| Bulk Delete | All selected → permanent delete with count report | Super Admin |
| Export CSV | Downloads `users_export.csv` via `GET /admin/export/users` | Admin |
| Pagination | Page size 20, first/prev/next/last buttons | Admin |

### Stats chips (live)
Total · Active · Inactive · Doctors · Admins

### API endpoints used
```
GET    /api/v1/admin/users
GET    /api/v1/admin/users/{user_id}
POST   /api/v1/admin/users
PATCH  /api/v1/admin/users/{user_id}/status
PATCH  /api/v1/admin/users/{user_id}/role
DELETE /api/v1/admin/users/{user_id}
POST   /api/v1/admin/users/bulk-action
GET    /api/v1/admin/export/users
```

---

## 6. Authentication Management

**Route:** `/authentication`

Three tabs: **Active Sessions** · **Refresh Tokens** · **OTP Logs**

### Stats Cards
| Card | Value |
|---|---|
| Active Sessions | Currently logged-in users |
| Active Tokens | Valid (non-revoked, non-expired) refresh tokens |
| Pending OTPs | Unused OTP codes |
| Unverified Emails | Users with `email_verified = false` |

### Active Sessions tab

| Column | Description |
|---|---|
| User | Name + email |
| IP Address | Client IP at login |
| Device | User-agent string (truncated) |
| Status | Active / Expired / Revoked badge |
| Last Active | Timestamp |
| Expires | Expiry timestamp |
| Actions | Revoke Session · Revoke All for User |

**Revoke Session** — sets `is_active = false` on that session → user logged out on next request.
**Revoke All for User** — revokes all sessions AND all refresh tokens for that user.

### Refresh Tokens tab
| Column | Description |
|---|---|
| User | Name + email |
| IP Address | |
| Device | |
| Status | Valid / Revoked / Expired |
| Expires | |
| Last Used | |
| Actions | Revoke Token |

### OTP Logs tab (audit, read-only)
| Column | Description |
|---|---|
| User | Name + email |
| Purpose | email_verification / phone_verification / password_reset / login |
| Attempts | How many times used |
| Status | Used / Pending / Expired |
| Expires | |
| Created | |

### Additional actions (Super Admin)
- **Manually verify email** for any user: `PATCH /admin/auth/verify-email/{user_id}`
- **Manually verify phone** for any user: `PATCH /admin/auth/verify-phone/{user_id}`

### API endpoints used
```
GET    /api/v1/admin/auth/sessions
DELETE /api/v1/admin/auth/sessions/{session_id}
DELETE /api/v1/admin/auth/sessions/user/{user_id}
GET    /api/v1/admin/auth/tokens
DELETE /api/v1/admin/auth/tokens/{token_id}
GET    /api/v1/admin/auth/otp-logs
PATCH  /api/v1/admin/auth/verify-email/{user_id}
PATCH  /api/v1/admin/auth/verify-phone/{user_id}
```

---

## 7. Doctors

**Route:** `/doctors`

| Control | Action | Role |
|---|---|---|
| Search | Filter by name or email | Admin |
| Status filter | Active / Inactive | Admin |
| View Detail | Name, email, phone, verified status, last login | Admin |
| Create Doctor | Dialog: full name, email, password, phone → `POST /admin/doctors` (email auto-verified) | Super Admin |
| Activate / Deactivate | Toggle per doctor account | Admin |
| Pagination | Page size 20 | Admin |

### API endpoints used
```
GET   /api/v1/admin/doctors
POST  /api/v1/admin/doctors
PATCH /api/v1/admin/doctors/{doctor_id}/status
```

---

## 8. User Profiles

**Route:** `/profile`

Four tabs: **User Profiles** · **Addresses** · **Emergency Contacts** · **Medical Info**

### User Profiles tab

| Column | Description |
|---|---|
| User | Name + email |
| Date of Birth | |
| Gender | |
| Blood Group | |
| Height / Weight | cm and kg |
| Occupation | |
| Actions | View Detail · Edit |

**Edit dialog** (saves to backend): Gender, Marital Status, Occupation, Bio
→ `PATCH /admin/profiles/{profile_id}`

### Addresses tab
Shows: User, Address Type (home/work/other), Street, Municipality, District, State, Country, Postal Code, Primary flag

### Emergency Contacts tab
Shows: User, Contact Name, Relationship, Phone, Email, Priority (#1 = primary)

### Medical Info tab
Shows: User, Blood Group, Allergies count, Chronic Diseases count, Medications count, Smoking status, Alcohol consumption, Notes

All tabs are paginated with page size 20.

### API endpoints used
```
GET   /api/v1/admin/profiles/list
PATCH /api/v1/admin/profiles/{profile_id}
GET   /api/v1/admin/profiles/addresses
GET   /api/v1/admin/profiles/emergency-contacts
GET   /api/v1/admin/profiles/medical-info
```

---

## 9. Emergency Detection

**Route:** `/emergency`

### Stats Grid (8 cards)
Total Cases · Critical · High Risk · SOS Triggered · This Week · Medium Risk · Low Risk · Today

### Risk Breakdown Bar
Visual proportional bar: Critical (purple) | High (red) | Medium (amber) | Low (green)

### Assessments Table

| Column | Description |
|---|---|
| Patient | Name + Age/Gender |
| Risk Level | Colour-coded badge: CRITICAL / HIGH / MEDIUM / LOW |
| Score | Progress bar + percentage |
| Type | Possible emergency type string |
| Symptoms | First 3 symptoms listed |
| SOS | SOS icon if `sos_required = true` |
| Actions | View Detail |
| Date | Created timestamp |

Filters: Risk Level dropdown · Emergency Only toggle
Rows colour-highlighted: CRITICAL rows have faint purple background, HIGH rows faint red.

**View Detail dialog** shows: patient, age/gender, risk score, risk level, emergency type, possible emergency, SOS required, SOS count, full symptom chips list.

### Risk Config Dialog (editable, saves to backend)

| Field | Type | Description |
|---|---|---|
| Critical Threshold | Number input (0–100) | Score above this = CRITICAL |
| High Threshold | Number input (0–100) | Score above this = HIGH |
| Medium Threshold | Number input (0–100) | Score above this = MEDIUM |
| Auto SOS Threshold | Number input (0–100) | Score above this triggers auto-SOS |
| Auto-trigger SOS | Toggle | Enable/disable automatic SOS |
| Notify Admin on SOS | Toggle | Send admin notification on SOS trigger |

Saved via `PUT /admin/emergency/config` → persisted to `system_settings` table.
Loading shows live values from `GET /admin/emergency/config`.
Requires **Super Admin**.

### Export
`GET /admin/export/emergency` → downloads `emergency_export.csv`

### API endpoints used
```
GET /api/v1/admin/emergency
GET /api/v1/admin/emergency/stats
GET /api/v1/admin/emergency/config
PUT /api/v1/admin/emergency/config          (Super Admin)
GET /api/v1/admin/export/emergency
```

---

## 10. AI Chatbot

**Route:** `/chatbot`

### Stats Cards (4)
Total Conversations · Active Conversations · Total Messages · Emergency Flags

### Language Distribution Card
Horizontal progress bars for EN / NE (Nepali) / HI (Hindi) / BH (Bhojpuri) with count and percentage.

### Conversations Table

| Column | Description |
|---|---|
| User | Avatar initial + name |
| Title | Conversation title (truncated) |
| Language | EN / NE / HI / BH chip |
| Messages | Count |
| Emergency | Red warning badge with count if flagged |
| Status | Active / Closed |
| Created | Timestamp |
| Actions | Delete |

Filters: Language · Has Emergency (yes/no)
Search: conversation title

**Delete conversation** — confirmation dialog → permanent delete including all messages.

### Config Dialog (fully editable, saves to backend)

| Field | Type | Default |
|---|---|---|
| Model | Read-only label | gemini-1.5-flash |
| Temperature | Slider 0.0–1.0 | 0.7 |
| Max Tokens | Number field | 2048 |
| Context Window | Number field (messages) | 10 |
| Safety Settings | Dropdown: low / medium / high / block_all | high |
| Emergency Detection | Toggle | enabled |

Saved via `PUT /admin/chatbot/config` → persisted to `system_settings` table.
Requires **Super Admin**.

### API endpoints used
```
GET    /api/v1/admin/chatbot/conversations
GET    /api/v1/admin/chatbot/stats
GET    /api/v1/admin/chatbot/config
PUT    /api/v1/admin/chatbot/config            (Super Admin)
DELETE /api/v1/admin/chatbot/conversations/{id}
```

---

## 11. Symptom Checker / Disease Prediction

**Route:** `/disease-prediction`

### Model Status Card
Live badge: LOADED (green) or NOT LOADED (red)
Shows: model version, available symptoms count, available diseases count.

### Stats Cards
Total Predictions · Emergency Flags · Top Predicted Disease

### Top 10 Predicted Diseases
Horizontal bar list with disease name and count.

### Prediction History Table

| Column | Description |
|---|---|
| Patient | Name (or Anonymous) |
| Symptoms | Chip list (first 5) |
| Age / Gender | |
| Predicted Disease | |
| Confidence | Percentage |
| Risk Level | Colour badge |
| Emergency | Flag icon if true |
| Date | Timestamp |

Filters: Risk Level · Is Emergency (yes/no)
Paginated, page size 20.

### Hot-Reload Model Button
`POST /admin/disease-prediction/reload-model` — reloads ML model from disk without restart.
Requires **Super Admin**. Shows success/failure snackbar with new model info.

### Symptom Checker Config (in Settings page)
Saved to `system_settings` table:
- `symptom_confidence_threshold` — minimum confidence to accept prediction
- `symptom_emergency_keywords` — JSON array of emergency keyword phrases
- `symptom_risk_thresholds` — JSON object with critical/high/medium/low values

### API endpoints used
```
GET  /api/v1/admin/disease-prediction/stats
GET  /api/v1/admin/disease-prediction/history
POST /api/v1/admin/disease-prediction/reload-model    (Super Admin)
GET  /api/v1/admin/symptom-checker/config
PUT  /api/v1/admin/symptom-checker/config             (Super Admin)
```

---

## 12. Health Records

**Route:** `/health-records`

### Stats Cards (5)
Medical Profiles · History Entries · Prescriptions · Medical Images · Timeline Events

### Tabs

**Overview tab** — summary table + privacy notice (records are patient-owned, admin sees aggregated data).

**Medical Profiles tab**
Columns: Patient, Blood Group, Height, Weight, BMI, Allergies count, Chronic Diseases count, Actions (View Detail)
Detail dialog: full profile including smoking/alcohol status, activity level, family history, medications.

**Prescriptions tab**
Search by doctor/hospital/diagnosis.
Columns: Patient, Doctor, Hospital, Diagnosis, Medicines count, Date, Valid Until, Actions (View Detail)
Detail dialog: full medicine list with dose and frequency.

**Medical Images tab**
Filter by image type: xray / mri / ct_scan / blood_report / ecg / skin / other
Columns: Patient, Title, Type badge, Body Part, Doctor, Hospital, Scan Date

**Timeline tab**
Columns: Patient, Event Type badge, Title (with emoji), Description, Event Date
Event types: prescription / medical_image / medical_history / symptom_assessment / emergency_assessment

All tabs read-only (patient-owned clinical data — admin oversight only).

### API endpoints used
```
GET /api/v1/admin/health-records/stats
GET /api/v1/admin/health-records/profiles
GET /api/v1/admin/health-records/prescriptions
GET /api/v1/admin/health-records/images
GET /api/v1/admin/health-records/timeline
```

---

## 13. Medical History

**Route:** `/medical-history`

### Stats Cards
Total Entries · Current · Past · Surgery · Chronic · Family · Active · Resolved · Managed

### Table

| Column | Description |
|---|---|
| Patient | Name + email |
| Disease Name | |
| Category | current / past / surgery / chronic / family |
| Status | active / resolved / managed badge |
| Diagnosis Date | |
| Doctor | |
| Hospital | |
| Notes | Truncated |
| Detail | View button |

Filters: Category · Status
Search: disease name or patient name
Detail dialog: full entry with all fields.

### API endpoints used
```
GET /api/v1/admin/health-records/medical-history
GET /api/v1/admin/health-records/medical-history/stats
```

---

## 14. Health Education

**Route:** `/education`

### Controls

| Control | Action | Role |
|---|---|---|
| Search | Filter by title or summary | Admin |
| Category filter | All categories / specific category ID | Admin |
| Language filter | EN / NE / HI / BH | Admin |
| Published filter | All / Published / Draft | Admin |
| Create Article | Full dialog → `POST /admin/education/articles` | Admin |
| Edit Article | Full dialog pre-filled → `PUT /admin/education/articles/{id}` | Admin |
| Delete Article | Confirmation → `DELETE /admin/education/articles/{id}` | Admin |
| Publish / Unpublish | Via edit dialog `is_published` toggle | Admin |
| Feature / Unfeature | Via edit dialog `is_featured` toggle | Admin |

### Article Table Columns
Title · Category · Language · Author · Tags · Featured badge · Published badge · Views · Bookmarks · Created Date · Actions (Edit, Delete)

### Create / Edit Article Dialog Fields

| Field | Type |
|---|---|
| Title | Text field (required) |
| Summary | Text area |
| Content | Multi-line text area |
| Category | Dropdown |
| Language | EN / NE / HI / BH |
| Author | Text field |
| Source | Text field |
| Read Time (min) | Number |
| Tags | Chip input |
| Is Featured | Toggle |
| Is Published | Toggle |
| Emoji | Text field |

### API endpoints used
```
GET    /api/v1/admin/education/articles
POST   /api/v1/admin/education/articles
PUT    /api/v1/admin/education/articles/{article_id}
DELETE /api/v1/admin/education/articles/{article_id}
```

---

## 15. Feedback

**Route:** `/feedback`

### Stats Grid (8 cards)
Total Feedback · Pending Review · Resolved · Avg Rating · In Progress · This Week · Reviewed · Dismissed

### Breakdown Cards
- **By Category** — progress bar per category with count
- **By Priority** — progress bar per priority with count

### Table

| Column | Description |
|---|---|
| User | Name + email (or "Anonymous") |
| Category | Colour-coded badge |
| Rating | Star icons (1–5, greyed if none) |
| Title / Message | Two-line truncated preview |
| Module | Which app module |
| Priority | low / normal / high / critical badge |
| Status | pending / reviewed / in_progress / resolved / dismissed badge |
| Platform | android / ios / web icon + label |
| Date | Submitted timestamp |
| Actions | View · Edit · Delete |

Filters: Category · Status · Priority · Rating (1–5 stars)
Search: title or message

### View Detail Dialog
Full feedback with all metadata, message body, admin notes (if set).
"Edit Status" button opens the quick-edit dialog.

### Quick-Edit Dialog (saves to backend)

| Field | Options |
|---|---|
| Status | pending / reviewed / in_progress / resolved / dismissed |
| Priority | low / normal / high / critical |
| Admin Notes | Internal text area (not visible to users) |

Saved via `PATCH /admin/feedback/{id}`.
When status set to `resolved`: auto-sets `resolved_by` and `resolved_at`.

### Delete
Permanent with confirmation dialog.

### API endpoints used
```
GET    /api/v1/admin/feedback
GET    /api/v1/admin/feedback/stats
GET    /api/v1/admin/feedback/{feedback_id}
PATCH  /api/v1/admin/feedback/{feedback_id}
DELETE /api/v1/admin/feedback/{feedback_id}
POST   /api/v1/feedback                         (mobile app submits here)
```

---

## 16. Analytics

**Route:** `/analytics`

All charts load from real symptom/emergency assessment data.

### Charts & Visualisations

| Chart | Description | Configurable |
|---|---|---|
| Assessment Trend | Daily assessment count over time | Days (7–90) |
| Symptom Frequency | Top N symptoms by occurrence count | Limit (5–50) |
| Risk Distribution | Count per risk level (CRITICAL/HIGH/MEDIUM/LOW) | — |
| Gender Distribution | Male / Female / Other / Unknown | — |
| Age Group Distribution | <18 / 18–30 / 31–45 / 46–60 / 60+ | — |
| Emergency Types | Top emergency type names by frequency | — |

All data is fetched live from the backend symptom check history.

### API endpoints used
```
GET /api/v1/admin/analytics/stats
GET /api/v1/admin/analytics/symptom-frequency?limit=20
GET /api/v1/admin/analytics/trend?days=30
GET /api/v1/admin/analytics/risk-distribution
GET /api/v1/admin/analytics/gender-distribution
GET /api/v1/admin/analytics/age-distribution
GET /api/v1/admin/analytics/emergency-types
```

---

## 17. Reports

**Route:** `/reports`

Time-range selector: 7 / 14 / 30 / 60 / 90 / 180 / 365 days.

### Report Sections

| Section | Data shown |
|---|---|
| User Registration Trend | Daily new user counts over selected period |
| Chatbot Daily Usage | New conversations per day |
| Emergency Weekly | Emergency assessments grouped by week |
| Symptom Frequency | Most common symptoms in period |
| Risk Distribution | Risk level breakdown with percentages |
| Education Engagement | Article view and bookmark counts |

### API endpoints used
```
GET /api/v1/admin/reports?days=30
```

---

## 18. Datasets

**Route:** `/datasets`

### Stats Card
Total Versions · Active Version · Symptom Datasets · Chatbot Datasets

### Table Columns
Name · Type · Version · Records count · File size (KB) · Active badge · Uploaded by · Created Date · Actions

### Controls

| Control | Action | Role |
|---|---|---|
| Type filter | symptom / chatbot / disease / faq | Admin |
| Register Dataset | Dialog: name, type, version, description → `POST /admin/datasets` | Admin |
| Activate Version | Sets this version active, deactivates all others → `PATCH /admin/datasets/{id}/activate` | Super Admin |
| Delete Version | Permanent with confirmation → `DELETE /admin/datasets/{id}` | Super Admin |
| Pagination | Page size 20 | Admin |

### API endpoints used
```
GET   /api/v1/admin/datasets
GET   /api/v1/admin/datasets/stats
POST  /api/v1/admin/datasets
PATCH /api/v1/admin/datasets/{dataset_id}/activate    (Super Admin)
DELETE /api/v1/admin/datasets/{dataset_id}            (Super Admin)
```

---

## 19. Activity Logs

**Route:** `/logs`

Complete audit trail of every admin action. Append-only (no delete from UI).

### Table Columns
Admin Name · Action · Module · Target ID · Description · IP Address · Severity badge · Timestamp

### Severity colour coding
- `info` — blue
- `warning` — amber
- `error` — red
- `critical` — purple

### Filters
- Module (users / authentication / chatbot / emergency / education / feedback / settings / …)
- Severity (info / warning / error / critical)
- Admin ID (filter to one admin's actions)

### API endpoints used
```
GET /api/v1/admin/logs?module=&severity=&admin_id=&page=1&page_size=50
```

---

## 20. Notifications

**Route:** `/notifications`

Sidebar badge shows unread count (updated on each page load).

### Table Columns
Type badge (info/warning/error/success) · Title · Message · Module · Created · Read status

### Controls
- **Mark as Read** — per notification
- **Mark All as Read** — bulk action in top bar

### API endpoints used
```
GET   /api/v1/admin/notifications
PATCH /api/v1/admin/notifications/{notification_id}/read
```

---

## 21. System Settings

**Route:** `/settings`

All settings are stored in the `system_settings` table as key-value pairs with a `value_type`
(string / int / float / bool / json) and a `category` (ai / security / general / emergency / chatbot).

### Settings grouped by category

#### AI category
| Key | Type | Description |
|---|---|---|
| `chatbot_temperature` | float | LLM sampling temperature |
| `chatbot_max_tokens` | int | Max output tokens |
| `chatbot_context_window` | int | Number of prior messages kept in context |
| `chatbot_safety_settings` | string | low / medium / high / block_all |
| `chatbot_emergency_detection_enabled` | bool | Flag emergency keywords in chat |
| `symptom_confidence_threshold` | float | Min confidence to accept a prediction |
| `symptom_emergency_keywords` | json | Array of emergency keyword phrases |
| `symptom_risk_thresholds` | json | Object with critical/high/medium/low values |

#### Emergency category
| Key | Type | Description |
|---|---|---|
| `emergency_critical_threshold` | int | Risk score threshold for CRITICAL |
| `emergency_high_threshold` | int | Risk score threshold for HIGH |
| `emergency_medium_threshold` | int | Risk score threshold for MEDIUM |
| `emergency_auto_sos_threshold` | int | Score above which SOS is auto-triggered |
| `emergency_auto_sos_enabled` | bool | Enable auto SOS trigger |
| `emergency_notify_admin_on_sos` | bool | Send admin notification on SOS |

#### Security category
| Key | Type | Description |
|---|---|---|
| `jwt_access_expiry_minutes` | int | Access token lifetime |
| `jwt_refresh_expiry_days` | int | Refresh token lifetime |
| `max_login_attempts` | int | Lockout threshold |
| `otp_expiry_minutes` | int | OTP code lifetime |

#### General category
| Key | Type | Description |
|---|---|---|
| `app_name` | string | Application display name |
| `support_email` | string | Contact email shown to users |
| `max_upload_size_mb` | int | Max file upload size |

### Inline editing
Every row has a pencil icon → inline text field → check to save, X to cancel.
Saved via `PATCH /admin/settings/{key}` (requires **Super Admin**).

### Danger Zone
- **Clear Cache** — flushes response cache
- **Export All Data** — downloads full JSON report via `GET /admin/reports?days=365`

### API endpoints used
```
GET   /api/v1/admin/settings
PATCH /api/v1/admin/settings/{key}    (Super Admin)
```

---

## 22. API Reference Summary

All endpoints are under `/api/v1/admin/` unless noted.

### Dashboard
| Method | Path | Description |
|---|---|---|
| GET | /dashboard | Full dashboard response |
| GET | /dashboard/stats | KPI stats only |
| GET | /system/health | System health status |
| GET | /system/metrics | CPU / memory / disk metrics |

### Users
| Method | Path | Role |
|---|---|---|
| GET | /users | Admin |
| GET | /users/{id} | Admin |
| POST | /users | Admin |
| PATCH | /users/{id}/status | Admin |
| PATCH | /users/{id}/role | Super Admin |
| DELETE | /users/{id} | Super Admin |
| POST | /users/bulk-action | Admin |
| GET | /export/users | Admin |

### Authentication
| Method | Path | Role |
|---|---|---|
| GET | /auth/sessions | Admin |
| DELETE | /auth/sessions/{id} | Admin |
| DELETE | /auth/sessions/user/{user_id} | Admin |
| GET | /auth/tokens | Admin |
| DELETE | /auth/tokens/{id} | Admin |
| GET | /auth/otp-logs | Admin |
| PATCH | /auth/verify-email/{user_id} | Super Admin |
| PATCH | /auth/verify-phone/{user_id} | Super Admin |

### Doctors
| Method | Path | Role |
|---|---|---|
| GET | /doctors | Admin |
| POST | /doctors | Super Admin |
| PATCH | /doctors/{id}/status | Admin |

### Profiles
| Method | Path | Role |
|---|---|---|
| GET | /profiles/list | Admin |
| PATCH | /profiles/{id} | Admin |
| GET | /profiles/addresses | Admin |
| GET | /profiles/emergency-contacts | Admin |
| GET | /profiles/medical-info | Admin |

### Emergency
| Method | Path | Role |
|---|---|---|
| GET | /emergency | Admin |
| GET | /emergency/stats | Admin |
| GET | /emergency/config | Admin |
| PUT | /emergency/config | Super Admin |
| GET | /export/emergency | Admin |

### Chatbot
| Method | Path | Role |
|---|---|---|
| GET | /chatbot/conversations | Admin |
| GET | /chatbot/stats | Admin |
| GET | /chatbot/config | Admin |
| PUT | /chatbot/config | Super Admin |
| DELETE | /chatbot/conversations/{id} | Admin |

### Symptom Checker / Disease Prediction
| Method | Path | Role |
|---|---|---|
| GET | /disease-prediction/stats | Admin |
| GET | /disease-prediction/history | Admin |
| POST | /disease-prediction/reload-model | Super Admin |
| GET | /symptom-checker/config | Admin |
| PUT | /symptom-checker/config | Super Admin |

### Health Records
| Method | Path | Role |
|---|---|---|
| GET | /health-records/stats | Admin |
| GET | /health-records/profiles | Admin |
| GET | /health-records/prescriptions | Admin |
| GET | /health-records/images | Admin |
| GET | /health-records/medical-history | Admin |
| GET | /health-records/medical-history/stats | Admin |
| GET | /health-records/timeline | Admin |

### Education
| Method | Path | Role |
|---|---|---|
| GET | /education/articles | Admin |
| POST | /education/articles | Admin |
| PUT | /education/articles/{id} | Admin |
| DELETE | /education/articles/{id} | Admin |

### Feedback (mounted at `/api/v1/`)
| Method | Path | Role |
|---|---|---|
| POST | /feedback | Authenticated user |
| GET | /admin/feedback | Admin |
| GET | /admin/feedback/stats | Admin |
| GET | /admin/feedback/{id} | Admin |
| PATCH | /admin/feedback/{id} | Admin |
| DELETE | /admin/feedback/{id} | Admin |

### Analytics
| Method | Path | Role |
|---|---|---|
| GET | /analytics/stats | Admin |
| GET | /analytics/symptom-frequency | Admin |
| GET | /analytics/trend | Admin |
| GET | /analytics/risk-distribution | Admin |
| GET | /analytics/gender-distribution | Admin |
| GET | /analytics/age-distribution | Admin |
| GET | /analytics/emergency-types | Admin |

### Reports, Datasets, Logs, Notifications, Settings
| Method | Path | Role |
|---|---|---|
| GET | /reports | Admin |
| GET | /datasets | Admin |
| GET | /datasets/stats | Admin |
| POST | /datasets | Admin |
| PATCH | /datasets/{id}/activate | Super Admin |
| DELETE | /datasets/{id} | Super Admin |
| GET | /logs | Admin |
| GET | /notifications | Admin |
| PATCH | /notifications/{id}/read | Admin |
| GET | /settings | Admin |
| PATCH | /settings/{key} | Super Admin |

---

## 23. Role Permission Matrix

| Action | patient | doctor | admin | super_admin |
|---|---|---|---|---|
| Access admin dashboard | — | — | ✓ | ✓ |
| View all users | — | — | ✓ | ✓ |
| Create user | — | — | ✓ | ✓ |
| Activate/deactivate user | — | — | ✓ | ✓ |
| Change user role | — | — | — | ✓ |
| Delete user | — | — | — | ✓ |
| Bulk user actions | — | — | ✓ | ✓ |
| Export users CSV | — | — | ✓ | ✓ |
| Revoke sessions/tokens | — | — | ✓ | ✓ |
| Manually verify email/phone | — | — | — | ✓ |
| Create doctor account | — | — | — | ✓ |
| Activate/deactivate doctor | — | — | ✓ | ✓ |
| Edit user profile | — | — | ✓ | ✓ |
| View emergency assessments | — | — | ✓ | ✓ |
| Edit emergency config | — | — | — | ✓ |
| View chatbot conversations | — | — | ✓ | ✓ |
| Delete conversation | — | — | ✓ | ✓ |
| Edit chatbot config | — | — | — | ✓ |
| View/filter disease predictions | — | — | ✓ | ✓ |
| Reload ML model | — | — | — | ✓ |
| Edit symptom checker config | — | — | — | ✓ |
| View health records (read) | — | — | ✓ | ✓ |
| Create/edit education articles | — | — | ✓ | ✓ |
| Delete education articles | — | — | ✓ | ✓ |
| View/manage feedback | — | — | ✓ | ✓ |
| Delete feedback | — | — | ✓ | ✓ |
| View analytics & reports | — | — | ✓ | ✓ |
| Register/delete datasets | — | — | ✓ | ✓ |
| Activate dataset version | — | — | — | ✓ |
| View activity logs | — | — | ✓ | ✓ |
| View/read notifications | — | — | ✓ | ✓ |
| Edit system settings | — | — | — | ✓ |

---

## 24. Running the Admin Dashboard

### Prerequisites
- Flutter SDK 3.x
- Backend running on `http://localhost:8000` (or configured `API_BASE_URL`)
- Super Admin account seeded (run `python -m app.admin.seed` in `backend/`)

### Start (Windows)
```bat
start_admin_dashboard.bat
```
Or manually:
```powershell
cd admin_dashboard
flutter run -d chrome --web-port 3001
```

### Environment / API base URL
Edit `admin_dashboard/lib/core/constants.dart`:
```dart
static const String apiBase = 'http://localhost:8000/api/v1';
```
Change to your server IP/domain for network access from other devices.

### Default Super Admin credentials
Set in `backend/app/admin/seed.py` (or via env vars):
```
Email:    admin@healthcare.com
Password: Admin@1234
```
Change immediately after first login via Settings → User Management.

### Build for production (web)
```powershell
cd admin_dashboard
flutter build web --release
# Output in admin_dashboard/build/web/
# Serve with nginx, Apache, or any static file server
```

### Flutter Web CORS note
The backend `CORS_ORIGINS` env var must include the admin dashboard URL.
In development, `CORS_ORIGINS=*` is the default. In production, set:
```
CORS_ORIGINS=https://admin.yourdomain.com
```

---

*Generated from source — `backend/app/admin/routes.py`, `backend/app/feedback/routes.py`,
and all files under `admin_dashboard/lib/features/`.*
