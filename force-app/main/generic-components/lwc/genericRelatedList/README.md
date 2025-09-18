# Generic Related List Component

A flexible Lightning Web Component for displaying related records in Salesforce using dynamic, JSON-driven configurations. This component enables rapid creation of related lists for any object, with support for custom layouts, enum mapping, and controller-driven data.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Apex Controller Interface](#apex-controller-interface)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The `genericRelatedList` component renders a configurable related list for any Salesforce object. It uses JSON-based configuration files (see examples in `staticresources`) to define the fields, layout, and enum mappings, and retrieves data via Apex controllers implementing a generic interface.

## Features

### Core Capabilities

- **Dynamic Configuration**: Layout and fields defined in JSON Static Resources
- **Flexible Data Sources**: Works with any Apex controller implementing a generic interface
- **Enum Mapping**: Converts technical values to user-friendly labels
- **View All Navigation**: Supports navigation to a full data table view
- **Error Handling**: Displays errors from child components and data fetches

### Display Features

- **Loading States**: Shows spinner during data fetch
- **Responsive Design**: SLDS-based layouts
- **Custom Styling**: Loads external CSS via Static Resource
- **Icon Support**: Optional icon in list title

### Data Processing

- **Nested Object Support**: Access deep properties via dot notation
- **Array Handling**: Supports arrays and object-to-array conversion
- **Enum and Date Formatting**: Automatic mapping and formatting

## Architecture

### Component Hierarchy

```
genericRelatedList (Parent)
├── lightning-card (Container)
├── lightning-spinner (Loading State)
├── c-error (Error Display)
└── c-generic-field-container (For each section)
    └── c-generic-field (Individual fields)
```

### Data Flow

```
1. Component Initialization
   ↓
2. Load Configuration from Static Resource
   ↓
3. Fetch Data via Apex Controller
   ↓
4. Apply Enum Mappings
   ↓
5. Render Sections with Field Containers
```

## Configuration

### Static Resource Structure

See attached examples:

- [`config_tasks.json`](../../sf-lending/staticresources/config_tasks.json)
- [`config_loanAccept.json`](../../sf-lending/staticresources/config_loanAccept.json)
- [`config_proofOfInsurance.json`](../../sf-lending/staticresources/config_proofOfInsurance.json)

#### Example Section

```json
{
  "sections": [
    {
      "title": "",
      "schema": [
        {
          "fieldtype": "lightning-formatted-text",
          "fieldLabel": "Task Name",
          "fieldColumn": "type",
          "isEnum": true,
          "enumValues": {
            "TYPE_UNSPECIFIED": "Unspecified",
            "TYPE_UPLOAD_LOO_DOCUMENT": "Upload Loo Document"
          }
        }
      ],
      "layoutconfig": {
        "layout": {
          "horizontalAlign": "spread"
        },
        "layoutitem": {
          "size": "12"
        }
      },
      "viewallconfig": {
        "schema": "config_tasksTable"
      }
    }
  ]
}
```

#### Field Properties

| Property      | Type    | Description                             |
| ------------- | ------- | --------------------------------------- |
| `fieldLabel`  | String  | Display label for the field             |
| `fieldColumn` | String  | Path to the value in the data object    |
| `fieldtype`   | String  | Field display type (e.g., text, number) |
| `isEnum`      | Boolean | Whether to map value using `enumValues` |
| `enumValues`  | Object  | Key-value mapping for enum display      |
| `isDate`      | Boolean | Format value as date                    |
| `isRecordUrl` | Boolean | Render as a clickable record link       |
| `attributes`  | Object  | Additional field-specific configuration |

#### Section Properties

| Property        | Type   | Description                             |
| --------------- | ------ | --------------------------------------- |
| `title`         | String | Section title                           |
| `schema`        | Array  | List of field definitions               |
| `layoutconfig`  | Object | Layout configuration for section        |
| `viewallconfig` | Object | Configuration for "View All" navigation |

## View All

When more than two records are present, a "View All" button appears. Clicking it navigates to a full data table view, passing configuration and context via navigation state.

## API Reference

### Component Properties

| Property           | Type   | Description                                       | Required |
| ------------------ | ------ | ------------------------------------------------- | -------- |
| `ApexController`   | String | Name of Apex class implementing generic interface | Yes      |
| `SchemaConfig`     | String | Name of Static Resource containing configuration  | Yes      |
| `RelatedListTitle` | String | Title for the related list                        | Yes      |
| `TargetKey`        | String | Path to extract data from controller response     | Optional |
| `titleIcon`        | String | SLDS icon name for title                          | Optional |
| `recordId`         | String | Record ID context                                 | Yes      |

## Apex Controller Interface

Controllers must implement a method that returns a data structure compatible with the config schema.

```apex
global interface IGenericClass {
  Map<String, Object> getData(Map<String, String> params);
}
```

### Example Implementation

```apex
global class SettlementController implements IGenericClass {
  global Map<String, Object> getData(Map<String, String> params) {
    String recordId = params.get('recordId');
    // Query and build data map
    // Return array or object as required by config
  }
}
```

## Best Practices

- Keep configurations modular and reusable
- Use meaningful field labels and section titles
- Document enum mappings clearly
- Optimize Apex queries for performance
- Implement proper error handling in controllers

## Troubleshooting

### Common Issues

- **Configuration not loading**: Check Static Resource name and JSON syntax
- **Data not displaying**: Confirm controller returns correct structure
- **Enum values not mapping**: Ensure keys match data values exactly
- **View All not working**: Verify `viewallconfig` and schema name are correct
- **Styling issues**: Confirm CSS Static Resource is loaded

### Debugging

Enable debug logging in your component:

```javascript
connectedCallback() {
  console.log('Controller:', this.ApexController);
  console.log('Config Name:', this.SchemaConfig);
  console.log('Record ID:', this.recordId);
}
```

---
