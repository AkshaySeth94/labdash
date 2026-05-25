# Architecture Decision Document

## 1. Project Context Analysis
**Requirements overview**
The system is a mobile-first lab report management web application with two distinct user roles, Patients and Admins. The functional requirements can be clustered into three main subsystems:
-   **Patient Application (FR-1 to FR-5):** A mobile-first web interface for patients to log in via phone and a static OTP, view their list of lab reports, see report details, and visualize their glucose trends on a chart.
-   **Admin Panel (FR-6 to FR-11):** A secure web interface for administrators to log in with a password, manage patient records (create, view), and manage reports for patients (create, edit).
-   **Backend API & Core Logic:** A central API to serve both applications, handling authentication, authorization, data persistence, and business logic. It also includes cross-cutting concerns like seeding the initial admin user (FR-7).
-   **Cross-Cutting Concerns (FR-12 to FR-15):** System-wide non-functional requirements including secure HTTPS communication, strict Role-Based Access Control (RBAC), rate limiting on login endpoints, and audit logging for all admin actions.

**NFRs that drive architecture**
The dominant constraint is **Security and Data Privacy**. The system handles sensitive patient health information, making security paramount. This is explicitly required by FR-12 (HTTPS), FR-13 (RBAC), and FR-14 (Rate Limiting). All architectural decisions, from authentication mechanisms to data handling and deployment, must prioritize the confidentiality, integrity, and availability of patient data. Simplicity and developer velocity are traded against robust security measures.

**Scale & complexity**
-   **Domain:** Healthcare IT (Lab Report Management).
-   **Complexity Level:** Low-to-Medium. The system has two roles, three core data entities (Patient, Admin, Report), and straightforward CRUD operations. The complexity lies in ensuring the security and privacy requirements are met rigorously.
-   **~N components:** The architecture consists of three primary components: a frontend single-page application, a backend API server, and a database.

**Technical constraints & dependencies**
The `spec.md` mandates the following technology stack:
-   **Database:** MongoDB
-   **Backend:** Node.js, Express
-   **Frontend:** React
-   **Charting Library:** Chart.js or Recharts
-   **Authentication:** JWT or secure session auth

**Cross-cutting concerns**
-   **Auditability:** Required by FR-15. All state-changing actions by Admins must be logged.
-   **Security:** Required by FR-12, FR-13, FR-14. Includes encrypted communication, RBAC, and brute-force protection.
-   **Observability:** While not explicitly specified, standard logging for errors and application lifecycle events is essential for a production-ready system.
-   **Cost:** Not a primary driver, but the choice of an open-source MERN stack is inherently cost-effective.

## 2. Starter / Foundation
To ensure developer productivity and a robust starting point, we will use established, scaffolder-backed frameworks.

-   **Backend API / server:** **NestJS 11.0**. NestJS is a progressive Node.js framework built on Express that provides a modular, scalable architecture out of the box. This directly supports the requirement for a "scalable architecture for adding more report types later."
-   **Web frontend:** **Next.js 14.2**. Next.js is a production-grade React framework that provides a solid foundation for building a "mobile-first responsive UI" with features like file-based routing, server components, and optimized performance.
-   **Database access:** **Mongoose**. As the standard Object Data Modeling (ODM) library for MongoDB in the Node.js ecosystem, it will be used via the `@nestjs/mongoose` package to provide schema definition, validation, and business logic hooks.

These foundational choices make the following decisions for us ("inherited from foundation"):
-   **Language:** TypeScript for both frontend and backend.
-   **Build Tooling:** `nest build` (which uses `tsc`) for the backend, `next build` for the frontend.
-   **Project Structure:** Standard NestJS module structure (`src/app.module.ts`, etc.) and Next.js app router structure (`src/app/page.tsx`, etc.).
-   **Testing Framework:** Jest is the default for both NestJS and Next.js.
-   **Linting:** ESLint, configured by both frameworks.

## 3. Core Architectural Decisions

### ADR-runtime: Monorepo with Two Applications
**Decision:** The project will be structured as a monorepo containing two distinct applications: `backend` (NestJS) and `frontend` (Next.js).
**Rationale:** This approach simplifies the development workflow, allowing for shared TypeScript types and utilities between the frontend and backend. It streamlines dependency management and makes local end-to-end testing easier. We trade away fully independent deployment pipelines, which is an acceptable trade-off for a small team on a v1 product.
**Affects:** Overall project structure, build process, and local development setup.

### ADR-state: MongoDB for Durable State
**Decision:** MongoDB will be the primary data store for all application state, including users, reports, and audit logs.
**Rationale:** This is mandated by the `spec.md`. MongoDB's document-based model is well-suited for the defined entities and provides the flexibility to easily add new report types in the future without complex schema migrations.
**Affects:** FR-3, FR-4, FR-8, FR-9, FR-10, FR-11, FR-15.

### ADR-auth: JWT-based Authentication
**Decision:** We will use JSON Web Tokens (JWTs) for stateless authentication of both Patients and Admins.
**Rationale:** JWT is a secure, standard choice for authenticating APIs, as suggested in the `spec.md`. A JWT containing the user's ID and role (`Patient` or `Admin`) will be issued upon successful login. This token must be included in the `Authorization` header for all subsequent requests to protected endpoints. This stateless approach simplifies the backend architecture.
**Affects:** FR-1, FR-2, FR-6, FR-13.

