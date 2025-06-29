# Cost Estimator App

A comprehensive macOS application for construction cost estimation and project management, built with SwiftUI and Core Data.

## Features

### 🔐 Authentication & User Management
- Secure user authentication with role-based access control
- Four user roles: Admin, Manager, Estimator, and Viewer
- Permission-based feature access
- User management with password changes

### 👥 Customer Management
- Complete customer database with contact information
- Customer search and filtering
- Project tracking per customer
- Customer activity history

### 📁 Project Management
- Project creation and management
- Link projects to customers
- Project status tracking
- Timeline management

### 📋 Quotation System
- Detailed quotation creation
- Item-wise cost breakdown
- Multiple quotations per project
- Status tracking (Draft, Sent, Approved, etc.)

### 🧱 Materials Database
- Comprehensive materials catalog
- Dual UOM system (Storing vs Consuming)
- Automatic rate calculations with conversion units
- Bulk upload via CSV
- CSV template generation

### 📊 Cost Estimation
- **Material Costs**: Automatic calculation based on consumption
- **Labor Costs**: Manual entry per item
- **Overhead Costs**: Configurable percentage
- **Profit Margins**: Customizable per item
- **Subcontract Amounts**: For outsourced work
- **Total Selling Amount**: Comprehensive cost summary

### 💰 Multi-Currency Support
- Default currency: AED (UAE Dirham)
- Support for USD, EUR, GBP, INR, SAR
- Automatic currency formatting
- Company-wide currency settings

### 📈 Reports & Analytics
- Customer reports
- Project reports
- Estimation reports
- Material usage reports
- Financial summaries
- Date range filtering

## Data Structure

### Customer → Projects → Quotations → Items → Materials

```
Customer
├── Projects (Multiple)
│   ├── Quotations (Multiple)
│   │   ├── Items (Multiple)
│   │   │   ├── Materials (Multiple)
│   │   │   ├── Labor Cost
│   │   │   ├── Overhead Cost
│   │   │   ├── Profit Amount
│   │   │   └── Subcontract Amount (Optional)
│   │   └── Total Selling Amount
│   └── Status Tracking
└── Contact Information
```

### Materials Database Schema

| Field | Description | Required |
|-------|-------------|----------|
| Item Code | Unique identifier | Yes |
| Item Name | Material description | Yes |
| Storing UOM | Storage unit of measurement | Yes |
| Purchasing Amount | Price per storing unit | Yes |
| Consuming UOM | Usage unit of measurement | Yes |
| Conversion Unit | Conversion factor between storing and consuming UOM | No (Default: 1) |

**Example**: 
- Item: Portland Cement
- Storing UOM: Bag
- Purchasing Amount: 25.00 AED
- Consuming UOM: Kg
- Conversion Unit: 50.00 (1 Bag = 50 Kg)
- **Calculated Consuming Rate**: 0.50 AED per Kg

## Installation & Setup

### Requirements
- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Building the App
1. Open `CostEstimatorApp.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run (⌘+R)

### Default Login
- **Username**: admin
- **Password**: admin123

## User Roles & Permissions

### Admin
- Full system access
- User management
- All CRUD operations
- System settings

### Manager
- Customer, Project, Quotation management
- Materials management
- Bulk upload capabilities
- Reports access

### Estimator
- View customers and projects
- Create and edit quotations
- View materials database
- Generate reports

### Viewer
- Read-only access to all data
- View reports
- No editing capabilities

## CSV Bulk Upload

### Template Format
```csv
Item Code,Item Name,Storing UOM,Purchasing Amount,Consuming UOM,Conversion Unit
CEM001,Portland Cement,Bag,25.00,Kg,50.00
STL001,Steel Rebar 12mm,Ton,2500.00,Kg,1000.00
BLK001,Concrete Block 200mm,Piece,3.50,Piece,1.00
```

### Upload Process
1. Navigate to Materials → Bulk Upload
2. Download CSV template
3. Fill in material data
4. Upload and preview
5. Confirm import

## Cost Calculation Logic

### Item Total Cost Calculation
```
Material Cost = Σ(Material Consuming Rate × Consumed Quantity)
Total Item Cost = Material Cost + Labor Cost + Overhead Cost + Profit Amount + Subcontract Amount
```

### Quotation Total Calculation
```
Total Material Cost = Σ(All Items Material Cost)
Total Labor Cost = Σ(All Items Labor Cost)
Total Overhead Cost = Σ(All Items Overhead Cost)
Total Profit Amount = Σ(All Items Profit Amount)
Total Subcontract Amount = Σ(All Items Subcontract Amount)
Grand Total = Total Material + Labor + Overhead + Profit + Subcontract
```

## Technical Architecture

### Core Technologies
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence
- **Combine**: Reactive programming
- **CryptoKit**: Secure password hashing

### Data Models
- Customer (Core Data Entity)
- Project (Core Data Entity)
- Quotation (Core Data Entity)
- EstimationItem (Core Data Entity)
- Material (Core Data Entity)
- ItemMaterial (Core Data Entity - Junction table)

### Security Features
- SHA256 password hashing
- Secure user session management
- Role-based access control
- Input validation and sanitization

## Future Enhancements

### Planned Features
- PDF quotation generation
- Email integration
- Advanced reporting with charts
- Project templates
- Material price history
- Multi-company support
- Cloud synchronization
- Mobile companion app

### Integration Possibilities
- Accounting software integration
- Supplier catalog imports
- Project management tools
- Document management systems

## Support & Documentation

### Getting Help
- Check the built-in help system
- Review user permissions for access issues
- Verify CSV format for bulk uploads
- Contact system administrator for user management

### Data Backup
- Core Data automatically handles local storage
- Regular backups recommended
- Export functionality for data portability

## License

This application is developed for Zesto Tech and is proprietary software.

---

**Developed by**: Zesto Tech Development Team  
**Version**: 1.0  
**Last Updated**: 2024  
**Platform**: macOS 14.0+