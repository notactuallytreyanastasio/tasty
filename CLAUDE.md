# Tasty - Social Bookmarking Service Specification

## Project Overview

Tasty is a social bookmarking service built with Elixir and Phoenix Framework, featuring real-time collaboration capabilities. The system consists of a Chrome extension for bookmark capture and a Phoenix web application for bookmark management, sharing, and social interaction.

## Architecture Overview

### Components
1. **Chrome Extension**: Captures bookmarks from browser
2. **Phoenix Web Application**: Backend API and web interface
3. **PostgreSQL Database**: Data persistence
4. **Phoenix Channels**: Real-time features (live updates, notifications)
5. **Phoenix LiveView**: Interactive UI without JavaScript

## Database Schema

### Core Tables

```sql
-- Users table
users
- id: uuid primary key
- email: string unique not null
- username: string unique not null
- password_hash: string not null
- avatar_url: string
- bio: text
- inserted_at: timestamp
- updated_at: timestamp

-- Bookmarks table
bookmarks
- id: uuid primary key
- user_id: uuid foreign key -> users.id
- url: string not null
- title: string not null
- description: text
- favicon_url: string
- screenshot_url: string
- is_public: boolean default true
- view_count: integer default 0
- inserted_at: timestamp
- updated_at: timestamp

-- Tags table
tags
- id: uuid primary key
- name: string unique not null
- slug: string unique not null
- color: string
- inserted_at: timestamp
- updated_at: timestamp

-- Bookmark tags junction table
bookmark_tags
- bookmark_id: uuid foreign key -> bookmarks.id
- tag_id: uuid foreign key -> tags.id
- primary key (bookmark_id, tag_id)

-- Votes table
votes
- id: uuid primary key
- user_id: uuid foreign key -> users.id
- bookmark_id: uuid foreign key -> bookmarks.id
- vote_type: integer (1 for upvote, -1 for downvote)
- inserted_at: timestamp
- unique constraint (user_id, bookmark_id)

-- Comments table
comments
- id: uuid primary key
- user_id: uuid foreign key -> users.id
- bookmark_id: uuid foreign key -> bookmarks.id
- parent_id: uuid foreign key -> comments.id (nullable, for nested comments)
- content: text not null
- edited_at: timestamp
- inserted_at: timestamp
- updated_at: timestamp

-- Collections table (for organizing bookmarks)
collections
- id: uuid primary key
- user_id: uuid foreign key -> users.id
- name: string not null
- description: text
- is_public: boolean default false
- inserted_at: timestamp
- updated_at: timestamp

-- Collection bookmarks junction table
collection_bookmarks
- collection_id: uuid foreign key -> collections.id
- bookmark_id: uuid foreign key -> bookmarks.id
- position: integer
- primary key (collection_id, bookmark_id)

-- Follows table (user following)
follows
- follower_id: uuid foreign key -> users.id
- followed_id: uuid foreign key -> users.id
- inserted_at: timestamp
- primary key (follower_id, followed_id)
```

## API Endpoints

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user

### Bookmark Endpoints
- `GET /api/bookmarks` - List bookmarks (with pagination, filtering)
- `POST /api/bookmarks` - Create bookmark
- `GET /api/bookmarks/:id` - Get bookmark details
- `PUT /api/bookmarks/:id` - Update bookmark
- `DELETE /api/bookmarks/:id` - Delete bookmark
- `POST /api/bookmarks/:id/vote` - Vote on bookmark
- `DELETE /api/bookmarks/:id/vote` - Remove vote

### Comment Endpoints
- `GET /api/bookmarks/:id/comments` - Get bookmark comments
- `POST /api/bookmarks/:id/comments` - Create comment
- `PUT /api/comments/:id` - Update comment
- `DELETE /api/comments/:id` - Delete comment

### Tag Endpoints
- `GET /api/tags` - List all tags
- `GET /api/tags/:slug/bookmarks` - Get bookmarks by tag

### User Endpoints
- `GET /api/users/:username` - Get user profile
- `GET /api/users/:username/bookmarks` - Get user's bookmarks
- `POST /api/users/:username/follow` - Follow user
- `DELETE /api/users/:username/follow` - Unfollow user

### Collection Endpoints
- `GET /api/collections` - List user's collections
- `POST /api/collections` - Create collection
- `PUT /api/collections/:id` - Update collection
- `DELETE /api/collections/:id` - Delete collection
- `POST /api/collections/:id/bookmarks` - Add bookmark to collection
- `DELETE /api/collections/:id/bookmarks/:bookmark_id` - Remove from collection

## Chrome Extension Specification

### Manifest (manifest.json)
```json
{
  "manifest_version": 3,
  "name": "Tasty Bookmarks",
  "version": "1.0.0",
  "description": "Save and share bookmarks with Tasty",
  "permissions": ["activeTab", "storage"],
  "host_permissions": ["http://localhost:4000/*"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  },
  "icons": {
    "16": "icon-16.png",
    "48": "icon-48.png",
    "128": "icon-128.png"
  }
}
```