### ADR-contracts: REST API with DTOs
**Decision:** The backend will expose a RESTful API. All request and response payloads will be strictly defined and validated using Data Transfer Objects (DTOs) powered by `class-validator` and `class-transformer` within NestJS.
**Rationale:** A REST API is the industry standard for frontend-backend communication. Enforcing strict data contracts with DTOs fulfills the "input validation" requirement, enhances security by preventing malformed data, and provides clear API documentation.
**Affects:** All functional requirements involving client-server interaction.

### ADR-creds: Environment Variables for Secrets
**Decision:** All secrets, including the MongoDB connection string, JWT signing secret, and initial admin credentials, will be managed exclusively through environment variables.
**Rationale:** This follows the twelve-factor app methodology, strictly separating configuration from code. It prevents secrets from being committed to version control and allows for different configurations across environments (development, staging, production).
**Affects:** FR-7, FR-12, and the overall security posture of the application.

### ADR-seeding: Application Startup Seeding
**Decision:** The NestJS backend will include a startup routine (e.g., using `OnModuleInit`) to check for the existence of any Admin user and create the default admin if none are found.
**Rationale:** This directly and reliably implements FR-7. It ensures the system is always accessible for administration immediately after a fresh deployment. The credentials will be sourced from environment variables.
**Affects:** FR-7.

## 4. Implementation Patterns & Consistency Rules
**Naming conventions:**
-   **Files/Directories:** `kebab-case` (e.g., `report-management.service.ts`).
-   **Variables/Functions:** `camelCase` (e.g., `getPatientReport`).
-   **Classes/Interfaces/Types/Components:** `PascalCase` (e.g., `PatientReportDto`, `ReportChart`).

**File & path conventions:**
-   **Source Code:** `backend/src/` and `frontend/src/`.
-   **Tests:** Located alongside the files they test (e.g., `report.service.spec.ts` next to `report.service.ts`).
-   **Configuration:** NestJS modules for backend structure. Next.js app router for frontend structure.

**Schema contracts:**
Key data structures will be defined as TypeScript interfaces/classes and shared where applicable.
```typescript
// Example Report Schema
interface Report {
  _id: string; // or ObjectId
  patientId: string;
  reportDate: Date;
  type: 'GlucoseMarkerReport';
  glucoseValue: number; // in mg/dL
  status: 'Pending' | 'Final';
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

// Example User Schema
interface User {
  _id: string;
  phone: string; // unique
  password?: string; // for Admins
  role: 'Patient' | 'Admin';
  fullName?: string; // for Patients
}
```

**Process conventions:**
-   **Error Handling:** The NestJS backend will use global exception filters to provide consistent, structured JSON error responses (e.g., `{ "statusCode": 403, "message": "Forbidden" }`).
-   **Logging:** Use the built-in NestJS `Logger`. Logs should be structured as JSON for easier parsing by log aggregation tools.
-   **Commit Messages:** Adhere to the Conventional Commits specification (e.g., `feat(admin): add report creation endpoint`).

## 5. Project Structure
The monorepo will have the following top-level structure:
```
/
├── _artifacts/
│   ├── architecture.md       (THIS FILE, NEW)
│   └── deployment-doc.md     (NEW)
├── _pipeline/
│   └── build.Dockerfile      (NEW)
├── backend/                  (NEW, via scaffolder)
│   ├── src/
│   └── package.json
├── frontend/                 (NEW, via scaffolder)
│   ├── src/
│   └── package.json
├── .gitignore                (NEW)
├── package.json              (NEW, for monorepo workspaces)
└── README.md                 (NEW)
```

## 6. Decision Impact Analysis
**Implementation sequence:**
A vertical slice approach is recommended to deliver value quickly and validate the architecture.
1.  **Foundation:** Set up the monorepo structure and scaffold the NestJS backend and Next.js frontend.
2.  **Backend - Core Models & Auth:** Implement MongoDB connection, User (Admin/Patient) and Report schemas. Implement Admin seeding (FR-7) and authentication (FR-6).
3.  **Backend - Admin APIs:** Build the CRUD APIs for managing patients (FR-8, FR-9) and reports (FR-10, FR-11). Implement audit logging (FR-15).
4.  **Frontend - Admin Panel:** Build the UI for the Admin Panel to consume the new APIs.
5.  **Backend - Patient APIs & Auth:** Implement Patient OTP authentication (FR-1, FR-2) and endpoints to fetch reports (FR-3, FR-4, FR-5).
6.  **Frontend - Patient Dashboard:** Build the UI for the Patient Dashboard, including the report list and glucose chart.
7.  **Cross-Cutting Concerns:** Implement and test RBAC (FR-13) and rate limiting (FR-14) on the backend. Ensure HTTPS is enforced in deployment configuration.

**Cross-component dependencies:**
-   The `frontend` application is highly dependent on the `backend` API for all data and authentication.
-   The `backend` application is dependent on the MongoDB database.
-   There are no circular dependencies.

## 7. Validation
**Coherence check:** The chosen technologies (Next.js, NestJS, MongoDB) form a modern, coherent, and widely-used stack (a variant of MERN) that is well-suited to the project requirements. The architectural patterns (monorepo, JWT, REST) are standard and work well together.
**Requirements coverage:** All functional requirements from FR-1 to FR-15 have been mapped to a component or architectural decision.
**Implementation readiness:** This document provides a clear foundation, technology choices, project structure, and implementation sequence, enabling a downstream development agent to begin work without ambiguity.
**Gap analysis:** The architecture is complete for the v1 scope. Features explicitly listed as non-goals (e.g., real SMS gateway, patient self-registration) are not accounted for but the modular nature of the NestJS backend provides a clear path for future extension.
