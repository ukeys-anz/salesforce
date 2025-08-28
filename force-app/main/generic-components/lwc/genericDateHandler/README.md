# Generic Date Handler Component

A specialized Lightning Web Component for formatting and displaying date/time values with a fixed Australian timezone format. This component provides consistent date formatting across the application.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Component Structure](#component-structure)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Formatting Details](#formatting-details)
- [Limitations](#limitations)
- [Best Practices](#best-practices)
- [Future Enhancements](#future-enhancements)

## Overview

The `genericDateHandler` component is a simple date formatting component that displays dates in a consistent format using the Australia/Sydney timezone. It wraps the standard `lightning-formatted-text` component with custom date formatting logic.

## Features

### Current Capabilities

- **Fixed Timezone** - Always displays in Australia/Sydney timezone
- **Fixed Format** - Uses en-GB locale (DD/MM/YYYY format)
- **Time Display** - Always shows time component
- **Text Formatting** - Leverages lightning-formatted-text for display
- **Attribute Spreading** - Supports additional attributes via lwc:spread

### Key Characteristics

- Lightweight wrapper component
- No configuration options (hardcoded format)
- Consistent date display across the application
- Simple API with two properties

## Component Structure

```
genericDateHandler/
├── genericDateHandler.js          # Component logic with formatting
├── genericDateHandler.html        # Simple template
├── genericDateHandler.js-meta.xml # Component metadata
└── README.md                     # This file
```

### Dependencies

- `genericUtils` - Provides `getCustomformatDateTimeValue` function
- `lightning-formatted-text` - Base display component

## Usage Examples

### Example 1: Basic Date Display

```html
<c-generic-date-handler field="{dateFieldConfig}" value="{dateValue}">
</c-generic-date-handler>
```

```javascript
// Component controller
dateFieldConfig = {
  fieldLabel: "Created Date"
};

dateValue = "2024-01-15T14:30:00Z";

// Output: "15/01/2024, 01:30 AM" (Sydney time)
```

### Example 2: With Additional Attributes

```html
<c-generic-date-handler
  field="{fieldConfig}"
  value="{timestamp}"
  class="custom-date-class"
  data-id="date-field"
>
</c-generic-date-handler>
```

### Example 3: In a Field Container

```javascript
// Used within genericFieldContainer configuration
{
    fieldtype: "date",
    fieldLabel: "Last Modified",
    fieldColumn: "lastModifiedDate",
    isDate: true  // Triggers use of genericDateHandler
}
```

## API Reference

### Properties

| Property | Type        | Description                | Required |
| -------- | ----------- | -------------------------- | -------- |
| `field`  | Object      | Field configuration object | Yes      |
| `value`  | String/Date | Date value to format       | Yes      |

### Field Object Properties

| Property         | Type   | Description               | Used |
| ---------------- | ------ | ------------------------- | ---- |
| `fieldLabel`     | String | Label for the field       | Yes  |
| Other properties | Any    | Passed through via spread | No   |

### Formatting Parameters (Hardcoded)

| Parameter    | Value              | Description                      |
| ------------ | ------------------ | -------------------------------- |
| `dateFormat` | "en-GB"            | British date format (DD/MM/YYYY) |
| `timeZone`   | "Australia/Sydney" | Fixed timezone                   |
| `needTime`   | true               | Always displays time             |

## Formatting Details

### Input Formats Supported

- ISO 8601 strings: `"2024-01-15T14:30:00Z"`
- JavaScript Date objects
- Timestamp milliseconds: `1705329000000`
- Any format parseable by JavaScript Date constructor

### Output Format

- **Pattern**: `DD/MM/YYYY, HH:MM AM/PM`
- **Example**: `"15/01/2024, 01:30 AM"`
- **Timezone**: Always converted to Australia/Sydney

### Formatting Logic

```javascript
// Internal formatting call
formattedValue = getCustomformatDateTimeValue(
  dateValue,
  "en-GB",
  "Australia/Sydney",
  true // needTime
);
```

## Limitations

### Current Limitations

1. **Fixed Timezone** - Cannot display in user's local timezone
2. **Fixed Format** - No configuration for date/time format
3. **Always Shows Time** - Cannot display date-only
4. **No Localization** - Fixed to en-GB locale
5. **No Error Handling** - Invalid dates may cause issues
6. **No Null Handling** - Undefined behavior for null values

### Design Constraints

- Designed specifically for Australian market
- Assumes all users need Sydney timezone
- No internationalization support
- No customization options

## Best Practices

### 1. Usage Guidelines

- Use only when Australia/Sydney timezone is required
- Ensure date values are valid before passing
- Consider user timezone requirements
- Document timezone assumptions

### 2. Data Validation

```javascript
// Validate before using
if (dateValue && !isNaN(Date.parse(dateValue))) {
  // Safe to use with genericDateHandler
}
```

### 3. Error Prevention

```javascript
// Provide fallback for invalid dates
get safeDataValue() {
    try {
        return new Date(this.rawDate).toISOString();
    } catch (e) {
        return null;  // Handle gracefully
    }
}
```

### 4. Alternative Approaches

For more flexible date handling:

```html
<!-- Use lightning-formatted-date-time directly -->
<lightning-formatted-date-time
  value="{dateValue}"
  year="numeric"
  month="short"
  day="2-digit"
  hour="2-digit"
  minute="2-digit"
  time-zone="America/New_York"
>
</lightning-formatted-date-time>
```

## Future Enhancements

### Recommended Improvements

1. **Configurable Timezone**

   ```javascript
   @api timezone = 'Australia/Sydney';  // Make configurable
   ```

2. **Configurable Format**

   ```javascript
   @api dateFormat = 'en-GB';  // Allow different locales
   @api showTime = true;        // Toggle time display
   ```

3. **Error Handling**

   ```javascript
   get formattedValue() {
       try {
           return this.formatDate(this.value);
       } catch (error) {
           console.error('Date formatting error:', error);
           return 'Invalid Date';
       }
   }
   ```

4. **Null Value Support**

   ```javascript
   if (!this.value) {
     return this.emptyDateLabel || "--";
   }
   ```

5. **Relative Time Option**
   ```javascript
   @api useRelativeTime = false;  // "2 hours ago"
   ```

### Migration Path

To make the component more flexible:

```javascript
// Enhanced version
export default class GenericDateHandler extends LightningElement {
  @api field;
  @api value;
  @api timezone = "Australia/Sydney";
  @api locale = "en-GB";
  @api showTime = true;
  @api emptyLabel = "--";
  @api useRelativeTime = false;

  get formattedValue() {
    if (!this.value) return this.emptyLabel;

    try {
      if (this.useRelativeTime) {
        return this.getRelativeTime(this.value);
      }
      return getCustomformatDateTimeValue(
        this.value,
        this.locale,
        this.timezone,
        this.showTime
      );
    } catch (error) {
      console.error("Date formatting error:", error);
      return this.emptyLabel;
    }
  }
}
```

## Common Use Cases

### Display Created/Modified Dates

```javascript
{
    fieldtype: "date",
    fieldLabel: "Created",
    fieldColumn: "createdDate",
    isDate: true
}
```

### Show Business Hours

Since it's fixed to Sydney timezone, useful for showing Australian business hours regardless of user location.

### Audit Timestamps

Consistent timezone for audit trails and compliance requirements.

## Testing Considerations

### Test Scenarios

1. Valid ISO date strings
2. JavaScript Date objects
3. Invalid date values
4. Null/undefined values
5. Different times of day
6. Daylight saving transitions

### Example Test Data

```javascript
const testDates = [
  "2024-01-15T14:30:00Z", // UTC time
  "2024-06-15T14:30:00Z", // Different season
  new Date(), // Current date
  "Invalid Date String", // Error case
  null, // Null case
  undefined // Undefined case
];
```

---

For questions or support, please contact the Salesforce development team.
