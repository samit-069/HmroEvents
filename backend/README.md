# HamroEvents Backend API

Express + MongoDB backend for HamroEvents.

## Setup
1. Create `.env` in backend directory:
```
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/hmroevents
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d
ADMIN_EMAIL=admin@admin.com
ADMIN_PASSWORD=Admin@123
```
2. Install & run:
```
npm install
npm run dev
```
3. Seed data (admin/user/events):
```
npm run seed
```

## Endpoints
- Auth: POST /api/auth/register, POST /api/auth/login, GET /api/auth/me
- Users: GET /api/users (admin), GET /api/users/:id, PUT /api/users/:id, PUT /api/users/:id/block (admin)
- Events: GET /api/events, GET /api/events/:id, POST /api/events (organizer/admin), PUT /api/events/:id, DELETE /api/events/:id, POST /api/events/:id/bookmark, GET /api/events/user/:userId