### Extension Features
1. **Quick Save**: One-click bookmark current page
2. **Add Tags**: Tag input with autocomplete
3. **Add Description**: Optional description field
4. **Collection Selection**: Choose collection to save to
4. **Authentication**: Login/logout from extension

## Phoenix Implementation Details

### Contexts to Create

1. **Accounts Context** (`lib/tasty/accounts/`)
   - User management
   - Authentication
   - Following relationships

2. **Bookmarks Context** (`lib/tasty/bookmarks/`)
   - Bookmark CRUD
   - Voting logic
   - View counting

3. **Social Context** (`lib/tasty/social/`)
   - Comments
   - Activity feed
   - Notifications

4. **Collections Context** (`lib/tasty/collections/`)
   - Collection management
   - Bookmark organization

### LiveView Components

1. **BookmarkLive.Index** - Browse bookmarks with real-time updates
2. **BookmarkLive.Show** - Single bookmark with comments
3. **ProfileLive.Show** - User profile page
4. **CollectionLive.Index** - User's collections
5. **TagLive.Show** - Bookmarks by tag

### Phoenix Channels

1. **BookmarkChannel** - Real-time bookmark updates
   - Events: new_bookmark, bookmark_voted, bookmark_deleted
2. **CommentChannel** - Real-time comments
   - Events: new_comment, comment_edited, comment_deleted
3. **UserChannel** - User notifications
   - Events: new_follower, bookmark_commented, bookmark_voted

## Implementation Steps

### Phase 1: Foundation
1. Set up authentication with `mix phx.gen.auth`
2. Create Accounts context with User schema
3. Implement user registration/login
4. Set up API authentication with tokens

### Phase 2: Core Bookmarking
1. Create Bookmarks context and schema
2. Implement bookmark CRUD operations
3. Add tag functionality
4. Create bookmark listing with pagination

### Phase 3: Social Features
1. Implement voting system
2. Add commenting functionality
3. Create following system
4. Build activity feeds

### Phase 4: Chrome Extension
1. Create extension structure
2. Implement API client
3. Build popup UI
4. Add authentication flow

### Phase 5: Real-time Features
1. Set up Phoenix Channels
2. Implement live bookmark updates
3. Add real-time notifications
4. Create live activity feed

### Phase 6: Advanced Features
1. Implement collections
2. Add search functionality
3. Create recommendation system
4. Build import/export features

## Testing Strategy

### Unit Tests
- Context functions
- Schema validations
- Business logic

### Integration Tests
- API endpoint tests
- Channel tests
- LiveView tests

### E2E Tests
- User flows
- Chrome extension integration

## Development Commands

```bash
# Run server
mix phx.server

# Run tests
mix test

# Run migrations
mix ecto.migrate

# Generate migration
mix ecto.gen.migration [name]

# Run seeds
mix run priv/repo/seeds.exs

# Format code
mix format

# Run linter
mix credo

# Type checking
mix dialyzer
```

## Environment Variables

```bash
# .env file
DATABASE_URL=postgresql://postgres:postgres@localhost/tasty_dev
SECRET_KEY_BASE=<generate with mix phx.gen.secret>
PHX_HOST=localhost
PHX_PORT=4000
POOL_SIZE=10

# For production
CHROME_EXTENSION_ID=<extension-id>
AWS_ACCESS_KEY_ID=<for-screenshot-storage>
AWS_SECRET_ACCESS_KEY=<for-screenshot-storage>
AWS_S3_BUCKET=tasty-screenshots
```

## Security Considerations

1. **API Authentication**: Use Guardian for JWT tokens
2. **Rate Limiting**: Implement with ExRated
3. **CORS**: Configure for Chrome extension
4. **Input Validation**: Sanitize all user inputs
5. **SQL Injection**: Use Ecto parameterized queries
6. **XSS Prevention**: Use Phoenix HTML safe functions

## Performance Optimizations

1. **Database Indexes**
   - bookmarks.user_id
   - bookmarks.url
   - tags.slug
   - bookmark_tags compound index

2. **Caching**
   - Popular bookmarks
   - User profiles
   - Tag clouds

3. **Background Jobs** (using Oban)
   - Screenshot generation
   - Email notifications
   - Data cleanup

## Deployment Considerations

1. **Infrastructure**
   - Elixir/OTP release with Distillery
   - PostgreSQL database
   - Redis for caching/sessions
   - CDN for static assets

2. **Monitoring**
   - AppSignal or New Relic
   - Error tracking with Sentry
   - Logging with LoggerJSON

3. **CI/CD**
   - GitHub Actions for tests
   - Automated deployments
   - Database migration strategy