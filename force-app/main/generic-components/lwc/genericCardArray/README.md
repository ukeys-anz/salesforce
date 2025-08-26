# Generic Card Array Component

A Lightning Web Component that displays an array of data as a collection of cards in a single column layout. This component is designed to work with the `genericCard` component to render multiple related records in an organized, visually appealing format.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Settlement Accounts Example](#settlement-accounts-example)
- [API Reference](#api-reference)
- [Styling and Layout](#styling-and-layout)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The `genericCardArray` component is a container that renders multiple `genericCard` components from an array of data. It's particularly useful for displaying related records like settlement accounts, repayment preferences, or loan facilities on Salesforce record pages. Each item in the array is rendered as an individual card with consistent styling and spacing.

## Features

### Data Management

- **Multiple Data Sources** - Direct API data or Apex controller integration
- **Array Processing** - Automatically iterates through data arrays
- **Data Extraction** - Configurable data path for nested structures
- **Dynamic Title Fields** - Extract card titles from any data field

### Display Capabilities

- **Single Column Layout** - Cards displayed vertically with consistent spacing
- **Hover Effects** - Interactive hover states with shadow effects
- **Loading States** - Built-in spinner during data fetch
- **Error Handling** - Comprehensive error display component
- **Responsive Design** - Adapts to different screen sizes

### Configuration Options

- **External Configuration** - Load from static resource JSON files
- **Inline Configuration** - Direct configuration via component properties
- **Flexible Card Config** - Pass-through configuration to child cards
- **Enum Value Mapping** - Transform technical values to user-friendly labels

### Integration Features

- **Lightning Page Builder** - Full support for App Builder
- **Generic Controller** - Standardized data fetching
- **Component Communication** - Proper parent-child data flow
- **URL State Support** - Dynamic behavior via URL parameters

## Component Structure

```
genericCardArray/
├── genericCardArray.js          # Main component logic
├── genericCardArray.html        # Component template
├── genericCardArray.css         # Component styles
├── genericCardArray.js-meta.xml # Component metadata
└── README.md                   # This file
```

### Component Hierarchy

```
genericCardArray (parent)
    └── lightning-card (container)
        └── div.slds-col (for each item)
            └── c-generic-card (child component)
```

### Dependencies

- `c-generic-card` - Child component for individual cards
- `c-error` - Error display component
- `GenericController` - Apex controller for data fetching

## Configuration

### Configuration Structure

```json
{
  "dataPath": "pathToArrayData",
  "titleField": "fieldForCardTitle",
  "cardConfig": {
    "fieldConfig": {
      "title": "Section Title",
      "schema": [
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Field Label",
          "fieldColumn": "dataFieldPath",
          "isText": true
        }
      ],
      "layoutconfig": {
        "layout": {
          "horizontalAlign": "spread",
          "pull-to-boundary": "medium"
        },
        "layoutitem": {
          "size": "6",
          "padding": "around-small"
        }
      }
    }
  }
}
```

### Configuration Properties

| Property     | Type   | Description                       | Required |
| ------------ | ------ | --------------------------------- | -------- |
| `dataPath`   | String | Path to array in API response     | Yes      |
| `titleField` | String | Field path for card titles        | No       |
| `cardConfig` | Object | Configuration passed to each card | Yes      |
| `metadata`   | Object | Component metadata                | No       |

### Field Schema Configuration

The `cardConfig.fieldConfig.schema` array defines how fields are displayed:

```json
{
  "fieldtype": "lightning-formatted-text",
  "fieldLabel": "Account Status",
  "fieldColumn": "status",
  "isEnum": true,
  "enumValues": {
    "ACTIVE": "Active",
    "PENDING": "Pending",
    "CLOSED": "Closed"
  }
}
```

## Usage Examples

### Example 1: Basic Implementation

```html
<c-generic-card-array api-data="{accountData}" config-name="accountCardsConfig">
</c-generic-card-array>
```

### Example 2: With Apex Controller

```html
<c-generic-card-array
  apex-controller="AccountsController"
  controller-params="accountType=Settlement"
  use-controller-data="true"
  config-name="settlementAccountsConfig"
>
</c-generic-card-array>
```

### Example 3: Direct Configuration

```html
<c-generic-card-array
  api-data="{settlementData}"
  api-config="{cardArrayConfig}"
  title="Settlement Accounts"
>
</c-generic-card-array>
```

## Settlement Accounts Example

Here's a comprehensive example of how `genericCardArray` is used to display settlement accounts:

### Configuration File: `config_settlementAccount.json`

```json
{
  "dataPath": "settlementAccounts",
  "titleField": "nominatedSettlementAccount.name",
  "cardConfig": {
    "fieldConfig": {
      "title": "Settlement Account Details",
      "schema": [
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Account Number",
          "fieldColumn": "nominatedSettlementAccount.name",
          "isText": true,
          "isStacked": true
        },
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Nominated Account State",
          "fieldColumn": "nominatedAccountState",
          "isEnum": true,
          "enumValues": {
            "PENDING_NOMINATION": "Pending Nomination",
            "NOMINATED": "Nominated",
            "REJECTED": "Rejected",
            "SETTLEMENT_COMPLETE": "Settlement Complete"
          }
        },
        {
          "fieldtype": "lightning-formatted-date-time",
          "fieldLabel": "Nominated Date",
          "fieldColumn": "nominatedDate",
          "isDate": true,
          "typeAttributes": {
            "year": "numeric",
            "month": "long",
            "day": "2-digit",
            "hour": "2-digit",
            "minute": "2-digit"
          }
        },
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Nominated By",
          "fieldColumn": "nominatedBy",
          "isText": true
        },
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "BSB",
          "fieldColumn": "nominatedSettlementAccount.bsb",
          "isText": true
        },
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Settlement ID",
          "fieldColumn": "settlementId",
          "isRecordUrl": true,
          "isStacked": true
        }
      ],
      "layoutconfig": {
        "layout": {
          "horizontalAlign": "spread",
          "verticalAlign": "start",
          "pull-to-boundary": "medium"
        },
        "layoutitem": {
          "flexibility": "auto",
          "padding": "around-small",
          "size": "6"
        }
      }
    }
  },
  "metadata": {
    "component": "genericCardArray",
    "version": "1.0"
  }
}
```

### Lightning Page Implementation

```xml
<flexipage:flexipageRegion name="settlementAccountsRegion" type="Facet">
    <flexipage:componentInstance>
        <componentInstanceProperties>
            <name>apexController</name>
            <value>SettlementAccountController</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>configName</name>
            <value>config_settlementAccount</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>controllerParams</name>
            <value>settlementId</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>title</name>
            <value>Settlement Accounts</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>iconName</name>
            <value>standard:account</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>useControllerData</name>
            <value>true</value>
        </componentInstanceProperties>
        <componentName>genericCardArray</componentName>
    </flexipage:componentInstance>
</flexipage:flexipageRegion>
```

### Apex Controller Data Structure

The controller returns data in this format:

```json
{
  "settlementAccounts": [
    {
      "settlementId": "SET-001",
      "nominatedSettlementAccount": {
        "name": "1234567890",
        "bsb": "062-001"
      },
      "nominatedAccountState": "NOMINATED",
      "nominatedDate": "2024-01-15T10:30:00Z",
      "nominatedBy": "John Smith"
    },
    {
      "settlementId": "SET-002",
      "nominatedSettlementAccount": {
        "name": "0987654321",
        "bsb": "062-002"
      },
      "nominatedAccountState": "PENDING_NOMINATION",
      "nominatedDate": "2024-01-16T14:45:00Z",
      "nominatedBy": "Jane Doe"
    }
  ]
}
```

### Rendered Output

Each settlement account is displayed as a card containing:

- **Title**: Account number (from `nominatedSettlementAccount.name`)
- **Fields**:
  - Account Number (stacked display)
  - Nominated Account State (with enum mapping)
  - Nominated Date (formatted date/time)
  - Nominated By
  - BSB
  - Settlement ID (as clickable link)

## API Reference

### Properties

| Property            | Type          | Description                    | Default |
| ------------------- | ------------- | ------------------------------ | ------- |
| `recordId`          | String        | Salesforce record ID           | -       |
| `apiData`           | Object/String | Direct data input              | -       |
| `apexController`    | String        | Apex controller class name     | -       |
| `controllerParams`  | String        | Parameters for Apex controller | -       |
| `useControllerData` | Boolean       | Fetch data from controller     | false   |
| `apiConfig`         | Object        | Direct configuration object    | -       |
| `configName`        | String        | Static resource config name    | -       |
| `title`             | String        | Card array title               | -       |
| `iconName`          | String        | SLDS icon name                 | -       |

### Internal Properties

| Property         | Type    | Description               |
| ---------------- | ------- | ------------------------- |
| `_isLoading`     | Boolean | Loading state indicator   |
| `_hasError`      | Boolean | Error state indicator     |
| `_errorMessage`  | String  | Error message to display  |
| `_cardArrayData` | Array   | Processed array data      |
| `_enumData`      | Object  | Enum mappings from config |

### Methods

The component handles all data processing internally. No public methods are exposed.

## Styling and Layout

### CSS Classes

```css
.slds-col {
  padding: 5px 10px;
}

.card-box {
  background-color: white;
  border: 1px solid #dddbda;
  border-radius: 4px;
  padding: 16px;
  margin-bottom: 12px;
  transition: box-shadow 0.3s ease;
}

.card-box:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
```

### Layout Behavior

- Cards are displayed in a single column
- Each card has consistent padding and margins
- Hover effects provide visual feedback
- Responsive design adapts to container width

## Best Practices

### 1. Configuration Management

- Store configurations in static resources with descriptive names
- Use version control for configuration files
- Document complex data paths and transformations
- Validate configuration structure before deployment

### 2. Performance Optimization

- Limit the number of cards displayed (consider pagination for > 10 items)
- Use efficient data paths to minimize processing
- Cache configuration files appropriately
- Optimize Apex queries to return only necessary data

### 3. User Experience

- Provide meaningful card titles using `titleField`
- Keep the number of fields per card reasonable (5-7 max)
- Use appropriate field types for data display
- Ensure consistent card heights when possible
- Consider empty state messaging

### 4. Data Handling

- Always validate array data before processing
- Handle null/empty arrays gracefully
- Use defensive programming for nested paths
- Provide fallback values for optional fields

### 5. Error Management

- Implement proper error handling in Apex controllers
- Use try-catch blocks for data processing
- Display user-friendly error messages
- Log errors for debugging purposes

## Common Patterns

### Nested Data Access

```json
{
  "dataPath": "response.data.accounts",
  "titleField": "accountDetails.primaryName"
}
```

### Multiple Status Fields

```json
{
  "fieldColumn": "status",
  "isEnum": true,
  "enumValues": {
    "ACTIVE": "Active",
    "PENDING": "Pending Review",
    "CLOSED": "Closed"
  }
}
```

### Conditional Rendering

```javascript
// In Apex controller
if (hasSettlementAccounts) {
    return new Map<String, Object>{
        'settlementAccounts' => accounts
    };
} else {
    return new Map<String, Object>{
        'settlementAccounts' => new List<Object>()
    };
}
```

## Troubleshooting

### Common Issues and Solutions

1. **No cards displayed**

   - Verify `dataPath` points to an array in the response
   - Check console for data structure
   - Ensure Apex controller returns data in expected format
   - Confirm configuration file is properly deployed

2. **Card titles not showing**

   - Check `titleField` path is correct
   - Verify the field contains data
   - Consider using a fallback field

3. **Enum values not mapping**

   - Ensure exact match between data values and enum keys
   - Check for case sensitivity issues
   - Verify `isEnum: true` is set

4. **Layout issues**

   - Review `layoutconfig` settings in card configuration
   - Check for CSS conflicts
   - Verify SLDS is properly loaded

5. **Performance problems**
   - Reduce the number of cards displayed
   - Optimize Apex controller queries
   - Simplify data paths
   - Consider implementing pagination

### Debug Tips

1. Enable debug mode in the browser console
2. Check the component's data using Chrome DevTools
3. Verify configuration loads correctly
4. Monitor network requests for data fetching
5. Use `console.log` statements in development

---

For questions or support, please contact the Salesforce development team.
