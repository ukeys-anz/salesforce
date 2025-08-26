# Generic Record Link Component

A flexible Lightning Web Component for rendering clickable record links in Salesforce, with optional popover details. This component enables dynamic linking to any record and can display a configurable set of fields in a popover, using Apex controllers for data retrieval.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Apex Controller Interface](#apex-controller-interface)
- [Generic Query Controller](#generic-query-controller)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The `genericRecordLink` component displays a record name as a clickable link. On hover, it can show a popover with additional record details, using fields specified by the parent or configuration. Data is fetched via a configurable Apex controller, including support for dynamic queries via the GenericQueryController.

## Features

- **Dynamic Record Linking**: Link to any Salesforce record by ID and object name
- **Popover Details**: Show a popover with configurable fields on hover
- **Apex-Driven Data**: Fetch record details using any Apex controller
- **Generic Query Support**: Use GenericQueryController for dynamic controller/method invocation
- **Flexible Field Display**: Choose which fields to show in the popover
- **Custom Styling**: Support for stacked or inline display

## Architecture

### Component Structure

```
genericRecordLink
├── <a> (Clickable record name)
└── <div.popoverContainer> (Popover with lightning-record-view-form)
```

### Data Flow

1. On component load, fetch record details via Apex controller or GenericQueryController
2. Display record name as link
3. On hover, show popover with specified fields

## Configuration

### Component Properties

| Property         | Type    | Description                                           | Required |
| ---------------- | ------- | ----------------------------------------------------- | -------- |
| `objectName`     | String  | Salesforce object API name                            | Yes      |
| `fields`         | Array   | List of field API names to display in popover         | Yes      |
| `apexController` | String  | Apex controller name for data retrieval               | Yes      |
| `recordName`     | String  | Field name to display as the link text                | Yes      |
| `params`         | Object  | Parameters to pass to Apex controller (e.g. recordId) | Yes      |
| `isStacked`      | Boolean | If true, uses stacked styling for the link            | No       |

## Usage Examples

### Example 1: Basic Record Link

```html
<c-generic-record-link
  object-name="Account"
  fields={["Name", "Industry", "Phone"]}
  apex-controller="AccountQueryController"
  record-name="Name"
  params={ { recordId: "001XXXXXXXXXXXXXXX" } }
></c-generic-record-link>
```

### Example 2: Stacked Link with Custom Fields

```html
<c-generic-record-link
  object-name="Contact"
  fields={["FirstName", "LastName", "Email"]}
  apex-controller="ContactQueryController"
  record-name="FirstName"
  params={ { recordId: "003XXXXXXXXXXXXXXX" } }
  is-stacked={true}
></c-generic-record-link>
```

### Example 3: Used in Related List Config (with GenericQueryController)

```json
{
  "fieldLabel": "Loan Applicant",
  "fieldColumn": "personaId",
  "isRecordLink": true,
  "attributes": {
    "apexController": "GenericQueryController",
    "params": {
      "controller": "LoanApplicantQueryController",
      "method": "getLoanApplicantByPersonaId",
      "args": {
        "personaId": "{personaId}"
      }
    },
    "objectName": "LoanApplicant",
    "recordName": "Name",
    "fields": ["Name", "LoanApplicationId"]
  }
}
```

## API Reference

### Methods

- **navigateToRecord**: Navigates to the record detail page on click
- **handlePopover**: Toggles the popover display on mouseover/mouseout

### Getters

- `recordNameValue`: Returns the display value for the link
- `recordDetailsId`: Returns the record Id for navigation
- `_fieldCompCss`: Returns the CSS class for stacked/inline display

## Apex Controller Interface

The Apex controller must implement a method that returns the record details as a map/object.

```apex
@AuraEnabled
public static Map<String, Object> getData(Map<String, Object> params) {
    // params should include recordId or other identifiers
    // Return a map with field names as keys
}
```

### Example Apex Controller

```apex
public with sharing class AccountQueryController {
  @AuraEnabled
  public static Map<String, Object> getData(Map<String, Object> params) {
    String recordId = (String) params.get('recordId');
    Account acc = [
      SELECT Id, Name, Industry, Phone
      FROM Account
      WHERE Id = :recordId
      LIMIT 1
    ];
    return new Map<String, Object>{
      'Id' => acc.Id,
      'Name' => acc.Name,
      'Industry' => acc.Industry,
      'Phone' => acc.Phone
    };
  }
}
```

## Generic Query Controller

The `GenericQueryController` enables dynamic invocation of any controller and method, making the component highly reusable for different objects and queries.

### Example Usage in Config

```json
{
  "apexController": "GenericQueryController",
  "params": {
    "controller": "AccountQueryController",
    "method": "getAccountByOcvId",
    "args": {
      "ocvId": "{ocvId}"
    }
  },
  "objectName": "Account",
  "recordName": "Name",
  "fields": ["Name", "Industry", "Phone"]
}
```

### Apex Implementation

```apex
public with sharing class GenericQueryController implements IGenericClass {
  public Object getData(String param) {
    // param is a JSON string with controller, method, and args
    // Dynamically instantiate and invoke the specified controller/method
    // Controller must implement Callable
  }
}
```

#### Requirements

- **Target controller must implement the `Callable` interface.**
- The method must accept a map of arguments and return a map/object.

#### Example Target Controller

```apex
public with sharing class AccountQueryController implements Callable {
  public Object call(String methodName, Map<String, Object> args) {
    switch on methodName {
      when 'getAccountByOcvId' {
        return getAccountByOcvId(args);
      }
      when else {
        throw new AuraHandledException('Unknown method: ' + methodName);
      }
    }
  }

  @AuraEnabled
  public static Map<String, Object> getAccountByOcvId(
    Map<String, Object> args
  ) {
    String ocvId = (String) args.get('ocvId');
    Account acc = [
      SELECT Id, Name, Industry, Phone
      FROM Account
      WHERE Ocv__c = :ocvId
      LIMIT 1
    ];
    return new Map<String, Object>{
      'Id' => acc.Id,
      'Name' => acc.Name,
      'Industry' => acc.Industry,
      'Phone' => acc.Phone
    };
  }
}
```

## Best Practices

- Always pass a valid recordId or required identifier in `params`
- Limit the number of fields for popover performance
- Use FLS checks in Apex controllers
- Use meaningful link text for accessibility
- Handle errors gracefully in Apex and JS
- For dynamic queries, ensure target controllers implement `Callable`

## Troubleshooting

- **Link not displaying**: Check that `recordName` matches a field in the returned data
- **Popover not showing**: Ensure `fields` array is correct and record details are returned
