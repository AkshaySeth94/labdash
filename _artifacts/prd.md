# PRD: Lab Report Management System

## 0. Document Purpose
This document specifies the product requirements for the first version (v1) of the Lab Report Management System. It is intended for the engineering team to understand the "what" and "why" of the product, for QA to formulate test plans, and for stakeholders to align on the scope of the MVP. It defines the target user, features, and success criteria, deliberately omitting implementation details which are captured in a separate technical addendum.

## 1. Vision
The Lab Report Management System aims to bridge the communication gap between diagnostic labs and patients. In a world where instant access to information is standard, waiting for or having to collect physical lab reports is an unnecessary friction point in a patient's healthcare journey. This mobile-first web application will provide patients with immediate, secure access to their lab results and historical data on their smartphones. For lab administrators, it offers a simple, secure, and efficient digital-native workflow for managing and publishing patient reports. Our initial focus is on glucose monitoring, a critical and frequent need for millions, empowering them to better manage their health through timely data.

## 2. Target User
### 2.1 Primary Persona
*   **Patient ("Priya"):** A 45-year-old marketing manager diagnosed with Type 2 diabetes. She checks her phone frequently for work and personal matters and is comfortable using web apps. She needs to track her glucose levels closely and wants to see trends over time to discuss with her doctor. She values convenience and privacy.
*   **Admin ("Amit"):** A 30-year-old lab technician at a mid-sized clinic. He is responsible for entering results from various tests into the clinic's systems. He is often multitasking and needs a tool that is fast, straightforward, and minimizes the chance of data entry errors. He is not a power user and prefers simple, purpose-built interfaces.

### 2.2 Jobs To Be Done
*   **Patient:**
    *   *Functional:* Give me a way to see my latest lab report as soon as it's ready.
    *   *Functional:* Show me my past glucose readings in one place so I can see trends.
    *   *Emotional:* Reduce my anxiety while waiting for results.
    *   *Emotional:* Make me feel more in control of my health data.
*   **Admin:**
    *   *Functional:* Let me enter a patient's glucose result quickly and accurately.
    *   *Functional:* Allow me to find a patient's record easily to add a new report.
    *   *Emotional:* Help me feel confident that patient data is secure and I'm not making mistakes.

## 3. Glossary
*   **System:** The Lab Report Management System web application.
*   **Patient:** An end-user of the System who views their own Reports. Identified by a unique phone number.
*   **Admin:** A privileged user of the System who manages Patients and their Reports via the Admin Panel.
*   **Report:** A digital record of a lab test result for a specific Patient. For v1, this is exclusively a Glucose Marker Report.
*   **Glucose Marker Report:** A type of Report containing a single glucose value, report date, status, and optional notes.
*   **OTP (One-Time Password):** A 6-digit numerical code used for authenticating a Patient.
*   **Patient Dashboard:** The mobile-first web interface a Patient sees after logging in.
*   **Admin Panel:** The secure web interface an Admin uses to perform their duties.

## 4. Features

### 4.1 Patient Authentication
**Description:** Enables Patients to securely access their private dashboard. Authentication is based on the Patient's registered phone number and an OTP.

**Functional Requirements:**

#### FR-1: Patient Login with Phone Number and OTP
A user can log in as a Patient by providing their registered phone number. The System will then prompt for an OTP to complete authentication.
**Consequences:**
- Given a phone number that exists in the System for a Patient, the System displays an OTP entry screen.
- Given a phone number that does not exist, the System displays a "Phone number not found" error message.
- Upon successful OTP validation, the Patient is redirected to their Patient Dashboard.
- Upon incorrect OTP entry, the System displays an "Invalid OTP" error message.

#### FR-2: Static OTP for v1
The System will use a static, hard-coded OTP for all Patient logins in v1.
**Consequences:**
- The System will successfully authenticate any Patient login attempt that uses the phone number on record and the static OTP value `123456`.
- No SMS or other message is sent to the Patient's phone number.

### 4.2 Patient Dashboard
**Description:** The primary interface for Patients, providing access to their lab reports and health data visualizations. The UI must be mobile-first and responsive.

**Functional Requirements:**

#### FR-3: View List of Reports
A logged-in Patient can view a list of all their Reports, sorted by report date in descending order (newest first).
**Consequences:**
- The Patient Dashboard displays a list containing each Report's date, type ("Glucose Marker Report"), and status.
- Clicking/tapping on a list item navigates the Patient to the detailed view for that Report.

#### FR-4: View Report Details
A Patient can view the full details of a single Report.
**Consequences:**
- The detail view displays the Patient's name, the Report date, glucose value (in mg/dL), status, and any notes from the Admin.

#### FR-5: View Glucose Trend Chart
The Patient Dashboard displays a bar chart visualizing the Patient's glucose values over time.
**Consequences:**
- The chart's X-axis represents the Report date.
- The chart's Y-axis represents the glucose value.
- Each bar corresponds to a single Glucose Marker Report.
- The chart displays data from at least the last 10 reports, or all reports if fewer than 10 exist.

### 4.3 Admin Authentication
**Description:** Enables Admins to securely access the Admin Panel. Authentication is based on a phone number and a static password.

**Functional Requirements:**

#### FR-6: Admin Login
A user can log in as an Admin by providing their registered phone number and password.
**Consequences:**
- Upon successful login, the user is redirected to the Admin Panel.
- Upon failed login (incorrect phone number or password), the System displays a "Invalid credentials" error message.

