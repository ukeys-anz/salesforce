# Generic Card Component

A highly flexible Lightning Web Component for displaying structured data in card format with support for field layouts and data tables. This component provides a configurable solution for rendering API data with various field types, layouts, and embedded tables.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Settlement and Mortgage Examples](#settlement-and-mortgage-examples)
- [API Reference](#api-reference)
- [Field Types](#field-types)
- [Best Practices](#best-practices)

## Overview

The `genericCard` component is designed to display complex data structures in a card format with customizable field layouts and optional data tables. It can work standalone or as a child component of `genericCardArray` for displaying multiple cards. The component supports various data sources and provides extensive configuration options through JSON files.

## Features

### Data Sources

- **Direct Data Binding** - Pass data directly via `apiData` property
- **Apex Controller Integration** - Fetch data from Apex controllers
- **URL State Parameters** - Support for dynamic configuration via URL parameters

### Display Capabilities

- **Flexible Field Layouts** - Configurable multi-column layouts
- **Multiple Field Types** - Text, number, date, boolean, currency, and more
- **Embedded Data Tables** - Display related data in tables within the card
- **Enum Value Mapping** - Map API values to user-friendly labels
- **Conditional Display** - Show/hide fields based on data values

### Configuration Options

- **External Configuration** - Load from static resources JSON files
- **Inline Configuration** - Pass configuration directly as property
- **Dynamic Field Mapping** - Support for nested data paths
- **Custom Styling** - Apply custom CSS via static resources

### Advanced Features

- **Error Handling** - Built-in error display component
- **Loading States** - Visual feedback during data fetch
- **Tab Management** - Automatic tab naming for console apps
- **Data Filtering** - Filter data based on field conditions
- **Responsive Design** - SLDS-based responsive layouts

## Component Structure

```
genericCard/
├── genericCard.js          # Main component logic
├── genericCard.html        # Component template
├── genericCard.css         # Component styles
├── genericCard.js-meta.xml # Component metadata
└── README.md              # This file
```

### Child Components Used

- `c-generic-button-handler` - Handles button actions
- `c-generic-field-container` - Renders field layouts
- `c-generic-data-table` - Displays tabular data
- `c-error` - Shows error messages

## Configuration

### Basic Configuration Structure

```json
{
  "cardTitle": "Cards Title",
  "fieldConfig": {
    "title": "Section Title",
    "schema": [
      {
        "fieldtype": "lightning-formatted-text",
        "fieldLabel": "Field Label",
        "fieldColumn": "path.to.data.field",
        "isText": true
      }
    ],
    "layoutconfig": {
      "layout": {
        "horizontalAlign": "spread",
        "verticalAlign": "end",
        "pull-to-boundary": "medium"
      },
      "layoutitem": {
        "flexibility": "auto",
        "padding": "around-small",
        "size": "6"
      }
    }
  },
  "tableConfig": [
    {
      "title": "Related Data",
      "dataPath": "relatedItems",
      "columns": [
        {
          "type": "text",
          "label": "Name",
          "fieldName": "name"
        }
      ]
    }
  ]
}
```

### Field Schema Properties

| Property      | Type    | Description                                                 |
| ------------- | ------- | ----------------------------------------------------------- |
| `fieldtype`   | String  | Lightning component type (e.g., `lightning-formatted-text`) |
| `fieldLabel`  | String  | Display label for the field                                 |
| `fieldColumn` | String  | Path to data field (supports nested paths)                  |
| `isText`      | Boolean | Plain text field                                            |
| `isDate`      | Boolean | Date field with formatting                                  |
| `isEnum`      | Boolean | Field with enum value mapping                               |
| `isRecordUrl` | Boolean | Clickable Salesforce record link                            |
| `isStacked`   | Boolean | Stack label and value vertically                            |
| `enumValues`  | Object  | Mapping of API values to display labels                     |

### Layout Configuration

The `layoutconfig` object controls the visual arrangement:

```json
{
  "layout": {
    "horizontalAlign": "spread|center|space|stretch|end",
    "verticalAlign": "start|center|end|stretch",
    "pull-to-boundary": "small|medium|large"
  },
  "layoutitem": {
    "flexibility": "auto|grow|shrink|no-grow|no-shrink",
    "padding": "around-small|around-medium|around-large",
    "size": "1-12" // Grid column size
  }
}
```

## Usage Examples

### Example 1: Standalone Card with Direct Data

```html
<c-generic-card
  api-data="{myData}"
  config-name="myCardConfig"
  title="Customer Details"
>
</c-generic-card>
```

### Example 2: Card with Apex Controller

```html
<c-generic-card
  record-id="{recordId}"
  apex-controller="CustomerDataController"
  controller-params="customerId"
  use-controller-data="true"
  config-name="customerCardConfig"
>
</c-generic-card>
```

### Example 3: Card within genericCardArray

```html
<c-generic-card-array
  apex-controller="AccountsController"
  config-name="accountCardsConfig"
  controller-params="accountType=Business"
>
</c-generic-card-array>
```

## Settlement and Mortgage Examples

The genericCard component is extensively used in settlement and mortgage processes. Here are real-world examples:

### Settlement Account Configuration

```json
{
  "dataPath": "settlementAccounts",
  "titleField": "accountName",
  "cardConfig": {
    "cardTitle": "Card Title",
    "fieldConfig": {
      "title": "Settlement Account Details",
      "schema": [
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Account ID",
          "fieldColumn": "accountId",
          "isText": true
        },
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Status",
          "fieldColumn": "status",
          "isEnum": true,
          "enumValues": {
            "ACTIVE": "Active",
            "PENDING": "Pending",
            "CLOSED": "Closed"
          }
        },
        {
          "fieldtype": "lightning-formatted-date-time",
          "fieldLabel": "Created Date",
          "fieldColumn": "createdDate",
          "isDate": true
        },
        {
          "fieldtype": "lightning-formatted-number",
          "fieldLabel": "Balance",
          "fieldColumn": "balance.amount",
          "isNumber": true,
          "typeAttributes": {
            "currencyCode": "AUD",
            "currencyDisplayAs": "symbol"
          }
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

### Mortgage Contract Details Configuration

```json
{
  "fieldConfig": {
    "title": "Mortgage Contract Information",
    "schema": [
      {
        "fieldtype": "lightning-formatted-text",
        "fieldLabel": "Contract ID",
        "fieldColumn": "contractId",
        "isText": true,
        "isStacked": true
      },
      {
        "fieldtype": "lightning-formatted-text",
        "fieldLabel": "Jurisdiction",
        "fieldColumn": "jurisdiction",
        "isEnum": true,
        "enumValues": {
          "NSW": "New South Wales",
          "VIC": "Victoria",
          "QLD": "Queensland",
          "WA": "Western Australia",
          "SA": "South Australia",
          "TAS": "Tasmania",
          "ACT": "Australian Capital Territory",
          "NT": "Northern Territory"
        }
      },
      {
        "fieldtype": "lightning-formatted-text",
        "fieldLabel": "Lodgement Status",
        "fieldColumn": "lodgementStatus",
        "isEnum": true,
        "enumValues": {
          "NOT_LODGED": "Not Lodged",
          "LODGED": "Lodged",
          "REGISTERED": "Registered",
          "REJECTED": "Rejected"
        }
      }
    ]
  },
  "tableConfig": [
    {
      "title": "Registration Fees",
      "dataPath": "registrationFees",
      "columns": [
        {
          "type": "text",
          "label": "Fee Type",
          "fieldName": "feeType"
        },
        {
          "type": "currency",
          "label": "Amount",
          "fieldName": "amount",
          "typeAttributes": {
            "currencyCode": "AUD"
          }
        },
        {
          "type": "text",
          "label": "Status",
          "fieldName": "status"
        }
      ]
    }
  ]
}
```

### Implementation in Lightning Page

```xml
<flexipage:flexipageRegion name="settlementRegion" type="Facet">
    <flexipage:componentInstance>
        <componentInstanceProperties>
            <name>apexController</name>
            <value>SettlementDetailsController</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>configName</name>
            <value>config_settlementDetails</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>controllerParams</name>
            <value>settlementId</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>useControllerData</name>
            <value>true</value>
        </componentInstanceProperties>
        <componentName>genericCard</componentName>
    </flexipage:componentInstance>
</flexipage:flexipageRegion>
```

## API Reference

### Properties

| Property            | Type          | Description                    | Default |
| ------------------- | ------------- | ------------------------------ | ------- |
| `recordId`          | String        | Salesforce record ID           | -       |
| `tabName`           | String        | Tab label when opened          | -       |
| `title`             | String        | Card title                     | -       |
| `apiData`           | Object/String | Direct data input              | -       |
| `apexController`    | String        | Apex controller class name     | -       |
| `controllerParams`  | String        | Parameters for Apex controller | -       |
| `useControllerData` | Boolean       | Fetch data from controller     | false   |
| `apiConfig`         | Object        | Direct configuration object    | -       |
| `configName`        | String        | Static resource config name    | -       |
| `filterCondition`   | Object        | Data filtering options         | -       |

### Methods

The component handles all data processing internally. No public methods are exposed.

### Events

The component dispatches events through child components (e.g., button clicks via genericButtonHandler).

## Field Types

### Supported Lightning Field Types

| Field Type | Component                       | Use Case                      |
| ---------- | ------------------------------- | ----------------------------- |
| Text       | `lightning-formatted-text`      | Plain text display            |
| Number     | `lightning-formatted-number`    | Numeric values                |
| Currency   | `lightning-formatted-number`    | Monetary values with currency |
| Date       | `lightning-formatted-date-time` | Date/time display             |
| Boolean    | `lightning-formatted-boolean`   | True/false values             |
| URL        | `lightning-formatted-url`       | Clickable links               |
| Email      | `lightning-formatted-email`     | Email addresses               |
| Phone      | `lightning-formatted-phone`     | Phone numbers                 |
| Rich Text  | `lightning-formatted-rich-text` | HTML content                  |

### Special Field Properties

```json
{
  "fieldtype": "lightning-formatted-number",
  "fieldLabel": "Amount",
  "fieldColumn": "amount.value",
  "isNumber": true,
  "typeAttributes": {
    "currencyCode": "AUD",
    "currencyDisplayAs": "symbol",
    "minimumFractionDigits": 2,
    "maximumFractionDigits": 2
  }
}
```

## Best Practices

### 1. Configuration Management

- Store configurations in version-controlled static resources
- Use meaningful names for configuration files (e.g., `config_settlementAccount.json`)
- Document complex field paths and transformations
- Keep configurations DRY by reusing common patterns

### 2. Performance Optimization

- Use `dataPath` to extract only needed data
- Limit the number of fields displayed initially
- Consider pagination for large table datasets
- Cache configuration files appropriately

### 3. User Experience

- Group related fields logically
- Use appropriate field types for data
- Provide clear field labels
- Use enum mappings for technical values
- Consider mobile responsiveness in layouts

### 4. Error Handling

- Always provide fallback values for optional fields
- Handle null/undefined data gracefully
- Use the built-in error component for failures
- Log errors appropriately for debugging

### 5. Security

- Validate data in Apex controllers
- Respect field-level security
- Sanitize any HTML content
- Use proper authentication for data access

## Common Patterns

### Nested Data Access

```json
{
  "fieldColumn": "account.details.balance.amount"
}
```

### Array Index Access

```json
{
  "fieldColumn": "addresses[0].streetName"
}
```

### Conditional Display

```json
{
  "fieldColumn": "status",
  "hideIfEmpty": true
}
```

### Dynamic Currency

```json
{
  "fieldColumn": "amount",
  "typeAttributes": {
    "currencyCode": {
      "fieldName": "currencyCode"
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Data not displaying**

   - Verify the data path in configuration
   - Check console for data structure
   - Ensure apex controller returns expected format

2. **Layout issues**

   - Review layoutconfig settings
   - Check for conflicting CSS
   - Verify SLDS classes are correct

3. **Enum values not mapping**

   - Confirm enum values match exactly
   - Check for case sensitivity
   - Verify isEnum flag is set to true

4. **Performance problems**
   - Reduce number of fields displayed
   - Optimize Apex queries
   - Use appropriate data paths

---

For questions or support, please contact the Salesforce development team.
