# Deployment Documentation

This document provides guidance for building, deploying, and configuring the Lab Report Management System.

## Prerequisites
-   Node.js 22.x LTS
-   npm (version bundled with Node.js)
-   Access to a MongoDB database instance.

## Scaffolders

Before the development stage runs, the wrapper will execute these commands in order to produce the base project structure. The development agent will then add feature code on top of this known-good foundation.

```json
{
  "scaffolders": [
    {
      "name": "NestJS backend",
      "command": [
        "npx", "-y", "@nestjs/cli@latest", "new", "backend",
        "--skip-git",
        "--skip-install",
        "--package-manager", "npm"
      ],
      "cwd": ".",
      "expected_files": [
        "backend/package.json",
        "backend/tsconfig.json",
        "backend/src/main.ts",
        "backend/src/app.module.ts"
      ],
      "timeoutSeconds": 180
    },
    {
      "name": "Next.js frontend",
      "command": [
        "npx", "-y", "create-next-app@latest", "frontend",
        "--typescript",
        "--eslint",
        "--tailwind",
        "--src-dir",
        "--app",
        "--no-import-alias",
        "--use-npm",
        "--skip-install"
      ],
      "cwd": ".",
      "expected_files": [
        "frontend/package.json",
        "frontend/tsconfig.json",
        "frontend/src/app/page.tsx"
      ],
      "timeoutSeconds": 180
    }
  ]
}
```

## Build & Package Step

The project is a monorepo. The development agent is expected to create a root `package.json` that defines npm workspaces and scripts to manage the sub-projects.

1.  **Install dependencies:** From the repository root, run:
    ```bash
    npm install
    ```
2.  **Build applications:** From the repository root, run:
    ```bash
    npm run build --workspace=backend
    npm run build --workspace=frontend
    ```
This will create production-ready builds in `backend/dist/` and `frontend/.next/`.

## Deploy Mechanisms

The recommended deployment strategy is to containerize the applications.

-   **Backend:** The `backend/` directory can be containerized using a Dockerfile. The container will run the Node.js server via `node dist/main`. It is a stateless application that can be scaled horizontally.
-   **Frontend:** The `frontend/` directory is a Next.js application. It can be deployed to a platform like Vercel or containerized. The container will run the application via `npm run start`.

## Environment variables

The system requires two separate sets of environment variables, one for the backend server and one for the frontend browser bundle. The development agent will create `.env.example` files at the specified paths.

| Variable | File path | Scope | Secret? | Purpose |
|---|---|---|---|---|
| `MONGODB_URI` | `backend/.env.example` | server | YES | MongoDB connection string (e.g., `mongodb://user:pass@host:port/db`) |
| `JWT_SECRET` | `backend/.env.example` | server | YES | A long, random string for signing JWTs. |
| `PORT` | `backend/.env.example` | server | no | The port for the backend server to listen on (e.g., `3001`). |
| `STATIC_OTP` | `backend/.env.example` | server | no | The static OTP for patient login (FR-2). Set to `123456`. |
| `DEFAULT_ADMIN_PHONE` | `backend/.env.example` | server | no | Phone number for the initial admin user (FR-7). Set to `9999942496`. |
| `DEFAULT_ADMIN_PASSWORD`| `backend/.env.example` | server | YES | Password for the initial admin user (FR-7). Set to `Hello@123!`. |
| `NEXT_PUBLIC_API_BASE_URL`| `frontend/.env.example`| browser | no | The public URL of the backend API for the frontend to call (e.g., `http://localhost:3001/api`). |

**WARNING:** Any variable prefixed with `NEXT_PUBLIC_` will be embedded in the publicly accessible JavaScript bundle. **NEVER** place secrets in the `frontend/.env.example` file.

## Dependencies