#### FR-7: Seed Initial Admin User
The System must ensure a default Admin user exists for initial access.
**Consequences:**
- If no Admin user exists in the database on application startup, the System creates one with the phone number `9999942496` and password `Hello@123!`.
- The default Admin can successfully log in using these credentials.
- `[ASSUMPTION: The initial admin user credentials are for bootstrapping and will be changed immediately upon first use in a production environment.]`

### 4.4 Admin Panel - Patient Management
**Description:** Admins need a way to manage the patient roster before they can add reports for them.

**Functional Requirements:**

#### FR-8: Create New Patient
An Admin can create a new Patient record in the System.
**Consequences:**
- The Admin Panel provides a form to enter a new Patient's full name and phone number.
- Upon submission, a new Patient record is created. The phone number must be unique across all Patients.
- The System generates a unique, internal Patient ID for the new record.

#### FR-9: View and Select Patient
An Admin can view a list of all Patients and select one to manage their reports.
**Consequences:**
- The Admin Panel displays a searchable or filterable list of all Patients in the System, showing their name and phone number.
- Selecting a Patient from the list navigates the Admin to that Patient's report management view.

### 4.5 Admin Panel - Report Management
**Description:** The core workflow for Admins to create and manage lab reports for Patients.

**Functional Requirements:**

#### FR-10: Create New Report for a Patient
An Admin can create a new Glucose Marker Report for a selected Patient.
**Consequences:**
- After selecting a Patient, the Admin can access a form to create a new Report.
- The form requires a Report Date, Glucose Value (numeric), and Report Status (`Pending` or `Final`). An optional 'Notes' text field is available.
- Upon submission, the new Report is associated with the selected Patient and becomes visible on their Patient Dashboard.

#### FR-11: Edit an Existing Report
An Admin can edit the details of an existing Report.
**Consequences:**
- The Admin can select any existing Report for a Patient and modify its date, glucose value, status, or notes.
- Saving the changes updates the Report, and the updated information is reflected on the Patient Dashboard.

### 4.6 Cross-Cutting NFRs
**Description:** System-wide quality attributes required for v1.

**Functional Requirements:**

#### FR-12: Secure Communication
All communication between the client (browser) and the server must be encrypted.
**Consequences:**
- The System is only accessible over HTTPS.
- Attempts to access the System via HTTP are automatically redirected to HTTPS.

#### FR-13: Role-Based Access Control (RBAC)
The System must enforce strict separation between Patient and Admin roles.
**Consequences:**
- A logged-in Patient can only access API endpoints related to their own data.
- Any attempt by a Patient to access Admin-only endpoints or another Patient's data results in an HTTP 403 Forbidden error.
- An Admin cannot log into the Patient Dashboard.

#### FR-14: Rate Limiting
The System must protect against brute-force login attacks.
**Consequences:**
- The Patient and Admin login endpoints are rate-limited to a maximum of 10 attempts per IP address per minute.
- Exceeding this limit results in an HTTP 429 Too Many Requests error for subsequent requests from that IP for the remainder of the minute.

#### FR-15: Audit Logging
The System must log all state-changing actions performed by Admins.
**Consequences:**
- When an Admin creates or edits a Patient or a Report, an audit log entry is created.
- The log entry includes the Admin's ID, the action performed (e.g., `CREATE_REPORT`), the target entity's ID (e.g., Patient ID, Report ID), and a timestamp.

## 5. Non-Goals (Explicit)
*   **No real SMS gateway integration:** The OTP for Patient login is static for v1.
*   **No Patient self-registration:** Patients are created exclusively by Admins.
*   **No file uploads:** Reports are created by data entry in the Admin Panel, not by uploading PDF or image files.
*   **Single report type:** The System will only support the Glucose Marker Report in v1. The architecture should allow for more types later.
*   **No Admin management UI:** The initial Admin user is seeded. There will be no interface to create, edit, or delete other Admin users in v1.
*   **No password recovery:** Admins who forget their password will require manual intervention (e.g., database update) to regain access.

## 6. MVP Scope
### 6.1 In Scope
*   All Functional Requirements from FR-1 to FR-15.
*   A complete, two-sided application allowing Admins to enter Glucose Marker Reports and Patients to view them.

### 6.2 Out of Scope for MVP
*   Any feature listed in Section 5 (Non-Goals).
*   Integration with any third-party systems (e.g., EMRs, LIS).
*   Push notifications to Patients when a new report is ready.
*   Advanced data filtering or exporting for Patients or Admins.
*   Patient profile management (e.g., changing their phone number).

## 7. Success Metrics
### Primary
*   **Patient Activation Rate:** Percentage of Patients with at least one Report who log in within 7 days of the first Report's creation. (Target: 60%). This validates the core value proposition for Patients (FR-1, FR-3, FR-4, FR-5).
*   **Admin Task Completion Rate:** Percentage of Admins who successfully create a new Report in under 90 seconds from login. (Target: 95%). This validates the efficiency of the Admin workflow (FR-6, FR-9, FR-10).

### Secondary
*   **Patient Engagement:** Average number of Patient sessions per month.

### Counter-metrics (Do Not Optimize)
*   **Admin Data Entry Error Rate:** Number of Reports edited within 24 hours of creation. An increase could mean the UI is confusing or rushed, even if task completion time is low.
*   **Support Ticket Volume:** Number of support requests related to login issues or inability to find a report.

## 8. Assumptions Index
1.  `[ASSUMPTION: The initial admin user credentials are for bootstrapping and will be changed immediately upon first use in a production environment.]`
2.  `[ASSUMPTION: Admins are trusted personnel and the initial scope does not require complex permission levels beyond the single 'Admin' role.]`
3.  `[ASSUMPTION: The primary user, the Patient, is already familiar with using mobile web apps and understands the concept of OTPs for login.]`
