
# Hotel Management System (Rails)

This is a Ruby on Rails application for managing hotel operations.

## Features
- Menu Management
- Order Processing
- Inventory Management
- Employee Work Hours Tracking
- Managerial Dashboard
- Accountant/Financial Reports

## Getting Started

### Prerequisites
- Ruby (see `.ruby-version`)
- Bundler (`gem install bundler`)

### Setup
```bash
bundle install
bin/rails db:setup
bin/rails server
```

- Access the app at http://localhost:3000

## Notes
- Uses SQLite for development and test by default.
- For production, update `config/database.yml` as needed.
