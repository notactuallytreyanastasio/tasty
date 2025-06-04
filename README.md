# Tasty - Social Bookmarking Service

A modern social bookmarking platform built with Elixir and Phoenix Framework, featuring real-time collaboration and a Chrome extension for seamless bookmark collection.

## Overview

Tasty allows users to:
- Save and organize bookmarks with tags
- Browse public bookmarks from the community
- Share and discover interesting content
- Use the Chrome extension for quick bookmark capture
- Filter content by tags and categories
- Follow other users and see their bookmarks

## Technology Stack

- **Backend**: Elixir 1.17.3 + Phoenix Framework 1.7.21
- **Database**: PostgreSQL with Ecto
- **Frontend**: Phoenix LiveView + Tailwind CSS
- **Real-time**: Phoenix Channels + PubSub
- **Authentication**: Built-in Phoenix authentication
- **Deployment**: Gigalixir (Heroku-compatible)

## Quick Start

### Prerequisites

- Elixir 1.14+ and Erlang/OTP 25+
- PostgreSQL 13+
- Node.js 18+ (for asset compilation)

### Local Development

1. **Clone and setup:**
   ```bash
   git clone <repository-url>
   cd tasty
   mix setup
   ```

2. **Configure database:**
   ```bash
   # Update config/dev.exs with your PostgreSQL settings
   # Default: postgresql://postgres:postgres@localhost/tasty_dev
   ```

3. **Start the server:**
   ```bash
   mix phx.server
   ```

4. **Visit the application:**
   - Main app: http://localhost:4000
   - LiveDashboard: http://localhost:4000/dev/dashboard
   - Discover page: http://localhost:4000/discover

### Initial Data

The application includes a comprehensive seed script with 100+ realistic bookmarks:

```bash
mix run priv/repo/seeds.exs
```

This creates:
- Test user: `redditcurator` (password: `testpassword123`)
- 12 popular tags (Programming, Technology, Science, etc.)
- 100 diverse bookmarks with realistic titles and descriptions
- Tag associations for filtering

## Architecture

### Database Schema

Key entities:
- **Users**: Authentication and profiles
- **Bookmarks**: URLs with metadata (title, description, tags)
- **Tags**: Categorization system
- **Collections**: Bookmark organization (future feature)
- **Votes/Comments**: Social features (future)

### Context Modules

- `Tasty.Accounts` - User management and authentication
- `Tasty.Bookmarks` - Core bookmarking functionality

### LiveView Components

- `BookmarkLive.Index` - Main discovery interface with real-time updates
- Tag filtering and search functionality
- Responsive, condensed UI design

## API Endpoints

### Public Endpoints
- `GET /api/bookmarks` - List public bookmarks
- `GET /api/tags` - List all tags

### Authenticated Endpoints (Future)
- `POST /api/bookmarks` - Create bookmark
- `PUT /api/bookmarks/:id` - Update bookmark
- `DELETE /api/bookmarks/:id` - Delete bookmark

## Chrome Extension

Located in `/chrome-extension/`:

