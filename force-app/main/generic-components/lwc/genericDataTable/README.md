# Generic DataTable Component

A highly configurable and reusable Lightning Web Component for displaying tabular data in Salesforce. This component provides a flexible solution for rendering various data types with support for multiple data sources, custom formatting, and navigation capabilities.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Mortgage Contract Example](#mortgage-contract-example)
- [API Reference](#api-reference)
- [Best Practices](#best-practices)

## Overview

The `genericDataTable` component is designed to be a universal solution for displaying data in Salesforce Lightning pages. It supports multiple data sources (Apex, LMS, direct data), various column types, and extensive configuration options through both inline and external JSON configurations.

## Features

### Data Sources

- **Apex Controller Integration** - Direct connection to Apex methods
- **Lightning Message Service (LMS)** - Real-time data updates via messaging channels
- **Direct Data Binding** - Pass data directly to the component

### Display Capabilities

- **Multiple Column Types**: text, number, boolean, currency, date, datetime, email, location, percent, phone, url, button, action
- **Row Actions**: Configurable actions menu for each row
- **Sorting**: Built-in column sorting functionality
- **Filtering**: Filter data by field values
- **Selection**: Optional checkbox column for row selection
- **Row Numbers**: Optional row number display

### Configuration Options

- **External Configuration**: Load configuration from static resources
- **Inline Configuration**: Pass configuration directly as component property
- **Dynamic Column Definitions**: Support for various column properties and formatting

### Advanced Features

- **Data Extraction**: Extract nested data using JSON paths
- **Enum Mapping**: Map API values to display labels
- **Navigation Integration**: Navigate to other components/pages from row actions
- **Error Handling**: Comprehensive error states with visual feedback
- **Loading States**: Visual indicators during data fetch operations

## Component Structure

```
genericDataTable/
├── genericDataTable.js          # Main component logic
├── genericDataTable.html        # Component template
├── genericDataTable.css         # Component styles
├── genericDataTable.js-meta.xml # Component metadata
└── README.md                    # This file
```

## Configuration

### Basic Configuration Structure

```json
{
  "columns": [
    {
      "label": "Column Label",
      "fieldName": "fieldName",
      "type": "text",
      "sortable": true
    }
  ],
  "dataPath": "response.items",
  "actions": [
    {
      "label": "View",
      "name": "view_details"
    }
  ]
}
```

### Column Types and Properties

| Type     | Description              | Additional Properties                                                           |
| -------- | ------------------------ | ------------------------------------------------------------------------------- |
| text     | Plain text               | `sortable`, `wrapText`                                                          |
| number   | Numeric values           | `sortable`                                                                      |
| currency | Currency with formatting | `typeAttributes.currencyCode`                                                   |
| date     | Date only                | `sortable`, `typeAttributes.year`, `typeAttributes.month`, `typeAttributes.day` |
| datetime | Date with time           | All date properties plus `typeAttributes.hour`, `typeAttributes.minute`         |
| boolean  | True/false values        | -                                                                               |
| email    | Email with mailto link   | -                                                                               |
| phone    | Phone with tel link      | -                                                                               |
| url      | Clickable URL            | `typeAttributes.label`                                                          |
| button   | Clickable button         | `typeAttributes.label`, `typeAttributes.name`                                   |
| action   | Row actions menu         | Requires `actions` configuration                                                |

## Usage Examples

### Example 1: Basic Table with Apex Controller

```html
<c-generic-data-table
  record-id="{recordId}"
  apex-controller="MyDataController"
  config-name="myTableConfig"
  title="My Data Table"
  icon-name="standard:account"
  show-row-number-column="true"
>
</c-generic-data-table>
```

### Example 2: Table with LMS Integration

```html
<c-generic-data-table
  lms-topic="DataUpdateChannel"
  table-config="{tableConfiguration}"
  hide-checkbox-column="true"
  key-field="Id"
>
</c-generic-data-table>
```

### Example 3: Direct Data Binding

```html
<c-generic-data-table
  table-data="{myData}"
  table-config="{myConfig}"
  extract-path="records"
  filter-field="Status"
  filter-value="Active"
>
</c-generic-data-table>
```

## Mortgage Contract Example

The genericDataTable is extensively used for displaying mortgage-related data in the settlement process. Here's a real-world example:

### Configuration File: `config_MortgageContractsTable.json`

```json
{
  "columns": [
    {
      "label": "Contract ID",
      "fieldName": "contractId",
      "type": "button",
      "sortable": true,
      "typeAttributes": {
        "label": {
          "fieldName": "contractId"
        },
        "name": "navigate_to_contract"
      }
    },
    {
      "label": "Jurisdiction",
      "fieldName": "jurisdiction",
      "type": "text",
      "sortable": true,
      "enumValues": {
        "NSW": "New South Wales",
        "QLD": "Queensland",
        "SA": "South Australia",
        "ACT": "Australian Capital Territory",
        "VIC": "Victoria",
        "WA": "Western Australia"
      }
    },
    {
      "label": "Settlement Time",
      "fieldName": "settlementTime",
      "type": "date",
      "sortable": true
    },
    {
      "label": "Overall Acceptance Status",
      "fieldName": "overallAcceptanceStatus",
      "type": "text",
      "enumValues": {
        "PENDING": "Pending",
        "ACCEPTED": "Accepted",
        "REJECTED": "Rejected"
      }
    },
    {
      "label": "Actions",
      "type": "action",
      "typeAttributes": {
        "rowActions": [
          {
            "label": "View Details",
            "name": "view_details"
          }
        ]
      }
    }
  ],
  "dataPath": "mortgageContracts",
  "navigationConfig": {
    "view_details": {
      "componentName": "genericCard",
      "attributes": {
        "c__recordId": "{recordId}",
        "c__apexController": "MortgageContractDetailsController",
        "c__controllerParams": "{\"contractId\": \"{contractId}\"}"
      }
    }
  }
}
```

### Implementation in Lightning Page

```xml
<flexipage:flexipageRegion name="mortgageContractsRegion" type="Facet">
    <flexipage:componentInstance>
        <componentInstanceProperties>
            <name>apexController</name>
            <value>MortgageContractsController</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>configName</name>
            <value>config_mortgageContractsTable</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>controllerParams</name>
            <value>id</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>title</name>
            <value>Mortgage Contracts</value>
        </componentInstanceProperties>
        <componentInstanceProperties>
            <name>iconName</name>
            <value>standard:contract</value>
        </componentInstanceProperties>
        <componentName>genericDataTable</componentName>
    </flexipage:componentInstance>
</flexipage:flexipageRegion>
```

### Key Features in Mortgage Contract Usage

1. **Enum Mapping**: Maps jurisdiction codes to full state names
2. **Navigation**: Contract ID buttons navigate to detailed view
3. **Status Display**: Shows acceptance status with friendly labels
4. **Date Formatting**: Displays settlement dates in readable format
5. **Row Actions**: Provides quick access to contract details

## API Reference

### Properties

| Property              | Type    | Description                           | Default |
| --------------------- | ------- | ------------------------------------- | ------- |
| `recordId`            | String  | Current record context                | -       |
| `apexController`      | String  | Apex controller class name            | -       |
| `controllerParams`    | String  | JSON string or comma-separated params | -       |
| `lmsTopic`            | String  | LMS channel name for subscription     | -       |
| `tableData`           | Array   | Direct data array                     | -       |
| `tableConfig`         | Object  | Inline configuration object           | -       |
| `configName`          | String  | Static resource config file name      | -       |
| `title`               | String  | Component header title                | -       |
| `iconName`            | String  | SLDS icon name                        | -       |
| `keyField`            | String  | Unique row identifier field           | 'Id'    |
| `showRowNumberColumn` | Boolean | Show row numbers                      | false   |
| `hideCheckboxColumn`  | Boolean | Hide selection checkboxes             | false   |
| `hideTableHeader`     | Boolean | Hide table headers                    | false   |
| `extractPath`         | String  | JSON path for data extraction         | -       |
| `filterField`         | String  | Field name to filter                  | -       |
| `filterValue`         | String  | Filter value                          | -       |

### Methods

The component handles data loading and processing internally. No public methods are exposed.

### Events

The component dispatches navigation events when row actions are triggered.

## Best Practices

1. **Configuration Management**
   - Store complex configurations in static resources for reusability
   - Use descriptive names for configuration files

2. **Performance**
   - Use `extractPath` to reduce data payload
   - Enable filtering at the source when possible

3. **User Experience**
   - Always provide meaningful column labels
   - Use appropriate column types for data
   - Include loading states for better feedback
   - Handle errors gracefully with user-friendly messages

4. **Security**
   - Validate data in Apex controllers
   - Use proper field-level security
   - Sanitize any user inputs

5. **Maintenance**
   - Document custom configurations
   - Use consistent naming conventions
   - Test configurations across different data scenarios

## Troubleshooting

Common issues and solutions:

1. **Data not displaying**
   - Check `dataPath` configuration
   - Verify Apex controller permissions
   - Confirm data structure matches configuration

2. **Navigation not working**
   - Ensure navigation configuration is properly set
   - Check component API version compatibility
   - Verify target component exists

3. **Formatting issues**
   - Review column type attributes
   - Check for data type mismatches
   - Validate enum mappings

## Future Enhancements

- Inline editing capabilities
- Export functionality
- Advanced filtering UI
- Column resizing
- Pagination for large datasets

---

For questions or support, please contact the Salesforce development team.
