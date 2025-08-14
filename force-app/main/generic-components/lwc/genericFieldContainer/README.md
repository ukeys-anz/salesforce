# Generic Field Container Component

A flexible Lightning Web Component that renders collections of fields in configurable layouts. This component serves as a container for multiple `genericField` components, supporting both single objects and arrays with accordion-style sections.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Data Processing](#data-processing)
- [API Reference](#api-reference)
- [Layout Options](#layout-options)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The `genericFieldContainer` component is designed to display structured data with flexible field layouts. It processes configuration schemas to dynamically render fields, supporting nested data structures, date formatting, and dynamic parameter resolution for record links.

## Features

### Core Capabilities

- **Dynamic Field Rendering** - Renders fields based on configurable schemas
- **Array Support** - Displays single objects or arrays of objects
- **Accordion Sections** - Collapsible sections for array data
- **Nested Data Access** - Supports dot notation for nested properties
- **Dynamic Parameters** - Resolves placeholders in record link configurations

### Display Features

- **Flexible Layouts** - SLDS grid-based responsive layouts
- **Section Headers** - Optional accordion-style headers
- **Error Handling** - Graceful error display with event propagation
- **Date Formatting** - Special handling for protobuf timestamps
- **Boolean Display** - Automatic boolean-to-string conversion

### Configuration Options

- **Schema-Driven** - JSON-based field definitions
- **Layout Customization** - Configurable grid properties
- **Padding Overrides** - Custom padding sizes per field
- **Field Attributes** - Pass-through attributes to child fields

## Component Structure

```
genericFieldContainer/
├── genericFieldContainer.js          # Main component logic
├── genericFieldContainer.html        # Component template
├── genericFieldContainer.css         # Component styles (minimal)
├── genericFieldContainer.js-meta.xml # Component metadata
└── README.md                        # This file
```

### Dependencies

- `c-generic-field` - Child component for individual field rendering
- `c-error` - Error display component
- Lightning base components (accordion, layout)

## Configuration

### Configuration Object Structure

```javascript
{
  title: "Section Title",
  layoutconfig: {
    layout: {
      horizontalAlign: "spread",
      verticalAlign: "start",
      pullToBoundary: "medium"
    },
    layoutitem: {
      flexibility: "auto",
      padding: "around-small",
      size: "6"
    },
    paddingSizeOverride: "4"  // Optional: Override for specific fields
  },
  schema: [
    {
      fieldColumn: "fieldName",
      fieldLabel: "Field Label",
      fieldtype: "text",
      isDate: false,
      isRecordLink: false,
      attributes: {
        // Field-specific attributes
      }
    }
  ]
}
```

### Schema Properties

| Property       | Type    | Description                             | Required |
| -------------- | ------- | --------------------------------------- | -------- |
| `fieldColumn`  | String  | Data field path (supports dot notation) | Yes      |
| `fieldLabel`   | String  | Display label                           | Yes      |
| `fieldtype`    | String  | Field type for rendering                | Yes      |
| `isDate`       | Boolean | Date field flag                         | No       |
| `isRecordLink` | Boolean | Record link field flag                  | No       |
| `attributes`   | Object  | Additional field attributes             | No       |

### Layout Configuration

The `layoutconfig` object controls the visual arrangement:

```javascript
layoutconfig: {
  layout: {
    horizontalAlign: "spread|center|space|stretch|end",
    verticalAlign: "start|center|end|stretch",
    pullToBoundary: "small|medium|large"
  },
  layoutitem: {
    flexibility: "auto|grow|shrink|no-grow|no-shrink",
    padding: "around-small|around-medium|around-large",
    size: "1-12"  // Grid columns
  }
}
```

## Usage Examples

### Example 1: Single Object Display

```html
<c-generic-field-container
  value="{accountData}"
  object-config="{accountConfig}"
  record-id="{recordId}"
>
</c-generic-field-container>
```

```javascript
accountConfig = {
  title: "Account Information",
  layoutconfig: {
    layout: {
      horizontalAlign: "spread"
    },
    layoutitem: {
      size: "6",
      padding: "around-small"
    }
  },
  schema: [
    {
      fieldColumn: "name",
      fieldLabel: "Account Name",
      fieldtype: "text"
    },
    {
      fieldColumn: "industry",
      fieldLabel: "Industry",
      fieldtype: "text"
    },
    {
      fieldColumn: "annualRevenue",
      fieldLabel: "Annual Revenue",
      fieldtype: "number",
      attributes: {
        formatStyle: "currency",
        currencyCode: "USD"
      }
    }
  ]
};

accountData = {
  name: "Acme Corporation",
  industry: "Technology",
  annualRevenue: 1000000
};
```

### Example 2: Array Display with Accordions

```html
<c-generic-field-container
  value="{contactsList}"
  object-config="{contactsConfig}"
  has-section-header="true"
>
</c-generic-field-container>
```

```javascript
contactsConfig = {
  title: "Related Contacts",
  schema: [
    {
      fieldColumn: "fullName",
      fieldLabel: "Name",
      fieldtype: "text"
    },
    {
      fieldColumn: "email",
      fieldLabel: "Email",
      fieldtype: "email"
    },
    {
      fieldColumn: "phone",
      fieldLabel: "Phone",
      fieldtype: "phone"
    }
  ]
};

contactsList = [
  {
    fullName: "John Smith",
    email: "john@example.com",
    phone: "+1-555-0123"
  },
  {
    fullName: "Jane Doe",
    email: "jane@example.com",
    phone: "+1-555-0124"
  }
];
```

### Example 3: Nested Data with Dynamic Parameters

```html
<c-generic-field-container
  value="{orderData}"
  object-config="{orderConfig}"
  record-id="{recordId}"
>
</c-generic-field-container>
```

```javascript
orderConfig = {
  title: "Order Details",
  schema: [
    {
      fieldColumn: "orderNumber",
      fieldLabel: "Order #",
      fieldtype: "text"
    },
    {
      fieldColumn: "customer.name",
      fieldLabel: "Customer",
      fieldtype: "text",
      isRecordLink: true,
      attributes: {
        params: {
          args: {
            customerId: "{customer.id}", // Dynamic resolution
            orderDate: "{orderDate}"
          }
        }
      }
    },
    {
      fieldColumn: "items[0].productName",
      fieldLabel: "First Product",
      fieldtype: "text"
    }
  ]
};

orderData = {
  orderNumber: "ORD-001",
  customer: {
    id: "001234567890ABC",
    name: "Acme Corp"
  },
  orderDate: "2024-01-15",
  items: [
    { productName: "Widget A", quantity: 5 },
    { productName: "Widget B", quantity: 3 }
  ]
};
```

## Data Processing

### Nested Property Access

The component supports dot notation for accessing nested properties:

```javascript
// Configuration
{
  fieldColumn: "address.city";
}

// Data
{
  address: {
    city: "New York";
  }
}

// Result: "New York"
```

### Array Index Access

Access specific array elements using bracket notation:

```javascript
// Configuration
{
  fieldColumn: "contacts[0].name";
}

// Data
{
  contacts: [{ name: "John" }, { name: "Jane" }];
}

// Result: "John"
```

### Dynamic Parameter Resolution

For record links, parameters can reference other fields:

```javascript
{
  fieldColumn: "name",
  isRecordLink: true,
  attributes: {
    params: {
      args: {
        // {userId} will be replaced with actual value
        userId: "{assignedTo.id}",
        // Static values also supported
        view: "detail"
      }
    }
  }
}
```

### Date Handling

Special processing for protobuf timestamp format:

```javascript
// Input
{
  createdDate: {
    seconds: 1642262400,
    nanos: 500000000
  }
}

// Processed to JavaScript Date
new Date(1642262400000 + 500)
```

## API Reference

### Properties

| Property           | Type         | Description                    | Required |
| ------------------ | ------------ | ------------------------------ | -------- |
| `value`            | Object/Array | Data to display                | Yes      |
| `objectConfig`     | Object       | Field schema and layout config | Yes      |
| `hasSectionHeader` | Boolean      | Enable accordion for arrays    | No       |
| `recordId`         | String       | Parent record ID for context   | No       |

### Events

| Event        | Description                      | Detail        |
| ------------ | -------------------------------- | ------------- |
| `childerror` | Propagated from child components | Error details |

### Methods

The component handles all data processing internally. No public methods are exposed.

## Layout Options

### Standard Grid Layout

Fields are arranged in a responsive grid:

```javascript
layoutconfig: {
  layout: {
    horizontalAlign: "spread"
  },
  layoutitem: {
    size: "6",  // 2 columns on desktop
    padding: "around-small"
  }
}
```

### Single Column Layout

For forms or mobile views:

```javascript
layoutconfig: {
  layoutitem: {
    size: "12",  // Full width
    padding: "around-medium"
  }
}
```

### Custom Field Sizing

Override individual field sizes:

```javascript
schema: [
  {
    fieldColumn: "shortField",
    fieldLabel: "ID",
    fieldtype: "text",
    // This field uses custom sizing
    paddingSizeOverride: "3"
  },
  {
    fieldColumn: "longField",
    fieldLabel: "Description",
    fieldtype: "text"
    // Uses default from layoutconfig
  }
];
```

## Best Practices

### 1. Configuration Management

- Keep configurations in separate files for reusability
- Use consistent naming conventions for field columns
- Document complex nested paths
- Version control configuration changes

### 2. Performance

- Limit the number of fields per section
- Use pagination for large arrays
- Avoid deeply nested property access
- Cache processed data when possible

### 3. User Experience

- Group related fields logically
- Use meaningful field labels
- Provide appropriate field types
- Consider mobile responsiveness

### 4. Error Handling

- Validate data structure matches schema
- Handle null/undefined gracefully
- Provide fallback values
- Test with edge cases

### 5. Maintenance

- Document custom configurations
- Use TypeScript interfaces for configs
- Create configuration validators
- Maintain consistent patterns

## Troubleshooting

### Common Issues

1. **Fields not displaying**
   - Check fieldColumn paths match data structure
   - Verify data is not null/undefined
   - Ensure schema is properly formatted
   - Check console for errors

2. **Layout issues**
   - Review layoutconfig settings
   - Check for CSS conflicts
   - Verify size values (1-12)
   - Test responsive behavior

3. **Dynamic parameters not resolving**
   - Confirm parameter paths are correct
   - Check for typos in placeholder syntax
   - Verify referenced fields exist
   - Test with console logging

4. **Accordion not working**
   - Ensure hasSectionHeader is true
   - Verify value is an array
   - Check for unique keys
   - Review console errors

5. **Date formatting issues**
   - Set isDate flag to true
   - Check date value format
   - Verify timezone handling
   - Test with different dates

### Debug Tips

```javascript
// Enable debug logging
connectedCallback() {
    console.log('Config:', this.objectConfig);
    console.log('Data:', this.value);
}

// Log processed data
console.log('Parsed Data:', this._parsedData);

// Check field resolution
console.log('Field Value:', this.getFieldValue(data, 'nested.path'));
```

---

For questions or support, please contact the Salesforce development team.