### Backend (Node 22 LTS, NestJS 11)
| Package | Version | Why |
|---|---|---|
| `@nestjs/common` | `^10.0.0` | NestJS core |
| `@nestjs/core` | `^10.0.0` | NestJS core |
| `@nestjs/config` | `^3.0.0` | Environment variable management |
| `@nestjs/mongoose` | `^10.0.0` | Mongoose integration for MongoDB |
| `mongoose` | `^8.0.0` | MongoDB ODM |
| `@nestjs/jwt` | `^10.0.0` | JWT authentication |
| `@nestjs/passport` | `^10.0.0` | Authentication module |
| `passport` | `^0.7.0` | Authentication middleware |
| `passport-jwt` | `^4.0.1` | JWT strategy for Passport |
| `bcryptjs` | `^2.4.3` | Password hashing |
| `class-validator` | `^0.14.0` | DTO validation |
| `class-transformer` | `^0.5.1` | DTO transformation |
| `@nestjs/throttler` | `^5.1.0` | Rate limiting (FR-14) |
| `reflect-metadata` | `^0.2.0` | NestJS dependency |
| `rxjs` | `^7.8.0` | NestJS dependency |

### Backend devDependencies
| Package | Version | Why |
|---|---|---|
| `@nestjs/cli` | `^10.0.0` | NestJS CLI tools |
| `@nestjs/schematics` | `^10.0.0` | NestJS code generation |
| `@nestjs/testing` | `^10.0.0` | Testing utilities |
| `jest` | `^29.5.0` | Test runner |
| `ts-jest` | `^29.1.0` | TypeScript transformer for Jest |
| `ts-loader` | `^9.4.3` | TypeScript loader |
| `ts-node` | `^10.9.1` | TypeScript execution environment |
| `tsconfig-paths` | `^4.2.0` | Module path mapping |
| `typescript` | `^5.1.3` | Compiler |
| `@types/jest` | `^29.5.0` | Jest types |
| `@types/node` | `^20.3.1` | Node.js types |
| `@types/express` | `^4.17.17` | Express types |
| `@types/supertest` | `^6.0.0` | Supertest types for e2e tests |
| `supertest` | `^6.3.3` | HTTP assertion library for e2e tests |

### Frontend (Next.js 14)
| Package | Version | Why |
|---|---|---|
| `next` | `^14.2.0` | Framework |
| `react` | `^18.3.0` | UI runtime |
| `react-dom` | `^18.3.0` | DOM renderer |
| `recharts` | `^2.12.0` | Charting library (FR-5) |
| `tailwindcss` | `^3.4.0` | Styling system |
| `autoprefixer` | `^10.4.0` | Tailwind dependency |
| `postcss` | `^8.4.0` | Tailwind dependency |
| `clsx` | `^2.1.0` | Conditional class composition |
| `lucide-react` | `^0.400.0` | Icon library |

### Frontend devDependencies
| Package | Version | Why |
|---|---|---|
| `typescript` | `^5.0.0` | Compiler |
| `@types/node` | `^20.0.0` | Node types |
| `@types/react` | `^18.0.0` | React types |
| `@types/react-dom` | `^18.0.0` | React DOM types |
| `eslint` | `^8.0.0` | Linter |
| `eslint-config-next` | `14.2.3` | Next.js ESLint config |
| `jest` | `^29.7.0` | Test runner |
| `@testing-library/react` | `^16.0.0` | Component-rendering for tests |
| `@testing-library/jest-dom` | `^6.4.0` | DOM-aware assertions |
| `@testing-library/user-event`| `^14.5.0` | Simulate user interactions |
| `@types/jest` | `^29.5.0` | Jest types |
| `jest-environment-jsdom` | `^29.7.0` | DOM environment for component tests |

## Styling system
-   **Tailwind CSS** (configured by `create-next-app` via the `--tailwind` flag).
-   All components must use utility classes for styling. Inline `style={{...}}` props are forbidden for static values.
-   The `clsx` library is recommended for composing class names conditionally.
-   The `lucide-react` library is recommended for icons.

## Health Checks / Smoke Tests
The backend application should expose a health check endpoint at `/health`. A successful `GET` request should return an HTTP 200 OK status if the application is running and can connect to the database.

## Rollback Procedure
Deployment is based on immutable artifacts (container images). To roll back, re-deploy the previously known-good container image tag for the affected service(s).
