# Hotel Management System - Technical Design

This document outlines the technical design for the hotel management system.

## 1. Architecture

The application will follow a standard Phoenix architecture, with some specific considerations for SurrealDB integration.

- **Frontend:** Phoenix LiveView for dynamic UIs, standard Phoenix templates where appropriate.
- **Backend:** Elixir/Phoenix
- **Databases:**
  - **Primary Data Store:** SurrealDB (Orders, Inventory, Menu, Users, Employee Hours)
  - **Analytics Data Store:** PostgreSQL (Potentially pre-aggregated data from SurrealDB for the AI-powered dashboard)

## 2. Modules & Contexts

We will structure the application using Phoenix Contexts:

- **Menu Context:** Manage daily menus, menu items.
- **Order Context:** Handle customer orders, order status, order transmission.
- **Inventory Context:** Track stock levels, expiration dates, automatic/manual updates, reporting.
- **Employee Context:** Manage employee data, work hour logging, approval.
- **Accounting Context:** Handle billing, payments, cashflow, expense tracking.
- **Manager Context:** Dashboard, analytics integration, high-level views.
- **UserAuth Context:** Handle user authentication and authorization for different roles.

## 3. Key Design Decisions

- **QR Code Ordering:** Will be a public-facing LiveView page, likely under a unique route per table.
- **Real-time Updates:** Phoenix Channels or LiveView for order status updates visible to customers, chefs, and cashiers.
- **SurrealDB Integration:**
  - Use SurrealDB for its flexibility and potential for handling complex relationships (e.g., orders with nested items, inventory links).
  - Need to find or build Elixir drivers for SurrealDB.
  - Define clear data models and queries for SurrealDB.
- **Analytics Dashboard:**
  - Data will be periodically aggregated from SurrealDB into PostgreSQL.
  - The AI-powered dashboard will query PostgreSQL for performance.
- **Authentication & Authorization:**
  - Standard Phoenix authentication.
  - Role-based access control (RBAC) to restrict features based on user roles.

## 4. Data Models (Initial Thoughts)

- **Users:** id (SurrealDB), role (customer, manager, chef, cashier, accountant), name, email, password_hash
- **MenuItems:** id (SurrealDB), name, description, price, ingredients (list of InventoryItem ids/refs), available (boolean)
- **DailyMenu:** id (SurrealDB), date, menu_items (list of MenuItem ids/refs)
- **Orders:** id (SurrealDB), table_id, customer_id (optional), items (list of {menu_item_id, quantity, customizations}), status (received, preparing, ready, delivered), timestamps
- **InventoryItems:** id (SurrealDB), name, quantity, unit, expiry_date, category
- **EmployeeHours:** id (SurrealDB), employee_id (User id), clock_in, clock_out, approved (boolean)
- **Bills:** id (SurrealDB), order_id, items (list of {menu_item, quantity, price_at_time_of_order}), total_amount, payment_status

## 5. API Considerations

- Internal API for communication between Phoenix and SurrealDB.
- Potentially a simple external API for future integrations, though not a primary requirement.

## 6. Deployment Considerations

- Dockerize the application.
- Define clear startup procedures for Elixir, SurrealDB, and PostgreSQL.
- Consider cloud deployment options.