# Service classes
Service classes should exist for each given API service, and contain all API callouts. For example, we have a service for Fabric, and if we added another system, Twilio for example, we may have a TwilioService that contains all Twilio API callouts. The Service classes themselves should not be called by consuming classes/code, but via a Repository class to allow proper error handling/logging and mock injection.

## Base class features
- Wrap responses in a wrapper class HttpCalloutResponse, with an easily accessible boolean for success/fail
- Common HTTP headers, for mulesoft and fabric, being set on each callout
- Common interface to support mock injection

## Mocking & Service Provider
- Service classes are loaded via a Service Provider, which can swap out a service for its mock implementation, if in an Apex testing context, or if a custom setting flag indicating a scratch org is being used (NON_PROD_SETTINGS.MockCallouts__c). The mock class loaded is simply, the original service class name, with the word "Mock" appended to it. For example, for a FabricService class, if in an Apex test, the FabricServiceMock class is attempted to be loaded.
