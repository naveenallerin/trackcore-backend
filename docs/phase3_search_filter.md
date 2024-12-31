# Phase 3 - Search and Filter Implementation

## Overview
The search and filter functionality has been implemented for the Candidates API, allowing filtering by various attributes.

## Available Filters

- `status`: Filter by candidate status
- `location`: Filter by candidate location
- `min_experience`: Filter by minimum years of experience
- `name`: Search by candidate first or last name
- `start_date`: Filter by creation date range start
- `end_date`: Filter by creation date range end

## Usage Examples

### Basic Filtering
```http
GET /api/v1/candidates?status=interviewed
GET /api/v1/candidates?location=New York
```

### Combined Filters
```http
GET /api/v1/candidates?status=interviewed&location=New York
```

### Date Range Filtering
```http
GET /api/v1/candidates?start_date=2023-01-01&end_date=2023-12-31
```

## Response Format
```json
[
  {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "status": "interviewed",
    "location": "New York",
    // ... other attributes
  }
]
```

## Testing
Run the request specs to verify filter functionality:
```bash
rspec spec/requests/api/v1/candidates_spec.rb
```
