# Generic Record Detail Component

A highly configurable Lightning Web Component for displaying Salesforce record details with dynamic layouts and field configurations. This component provides a flexible, JSON-driven approach to rendering record data without writing custom code for each object type.

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

The `genericRecordDetail` component is a reusable solution for displaying record details across different Salesforce objects. It uses JSON-based configurations stored in Static Resources to define field layouts and retrieves data through configurable Apex controllers that implement the `IGenericClass` interface.

## Features

### Core Capabilities

- **Dynamic Configuration** - JSON-driven layouts from Static Resources
- **Flexible Data Sources** - Any Apex controller implementing IGenericClass
- **Enum Mapping** - Convert technical values to user-friendly labels
- **Section-Based Layout** - Organize fields into logical sections
- **Error Handling** - Comprehensive error display and logging

### Display Features

- **Loading States** - Visual feedback during data fetch
- **Responsive Design** - SLDS-based adaptive layouts
- **Custom Styling** - Support for external CSS via Static Resources
- **Card Container** - Clean presentation with proper spacing

### Data Processing

- **Nested Object Support** - Access deep object properties
- **Array Handling** - Process arrays with index notation
- **Date Formatting** - Automatic date/time formatting
- **Null Handling** - Graceful handling of missing data

## Architecture

### Component Hierarchy

```
genericRecordDetail (Parent)
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

### Required Interfaces

```apex
global interface IGenericClass {
  Map<String, Object> getData(Map<String, String> params);
}
```

## Configuration

### Static Resource Configuration Structure

```json
{
  "title": "Record Detail View",
  "sections": [
    {
      "title": "Basic Information",
      "layoutconfig": {
        "layout": {
          "horizontalAlign": "spread",
          "verticalAlign": "start"
        },
        "layoutitem": {
          "size": "6",
          "padding": "around-small"
        }
      },
      "schema": [
        {
          "fieldColumn": "name",
          "fieldLabel": "Name",
          "fieldtype": "text"
        },
        {
          "fieldColumn": "status",
          "fieldLabel": "Status",
          "fieldtype": "text",
          "isEnum": true
        }
      ]
    }
  ],
  "enumMappings": {
    "status": {
      "NEW": "New",
      "IN_PROGRESS": "In Progress",
      "COMPLETED": "Completed"
    }
  }
}
```

### Configuration Properties

| Property       | Type   | Description                 | Required |
| -------------- | ------ | --------------------------- | -------- |
| `title`        | String | Page/card title             | No       |
| `sections`     | Array  | List of sections to display | Yes      |
| `enumMappings` | Object | Value-to-label mappings     | No       |
| `style`        | String | Custom CSS resource name    | No       |

### Section Properties

| Property       | Type   | Description          | Required |
| -------------- | ------ | -------------------- | -------- |
| `title`        | String | Section title        | Yes      |
| `layoutconfig` | Object | Layout configuration | Yes      |
| `schema`       | Array  | Field definitions    | Yes      |

## Usage Examples

### Example 1: Basic Implementation

```html
<c-generic-record-detail
  apex-controller="AccountDetailController"
  schema-config="accountDetailConfig"
  record-id="{recordId}"
>
</c-generic-record-detail>
```

**Lightning Page Configuration:**

```xml
<componentInstance>
    <componentInstanceProperties>
        <name>ApexController</name>
        <value>AccountDetailController</value>
    </componentInstanceProperties>
    <componentInstanceProperties>
        <name>SchemaConfig</name>
        <value>accountDetailConfig</value>
    </componentInstanceProperties>
    <componentName>genericRecordDetail</componentName>
