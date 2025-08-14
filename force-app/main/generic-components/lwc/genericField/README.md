# Generic Field Component

A versatile Lightning Web Component that dynamically renders different field types based on configuration. This component provides a unified way to display various data types with consistent styling and behavior.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Field Types](#field-types)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Layout Options](#layout-options)
- [Navigation](#navigation)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The `genericField` component is a flexible field renderer that can display various data types including text, numbers, dates, emails, URLs, and record links. It provides a consistent interface for rendering fields with labels, help text, and configurable layouts, making it ideal for building dynamic forms and data displays.

## Features

### Field Type Support

- **Text Fields** - Plain text display with formatting
- **Number Fields** - Numeric values with locale formatting
- **Email Fields** - Clickable email addresses
- **URL Fields** - Clickable web links
- **Date Fields** - Date/time display with custom formatting
- **Checkbox Fields** - Boolean values as checkboxes
- **Record Links** - Navigate to Salesforce records
- **Custom Navigation** - Navigate to custom components

### Display Options

- **Label Display** - Configurable field labels
- **Help Text** - Tooltip help for fields
- **Stacked Layout** - Vertical label/value arrangement
- **Grid Layout** - Responsive column-based layout
- **JSON Stringify** - Display objects as formatted JSON

### Advanced Features

- **Dynamic Rendering** - Field type determined at runtime
- **Navigation Support** - Built-in navigation capabilities
- **Error Handling** - Graceful error display
- **Responsive Design** - Adapts to container width
- **Parent Communication** - Error event propagation

## Component Structure

```
genericField/
├── genericField.js          # Main component logic
├── genericField.html        # Component template
├── genericField.css         # Component styles
├── genericField.js-meta.xml # Component metadata
└── README.md               # This file
```

### Dependencies

- `c-generic-date-handler` - Custom date formatting
- `c-generic-record-link` - Record link display
- `lightning-formatted-*` - SLDS formatted components
- `NavigationMixin` - Salesforce navigation

## Field Types

### Supported Field Types

| Type         | Component Used               | Description                    |
| ------------ | ---------------------------- | ------------------------------ |
| `number`     | `lightning-formatted-number` | Numeric values with formatting |
| `email`      | `lightning-formatted-email`  | Email with mailto link         |
| `url`        | `lightning-formatted-url`    | Clickable web links            |
| `date`       | `c-generic-date-handler`     | Custom date/time display       |
| `text`       | `lightning-formatted-text`   | Plain text                     |
| `checkbox`   | `lightning-input`            | Boolean checkbox               |
| `recordLink` | `c-generic-record-link`      | Salesforce record link         |
| `recordUrl`  | `lightning-button`           | Navigation button              |

### Field Type Examples

#### Number Field

```javascript
{
    fieldtype: 'number',
    fieldLabel: 'Amount',
    fieldColumn: 'amount',
    attributes: {
        formatStyle: 'currency',
        currencyCode: 'USD'
    }
}
```

#### Date Field

```javascript
{
    fieldtype: 'date',
    fieldLabel: 'Created Date',
    fieldColumn: 'createdDate',
    isDate: true,
    attributes: {
        year: 'numeric',
        month: 'long',
        day: '2-digit'
    }
}
```

#### Record URL Field

```javascript
{
    fieldtype: 'recordUrl',
    fieldLabel: 'View Details',
    fieldColumn: 'recordId',
    isRecordUrl: true,
    attributes: {
        navigationConfig: {
            componentName: 'c__customDetailView',
            apexController: 'DetailViewController'
        }
    }
}
```

## Configuration

### Field Configuration Object

```javascript
{
    fieldtype: 'text',              // Required: Field type
    fieldLabel: 'Field Label',      // Required: Display label
    fieldColumn: 'fieldName',       // Required: Data field name
    helpText: 'Helpful tooltip',    // Optional: Help text
    isStacked: false,              // Optional: Stack label/value
    isDate: false,                 // Optional: Date field flag
    isRecordLink: false,           // Optional: Record link flag
    isRecordUrl: false,            // Optional: Navigation flag
    stringify: false,              // Optional: JSON stringify
    attributes: {                  // Optional: Type-specific attributes
        // Additional configuration
    }
}
```

### Type-Specific Attributes

#### Number Attributes

```javascript
attributes: {
    formatStyle: 'decimal|currency|percent',
    currencyCode: 'USD',
    currencyDisplayAs: 'symbol|code|name',
    minimumIntegerDigits: 1,
    minimumFractionDigits: 0,
    maximumFractionDigits: 2
}
```

#### URL Attributes

```javascript
attributes: {
    target: '_blank|_self|_parent|_top',
    tooltip: 'Link tooltip text'
}
```

#### Date Attributes

```javascript
attributes: {
    year: 'numeric|2-digit',
    month: 'numeric|2-digit|long|short',
    day: 'numeric|2-digit',
    hour: 'numeric|2-digit',
    minute: 'numeric|2-digit',
    second: 'numeric|2-digit',
    timeZone: 'UTC|America/New_York'
}
```

## Usage Examples

### Example 1: Simple Text Field

```html
<c-generic-field field="{textFieldConfig}" value="Sample Text">
</c-generic-field>
```

```javascript
textFieldConfig = {
  fieldtype: "text",
  fieldLabel: "Description",
  fieldColumn: "description"
};
```

### Example 2: Currency Field with Help Text

```html
<c-generic-field field="{currencyFieldConfig}" value="1234.56">
</c-generic-field>
```

```javascript
currencyFieldConfig = {
  fieldtype: "number",
  fieldLabel: "Total Amount",
  fieldColumn: "totalAmount",
  helpText: "Total amount including tax",
  attributes: {
    formatStyle: "currency",
    currencyCode: "EUR"
  }
};
```

### Example 3: Stacked Date Field

```html
<c-generic-field
  field="{dateFieldConfig}"
  value="2024-01-15T10:30:00Z"
  padding-size="12"
>
</c-generic-field>
```

```javascript
dateFieldConfig = {
  fieldtype: "date",
  fieldLabel: "Due Date",
  fieldColumn: "dueDate",
  isDate: true,
  isStacked: true,
  attributes: {
    year: "numeric",
    month: "short",
    day: "2-digit"
  }
};
```

### Example 4: Record Navigation Field

```html
<c-generic-field
  field="{navigationFieldConfig}"
  value="View Full Details"
  record-id="{recordId}"
>
</c-generic-field>
```

```javascript
navigationFieldConfig = {
  fieldtype: "recordUrl",
  fieldLabel: "Actions",
  fieldColumn: "navigate",
  isRecordUrl: true,
  attributes: {
    navigationConfig: {
      componentName: "c__detailView",
      apexController: "DetailController",
      configName: "detailConfig",
      filterValue: "active"
    }
  }
};
```

## API Reference

### Properties

| Property      | Type   | Description                | Required |
| ------------- | ------ | -------------------------- | -------- |
| `field`       | Object | Field configuration object | Yes      |
| `value`       | Any    | Field value to display     | Yes      |
| `recordId`    | String | Record ID for navigation   | No       |
| `paddingSize` | String | Grid column size (1-12)    | No       |

### Field Configuration Properties

| Property       | Type    | Description              | Default |
| -------------- | ------- | ------------------------ | ------- |
| `fieldtype`    | String  | Type of field to render  | -       |
| `fieldLabel`   | String  | Display label            | -       |
| `fieldColumn`  | String  | Data field identifier    | -       |
| `helpText`     | String  | Tooltip help text        | -       |
| `isStacked`    | Boolean | Use stacked layout       | false   |
| `isDate`       | Boolean | Is date field            | false   |
| `isRecordLink` | Boolean | Is record link           | false   |
| `isRecordUrl`  | Boolean | Is navigation URL        | false   |
| `stringify`    | Boolean | JSON stringify value     | false   |
| `attributes`   | Object  | Type-specific attributes | {}      |

### Events

| Event   | Description                | Detail                |
| ------- | -------------------------- | --------------------- |
| `error` | Fired when an error occurs | `{ message: String }` |

## Layout Options

### Grid Layout (Default)

- Label takes 2 columns (or custom via `paddingSize`)
- Value takes remaining columns
- Responsive to container width

```html
<!-- Standard 2-10 layout -->
<c-generic-field field="{config}" value="{data}"></c-generic-field>

<!-- Custom 4-8 layout -->
<c-generic-field
  field="{config}"
  value="{data}"
  padding-size="4"
></c-generic-field>
```

### Stacked Layout

- Label takes full width (12 columns)
- Value takes full width (12 columns)
- Vertical arrangement

```javascript
{
    fieldtype: 'text',
    fieldLabel: 'Long Description',
    fieldColumn: 'description',
    isStacked: true
}
```

## Navigation

### Record URL Navigation

The component supports navigation to custom components with parameters:

```javascript
{
    fieldtype: 'recordUrl',
    fieldLabel: 'View Details',
    isRecordUrl: true,
    attributes: {
        navigationConfig: {
            componentName: 'c__myComponent',    // Target component
            apexController: 'MyController',     // Controller to use
            configName: 'myConfig',            // Configuration name
            filterValue: 'active',             // Filter value
            dataPath: 'data.items',           // Data path
            controllerParams: 'id,type'       // Controller parameters
        }
    }
}
```

### Navigation URL Structure

```
/component/c__myComponent?c__recordId=XXX&c__apexController=MyController&...
```

## Best Practices

### 1. Field Configuration

- Always provide meaningful labels
- Use appropriate field types for data
- Include help text for complex fields
- Validate configuration before use

### 2. Performance

- Reuse field configurations when possible
- Avoid complex computations in attributes
- Use efficient data binding

### 3. User Experience

- Keep labels concise and clear
- Use stacked layout for long values
- Provide tooltips for abbreviations
- Ensure consistent field ordering

### 4. Error Handling

- Handle null/undefined values gracefully
- Provide fallback displays
- Log errors appropriately
- Test edge cases

### 5. Accessibility

- Always include field labels
- Use semantic HTML elements
- Provide meaningful help text
- Test with screen readers

## Common Patterns

### Conditional Field Display

```javascript
get fieldConfig() {
    return {
        fieldtype: this.isEditable ? 'text' : 'lightning-formatted-text',
        fieldLabel: 'Status',
        fieldColumn: 'status'
    };
}
```

### Dynamic Attributes

```javascript
get currencyConfig() {
    return {
        fieldtype: 'number',
        fieldLabel: 'Price',
        attributes: {
            formatStyle: 'currency',
            currencyCode: this.userCurrency
        }
    };
}
```

### Field Array Rendering

```html
<template for:each="{fields}" for:item="field">
  <c-generic-field
    key="{field.fieldColumn}"
    field="{field}"
    value="{field.value}"
  >
  </c-generic-field>
</template>
```

## Troubleshooting

### Common Issues

1. **Field not displaying**
   - Verify field configuration object
   - Check value is not null/undefined
   - Ensure fieldtype is supported
   - Check console for errors

2. **Label not showing**
   - Confirm fieldLabel is provided
   - Check for CSS conflicts
   - Verify layout configuration

3. **Navigation not working**
   - Ensure navigationConfig is complete
   - Check component permissions
   - Verify target component exists
   - Test URL generation

4. **Layout issues**
   - Review paddingSize values
   - Check isStacked setting
   - Verify container width
   - Test responsive behavior

5. **Date formatting problems**
   - Confirm isDate flag is set
   - Check date value format
   - Verify attributes configuration
   - Test timezone handling

### Debug Tips

1. **Enable Debug Mode**

   ```javascript
   console.log("Field Config:", this.field);
   console.log("Field Value:", this.value);
   ```

2. **Check Computed Properties**
   - Verify paddingLabel calculation
   - Check paddingValue calculation
   - Test showError condition

3. **Monitor Events**
   - Listen for error events in parent
   - Log navigation attempts
   - Track field rendering

---

For questions or support, please contact the Salesforce development team.
