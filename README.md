# TrackCore Backend

## Setup & Installation

### Using Docker (Recommended)
```bash
# Build the containers
docker-compose build

# Install dependencies
docker-compose run app bundle install

# Setup database
docker-compose run app rails db:create
docker-compose run app rails db:migrate

# Run tests
docker-compose run app bundle exec rspec

# Start the application
docker-compose up
```

## API Endpoints

### Requisitions
- `POST /requisitions` - Create a new requisition
- `GET /requisitions` - List all requisitions

### Applications
- `POST /requisitions/:requisition_id/applications` - Create an application for a requisition
- `GET /requisitions/:requisition_id/applications` - List all applications for a requisition

## Authentication

The API uses JWT tokens for authentication. Include the JWT token in your requests:

```bash
# Login to get token
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"user": {"email": "user@example.com", "password": "password123"}}'

# Use token in subsequent requests
curl -X GET http://localhost:3000/requisitions \
  -H "Authorization: Bearer your-token-here"
```

### Authentication Endpoints
- `POST /login` - Login and receive JWT token
- `POST /signup` - Create a new user account
- `DELETE /logout` - Invalidate current token

## Project Structure

### Models
1. **Requisition**
   - `title`
   - `description`
   - `status`
   - Has many applications

2. **Application**
   - `candidate_id`
   - `requisition_id`
   - `notes`
   - `application_status`
   - Belongs to requisition

## Testing

Run the test suite:
```bash
docker-compose run app bundle exec rspec
```

## Current Achievements
- ✓ Implemented Requisition model with validations
- ✓ Implemented Application model with associations
- ✓ Basic CRUD operations via API endpoints
- ✓ Request specs for all endpoints
- ✓ Foundation for ATS Phase 1 complete

## Next Steps
1. Run migrations:
   ```bash
   docker-compose run app rails db:migrate
   ```
2. Verify test coverage:
   ```bash
   docker-compose run app bundle exec rspec
   ```
3. Start the application:
   ```bash
   docker-compose up
   ```