</componentInstance>
```

### Example 2: Custom Object with Enums

**Static Resource: `customObjectConfig.json`**

```json
{
  "title": "Project Details",
  "sections": [
    {
      "title": "Project Information",
      "layoutconfig": {
        "layout": {
          "horizontalAlign": "spread"
        },
        "layoutitem": {
          "size": "6",
          "padding": "around-small"
        }
      },
      "schema": [
        {
          "fieldColumn": "projectName",
          "fieldLabel": "Project Name",
          "fieldtype": "text"
        },
        {
          "fieldColumn": "stage",
          "fieldLabel": "Stage",
          "fieldtype": "text",
          "isEnum": true
        },
        {
          "fieldColumn": "startDate",
          "fieldLabel": "Start Date",
          "fieldtype": "date",
          "isDate": true
        },
        {
          "fieldColumn": "budget.amount",
          "fieldLabel": "Budget",
          "fieldtype": "number",
          "attributes": {
            "formatStyle": "currency",
            "currencyCode": "USD"
          }
        }
      ]
    },
    {
      "title": "Team Information",
      "layoutconfig": {
        "layoutitem": {
          "size": "12"
        }
      },
      "schema": [
        {
          "fieldColumn": "teamLead.name",
          "fieldLabel": "Team Lead",
          "fieldtype": "text"
        },
        {
          "fieldColumn": "teamSize",
          "fieldLabel": "Team Size",
          "fieldtype": "number"
        }
      ]
    }
  ],
  "enumMappings": {
    "stage": {
      "PLANNING": "Planning",
      "IN_PROGRESS": "In Progress",
      "UAT": "User Acceptance Testing",
      "DEPLOYED": "Deployed"
    }
  }
}
```

### Example 3: Apex Controller Implementation

```apex
global class ProjectDetailController implements IGenericClass {
  global Map<String, Object> getData(Map<String, String> params) {
    String recordId = params.get('recordId');

    Project__c project = [
      SELECT
        Id,
        Name,
        Stage__c,
        Start_Date__c,
        Budget_Amount__c,
        Budget_Currency__c,
        Team_Lead__r.Name,
        Team_Size__c
      FROM Project__c
      WHERE Id = :recordId
    ];

    return new Map<String, Object>{
      'projectName' => project.Name,
      'stage' => project.Stage__c,
      'startDate' => project.Start_Date__c,
      'budget' => new Map<String, Object>{
        'amount' => project.Budget_Amount__c,
        'currency' => project.Budget_Currency__c
      },
      'teamLead' => new Map<String, Object>{
        'name' => project.Team_Lead__r.Name
      },
      'teamSize' => project.Team_Size__c
    };
  }
}
```

## API Reference

### Component Properties

| Property         | Type   | Description                                      | Required   |
| ---------------- | ------ | ------------------------------------------------ | ---------- |
| `ApexController` | String | Name of Apex class implementing IGenericClass    | Yes        |
| `SchemaConfig`   | String | Name of Static Resource containing configuration | Yes        |
| `recordId`       | String | Record ID (from page context or passed)          | Contextual |

### Exposed Targets

- **lightning\_\_AppPage** - Can be used on App pages
- **lightning\_\_RecordPage** - Can be used on Record pages
- **lightning\_\_HomePage** - Can be used on Home pages
- **lightningCommunity\_\_Page** - Can be used in Communities
- **lightningCommunity\_\_Default** - Default community component

## Apex Controller Interface

### IGenericClass Interface

```apex
global interface IGenericClass {
  /**
   * Retrieves data for the generic component
   * @param params Map containing parameters (typically includes 'recordId')
   * @return Map<String, Object> containing the data to display
   */
  Map<String, Object> getData(Map<String, String> params);
}
```

### Implementation Guidelines

1. **Parameter Handling**

   ```apex
   String recordId = params.get('recordId');
   String additionalParam = params.get('customParam');
   ```

2. **Data Structure**

   - Return flat or nested objects
   - Use Maps for complex structures
   - Arrays are supported

3. **Error Handling**
   ```apex
   try {
       // Data retrieval logic
   } catch (Exception e) {
       throw new AuraHandledException(e.getMessage());
   }
   ```

## Best Practices

### 1. Configuration Design

- Keep configurations modular and reusable
- Use meaningful section titles
- Group related fields together
- Document enum mappings clearly

### 2. Performance

- Optimize Apex queries (selective queries, limited fields)
- Use lazy loading for large datasets
- Cache static configurations
- Minimize nested object depth

### 3. Security

- Implement proper FLS checks in Apex
- Use with sharing in controllers
- Validate record access
- Sanitize any dynamic content

### 4. User Experience

- Provide loading indicators
- Display meaningful error messages
- Use appropriate field types
- Consider mobile responsiveness

### 5. Maintenance

- Version control configurations
- Document controller interfaces
- Use consistent naming conventions
- Create reusable enum mappings

## Common Patterns

### Multi-Object Support

```apex
global class GenericDetailController implements IGenericClass {
  global Map<String, Object> getData(Map<String, String> params) {
    String recordId = params.get('recordId');
    String objectType = params.get('objectType');

    if (objectType == 'Account') {
      return getAccountData(recordId);
    } else if (objectType == 'Contact') {
      return getContactData(recordId);
    }
    // ...
  }
}
```

### Dynamic Field Selection

```json
{
  "sections": [
    {
      "title": "Dynamic Fields",
      "schema": [
        {
          "fieldColumn": "dynamicField1",
          "fieldLabel": "Custom Field 1",
          "fieldtype": "text",
          "condition": "showCustomFields"
        }
      ]
    }
  ]
}
```

### Related Records

```json
{
  "schema": [
    {
      "fieldColumn": "account.name",
      "fieldLabel": "Account",
      "fieldtype": "text",
      "isRecordLink": true,
      "attributes": {
        "recordId": "{account.id}"
      }
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. **Configuration not loading**

   - Verify Static Resource name is correct
   - Check JSON syntax is valid
   - Ensure Static Resource is deployed
   - Clear browser cache

2. **Data not displaying**

   - Confirm Apex controller implements IGenericClass
   - Check controller returns correct data structure
   - Verify field paths match returned data
   - Check console for errors

3. **Enum values not mapping**

   - Ensure exact match between data and enum keys
   - Check for case sensitivity
   - Verify isEnum flag is set
   - Review enumMappings structure

4. **Performance issues**

   - Optimize Apex queries
   - Reduce configuration complexity
   - Limit number of sections/fields
   - Check for infinite loops

5. **Styling problems**
   - Verify CSS Static Resource exists
   - Check for CSS conflicts
   - Review SLDS classes
   - Test in different themes

### Debug Mode

Enable debug logging:

```javascript
// In genericRecordDetail.js
connectedCallback() {
    console.log('Controller:', this.ApexController);
    console.log('Config Name:', this.SchemaConfig);
    console.log('Record ID:', this.recordId);
}

// Log configuration
console.log('Loaded Config:', this.configWrapper);

// Log data
console.log('Controller Data:', this.apidata);
```

---

For questions or support, please contact the Salesforce development team.
