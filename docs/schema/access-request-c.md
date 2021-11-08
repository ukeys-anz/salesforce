---
id: access-request-c
title: Access_Request__c
sidebar_label: Access_Request__c
---
## Sharing 
|Org Wide Default Sharing|
|:-|
|Private|
## Fields 
|Name|Description|Type|Label|Required|Unique|External Id|Confidentiality|Integrity|Privacy|Source|
|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|
|Access_Type\_\_c|The type of access level being requested|Picklist|Access Type|✔|||Confidential|Accurate|Non-Personal Information|Salesforce|
|Approver\_\_c|Auto-calculated approver, based on requesting user and global APM approver in custom settings|Lookup|Approver||||Confidential|Accurate|Non-Personal Information|Salesforce|
|CreatedById|Audit Field: Id of the User who created the record|Lookup(User)|Created By||||Confidential|Accurate|Non-Personal Information|Salesforce|
|CreatedDate|Audit Field: Date and time when this record was created.|Date/Time|Created Date||||Confidential|Accurate|Non-Personal Information|Salesforce|
|Duration_hrs\_\_c|Intended duration for privileged access session in hours|Picklist|Duration (hrs)|✔|||Confidential|Accurate|Non-Personal Information|Salesforce|
|Expected_Start\_\_c|Captures the start date and time of privileged access session (this is to allow users to submit for future access)|DateTime|Expected Start||||Confidential|Accurate|Non-Personal Information|Salesforce|
|Id|Audit Field: Id|Lookup()|Record ID||||Confidential|Accurate|Non-Personal Information|Salesforce|
|LastModifiedById|Audit Field: ID of the User who last updated this record.|Lookup(User)|Last Modified By||||Confidential|Accurate|Non-Personal Information|Salesforce|
|LastModifiedDate|Audit Field: Date and time when a user last modified this record.|Date/Time|Last Modified Date||||Confidential|Accurate|Non-Personal Information|Salesforce|
|Reason\_\_c|Reason for the access request for privileged access|Text|Reason|✔|||Confidential|Accurate|Non-Personal Information|Salesforce|
|Reference_Number\_\_c|Reference Number to a job, Jira story or CR|Text|Reference Number||||Confidential|Accurate|Non-Personal Information|Salesforce|
|Requestor\_\_c|The user to receive privileged access|Lookup|Requestor||||Confidential|Accurate|Non-Personal Information|Salesforce|
|Status\_\_c|The status of the access request|Picklist|Status||||Confidential|Accurate|Non-Personal Information|Salesforce|
|Trace_Id\_\_c|Records a queue trace Id per PAM request which will be used throughout its life cycle for tracking purposes on Application Trace Log big object|Text|Trace Id||||Confidential|Accurate|Non-Personal Information|Salesforce|
|When\_\_c|Captures if the user requires immediate or future access|Picklist|When|✔|||Confidential|Accurate|Non-Personal Information|Salesforce|
## Field Level Security 
|Name|CFMS Integration User|Coach|Content Author|COSMOS Integration User|Deployment User|EDW Integration User|Engineer|IDR Reporting Analyst|IDR Level 1|IDR Level 2|IDR Level 3|IDR Tech Support|MVISION Integration User|Notification Broker Integration User|OCV Integration User|Ops Support|Qualtrics Integration User|Read Only Administrator|Splunk Sec Ops Integration User|System Administrator|Splunk Tech Ops Integration User|Trailblazer|TrailTracker Integration User|User Provisioning|WebdriverIO Integration User|FraudX Agent|Twilio Integration User|Quality Analyst|Sailpoint User|Support Staff AR&C|Support Coach|Super Support Admin|
|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|:-|
|Access_Request\_\_c.Access_Type__c||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.Approver__c|||||||R|||||||||||||RW||||||||||||||
|Access_Request\_\_c.CreatedById||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.CreatedDate||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.Duration_hrs__c||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.Expected_Start__c|||||||RW|||||||||||||RW||||||||||||||
|Access_Request\_\_c.Id||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.LastModifiedById||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.LastModifiedDate||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.Reason__c||||||||||||||||||||||||||||||||||
|Access_Request\_\_c.Reference_Number__c|||||||RW|||||||||||||RW||||||||||||||
|Access_Request\_\_c.Requestor__c|||||||RW|||||||||||||RW||||||||||||||
|Access_Request\_\_c.Status__c|||||||R|||||||||||||RW||||||||||||||
|Access_Request\_\_c.Trace_Id__c||||||||||||||||||||RW||||||||||||||
|Access_Request\_\_c.When__c||||||||||||||||||||||||||||||||||
