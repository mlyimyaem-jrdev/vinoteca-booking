#!/usr/bin/env bash
set -euo pipefail
REPO="mlyimyaem-jrdev/vinoteca-booking"   # <-- edit

lbl() { gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force; }
lbl "type:feature" "1d76db" "New capability"
lbl "type:bug"     "d73a4a" "Defect"
lbl "type:chore"   "cfd3d7" "Maintenance"
lbl "type:docs"    "0075ca" "Documentation"
lbl "type:infra"   "5319e7" "CI/CD, Docker, deploy"
lbl "area:domain"  "fbca04" "Entities and business rules"
lbl "area:db"      "fef2c0" "Schema and migrations"
lbl "area:api"     "c2e0c6" "REST controllers"
lbl "area:auth"    "e99695" "Security"
lbl "area:web"     "bfd4f2" "Thymeleaf UI"
lbl "size:S" "ededed" "< 2h"; lbl "size:M" "ededed" "half day"; lbl "size:L" "ededed" "1-2 days"

ms() { gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null; }
ms "M1 Foundations"        "Repo, build, Docker, first green CI run"
ms "M2 Domain & Data"      "Entities, Flyway schema, repositories, unit tests"
ms "M3 Booking API"        "REST endpoints and business rules"
ms "M4 Auth & Admin UI"    "Spring Security, staff pages, public booking page"
ms "M5 CI/CD & Deploy"     "Image publishing, deployment, monitoring"
ms "M6 Hardening & Docs"   "Coverage, OpenAPI, README, architecture docs"

iss() { gh issue create --repo "$REPO" --title "$1" --body "$2" --milestone "$3" --label "$4"; }

# M1
iss "Scaffold Spring Boot project with Maven" "Spring Initializr: web, data-jpa, validation, postgresql, flyway, actuator. Commit the wrapper." "M1 Foundations" "type:chore,size:S"
iss "Add docker-compose with Postgres 16" "Service db, named volume, .env.example, documented in README." "M1 Foundations" "type:infra,size:S"
iss "Add multi-stage Dockerfile for the app" "Builder stage with Maven, runtime stage on a JRE base image, non-root user." "M1 Foundations" "type:infra,size:M"
iss "Add CI workflow: build and test on PR" "See docs/ci.md. Must run on pull_request and push to main." "M1 Foundations" "type:infra,size:M"
iss "Write README skeleton" "Problem statement, stack, how to run locally, architecture diagram placeholder." "M1 Foundations" "type:docs,size:S"

# M2
iss "Flyway migration V1: core schema" "Tables: wine, tasting_session, customer, booking, staff_user, session_wine join." "M2 Domain & Data" "type:feature,area:db,size:M"
iss "JPA entities and repositories" "Map all six tables. Use UUID primary keys and auditing timestamps." "M2 Domain & Data" "type:feature,area:domain,size:M"
iss "Seed data migration for local dev" "V2 migration with 6 wines and 10 upcoming sessions." "M2 Domain & Data" "type:chore,area:db,size:S"
iss "Repository integration tests with Testcontainers" "Real Postgres container, verify queries for available capacity." "M2 Domain & Data" "type:feature,area:db,size:L"
iss "SessionService: capacity calculation" "remainingCapacity = capacity - sum(confirmed partySize). Unit tested." "M2 Domain & Data" "type:feature,area:domain,size:M"

# M3
iss "GET /api/sessions with date range filter" "Returns upcoming sessions with remaining capacity. Paginated." "M3 Booking API" "type:feature,area:api,size:M"
iss "POST /api/bookings creates a booking" "Validates capacity, duplicate email, and booking cutoff window." "M3 Booking API" "type:feature,area:api,size:L"
iss "Reject overbooking with 409 Conflict" "Business rule 1. Include a concurrency test with two parallel requests." "M3 Booking API" "type:feature,area:domain,size:L"
iss "DELETE /api/bookings/{ref} cancels a booking" "Frees capacity and promotes oldest waitlisted booking." "M3 Booking API" "type:feature,area:api,size:M"
iss "Waitlist support when session is full" "Status WAITLISTED, FIFO promotion on cancellation." "M3 Booking API" "type:feature,area:domain,size:L"
iss "Global exception handler with RFC 7807 problem details" "Consistent error envelope for 400/404/409." "M3 Booking API" "type:feature,area:api,size:M"
iss "Booking reference code generator" "Human-readable 8-char code, collision-safe, unique index." "M3 Booking API" "type:feature,area:domain,size:S"

# M4
iss "Spring Security: form login for staff" "BCrypt hashes, roles ADMIN and STAFF, /admin/** protected." "M4 Auth & Admin UI" "type:feature,area:auth,size:L"
iss "Admin page: list and create tasting sessions" "Thymeleaf, server-side validation, flash messages." "M4 Auth & Admin UI" "type:feature,area:web,size:L"
iss "Admin page: view bookings per session" "Table with customer, party size, status; cancel action." "M4 Auth & Admin UI" "type:feature,area:web,size:M"
iss "Public booking page" "Calendar-ish list of sessions, booking form, confirmation screen with reference code." "M4 Auth & Admin UI" "type:feature,area:web,size:L"
iss "CSRF and security headers audit" "Verify CSRF on forms, add strict headers, document decisions." "M4 Auth & Admin UI" "type:feature,area:auth,size:M"

# M5
iss "CD workflow: build and push image to GHCR" "Tag with git sha and latest. Runs only on main." "M5 CI/CD & Deploy" "type:infra,size:M"
iss "Deploy to Render or Fly.io from Actions" "Use a deploy hook or flyctl. Store token in repo secrets." "M5 CI/CD & Deploy" "type:infra,size:L"
iss "Enable Dependabot for Maven and Actions" ".github/dependabot.yml, weekly schedule." "M5 CI/CD & Deploy" "type:infra,size:S"
iss "Enable CodeQL scanning" "Default setup for Java." "M5 CI/CD & Deploy" "type:infra,size:S"
iss "Actuator health and readiness endpoints" "Expose health and info only; document probe URLs." "M5 CI/CD & Deploy" "type:infra,size:S"

# M6
iss "JaCoCo coverage gate at 70 percent" "Fail the build below the threshold. Publish the report as an artifact." "M6 Hardening & Docs" "type:chore,size:M"
iss "OpenAPI docs with springdoc" "Serve /swagger-ui. Screenshot in README." "M6 Hardening & Docs" "type:docs,size:M"
iss "Architecture decision records" "docs/adr/ with at least 4 ADRs on stack and design choices." "M6 Hardening & Docs" "type:docs,size:M"
iss "Final README with diagrams and demo link" "C4-ish container diagram via Mermaid, screenshots, live URL." "M6 Hardening & Docs" "type:docs,size:M"