### Installation
1. Open Chrome Extensions (chrome://extensions/)
2. Enable "Developer mode"
3. Click "Load unpacked" and select the `chrome-extension` folder

### Features
- One-click bookmark saving
- Tag input with autocomplete
- Authentication with main app
- Quick access popup interface

## Deployment

### Gigalixir Deployment

1. **Install Gigalixir CLI:**
   ```bash
   pip install gigalixir
   ```

2. **Login and create app:**
   ```bash
   gigalixir login
   gigalixir create tasty-app
   ```

3. **Configure environment:**
   ```bash
   gigalixir config:set SECRET_KEY_BASE=$(mix phx.gen.secret)
   gigalixir config:set DATABASE_URL=postgresql://...
   ```

4. **Deploy:**
   ```bash
   git push gigalixir main
   ```

5. **Run migrations:**
   ```bash
   # Option 1: Use dedicated migrate command (recommended)
   gigalixir ps:migrate
   
   # Option 2: Use run command with POOL_SIZE
   POOL_SIZE=2 gigalixir run mix ecto.migrate
   POOL_SIZE=2 gigalixir run mix run priv/repo/seeds.exs
   
   # Option 3: Use release module directly
   POOL_SIZE=2 gigalixir run "/app/bin/tasty eval \"Tasty.Release.migrate\""
   ```

   **Note:** The `POOL_SIZE=2` prefix is required for Gigalixir database operations to prevent connection timeouts.

### Environment Variables

Required for production:

```bash
# Generate with: mix phx.gen.secret
SECRET_KEY_BASE=<64-char-secret>

# Database connection
DATABASE_URL=postgresql://user:pass@host:port/database

# App configuration
PHX_HOST=your-app.gigalixir.com
PHX_PORT=4000
POOL_SIZE=10

# Optional: Chrome Extension
CHROME_EXTENSION_ID=<extension-id>

# Optional: File uploads
AWS_ACCESS_KEY_ID=<key>
AWS_SECRET_ACCESS_KEY=<secret>
AWS_S3_BUCKET=tasty-screenshots
```

## Operations

### Common Tasks

**Database operations:**
```bash
# Local development
mix ecto.create          # Create database
mix ecto.migrate         # Run migrations
mix ecto.rollback        # Rollback last migration
mix ecto.reset           # Drop, create, migrate, seed

# Production
gigalixir ps:migrate                              # Recommended method
POOL_SIZE=2 gigalixir run mix ecto.migrate        # Alternative method
POOL_SIZE=2 gigalixir run mix ecto.rollback
```

**Application management:**
```bash
# Local
mix phx.server           # Start development server
mix test                 # Run test suite
mix format               # Format code
mix deps.get             # Install dependencies

# Production
gigalixir logs           # View application logs
gigalixir logs --tail    # Follow logs in real-time
gigalixir restart        # Restart application
gigalixir scale TIER     # Scale up/down
```

**Asset compilation:**
```bash
mix assets.build         # Compile assets (dev)
mix assets.deploy        # Compile and minify (prod)
```

### Monitoring and Debugging

**LiveDashboard** (production):
- Add basic auth protection
- Monitor performance metrics
- View live processes and memory usage

**Logging:**
```bash
# Local logs
tail -f _build/dev/logs/dev.log

# Production logs
gigalixir logs --tail
gigalixir logs --num 100
```

**Database access:**
```bash
# Local
psql -d tasty_dev

# Production
gigalixir pg:psql
```

### Maintenance

**Regular tasks:**
- Monitor database size and performance
- Review and cleanup old logs
- Update dependencies monthly
- Check security updates

**Backup strategy:**
```bash
# Database backup
gigalixir pg:backups:capture
gigalixir pg:backups:download <backup-id>

# Application backup
git tag v1.0.0
git push origin --tags
```

## Development

### Code Quality

**Formatting:**
```bash
mix format
```

**Testing:**
```bash
mix test                 # Run all tests
mix test test/tasty_web/live/bookmark_live_test.exs  # Specific test
```

**Dependencies:**
```bash
mix deps.get             # Install dependencies
mix deps.update --all    # Update all dependencies
mix deps.audit           # Security audit
```

### Adding Features

1. **Database changes:**
   ```bash
   mix ecto.gen.migration add_feature_table
   ```

2. **Context functions:**
   - Add to appropriate context module
   - Write comprehensive tests

3. **LiveView components:**
   - Create in `lib/tasty_web/live/`
   - Add routes in `router.ex`

4. **API endpoints:**
   - Add controllers in `lib/tasty_web/controllers/`
   - Define JSON views
   - Update router

## Troubleshooting

### Common Issues

**Database connection errors:**
```bash
# Check PostgreSQL is running
brew services start postgresql

# Verify credentials in config/dev.exs
```

**Gigalixir migration failures:**
```bash
# Try these methods in order:

# 1. Use dedicated migrate command
gigalixir ps:migrate

# 2. Restart app and try again
gigalixir restart
gigalixir ps:migrate

# 3. Use run command with POOL_SIZE
POOL_SIZE=2 gigalixir run mix ecto.migrate

# 4. Use release module directly
POOL_SIZE=2 gigalixir run "/app/bin/tasty eval \"Tasty.Release.migrate\""

# 5. Check app status
gigalixir ps
```

**Asset compilation errors:**
```bash
# Reinstall Node.js dependencies
mix assets.setup
```

**LiveView not updating:**
```bash
# Check PubSub configuration
# Verify Channel subscriptions
```

**Chrome extension not connecting:**
```bash
# Check CORS configuration in config/
# Verify API endpoints are accessible
```

### Getting Help

- Check logs first: `gigalixir logs` or local console
- Review Phoenix documentation
- Check Elixir Forum for community support
- Verify environment variables are set correctly

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Run the test suite: `mix test`
5. Format code: `mix format`
6. Submit a pull request

## License

[Add your license information here]