# CZ AI Dashboard — Starter

A new Next.js starter for CZ Group's internal company dashboard. Initial scope: dashboard shell and first database schema for a 10-person team. This is **not production-ready yet**: authentication UI, invitation/onboarding, role administration, audit enforcement, and live CRUD screens still need implementation and testing.

## Requirements
- Node.js 20.9+ (LTS recommended)
- Git
- GitHub account
- Supabase project
- Vercel account

## Run locally (Windows PowerShell)
```powershell
npm install
Copy-Item .env.example .env.local
npm run dev
```
Open http://localhost:3000. The initial dashboard shell can render without Supabase credentials; database features are not wired yet.

## Supabase setup
1. Create a Supabase project in Singapore.
2. Open SQL Editor and run `supabase/migrations/0001_initial_schema.sql`.
3. In Project Settings → API, copy Project URL and publishable/anon key into `.env.local` as `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
4. Never put the service-role key in browser code or commit any secrets.
5. Before inviting employees, implement a trusted server-side onboarding path that creates `profiles` rows and assigns roles. Do not let users self-assign privileged roles.

## GitHub
This project is stored in the connected repository. Clone it with:
```powershell
git clone https://github.com/supanneer/ai-db.git
cd ai-db
```

## Vercel
1. Import the private GitHub repository in Vercel.
2. Framework preset: Next.js.
3. Add `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` as environment variables when ready.
4. Deploy. Vercel will provide a temporary `*.vercel.app` URL.

## Before real staff use
- Implement Supabase Auth login, invitation-only onboarding, password reset, and role administration.
- Review and test all RLS policies with separate owner/admin/manager/staff accounts. The initial policies are a starting point, not a complete authorization design.
- Add server-side validation, rate limiting, CSRF-safe patterns where applicable, audit events for sensitive actions, backups, error monitoring, and automated tests.
- Add AI features only through server-side routes with secrets stored in Vercel environment variables. Require approval for destructive/high-impact actions.
