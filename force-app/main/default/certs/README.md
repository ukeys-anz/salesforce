# **Certificates**


 - For salesforce integrations with mulesoft to work we need to do the following

 ##### For egress from Salesforce to Mulesoft

 ![egress](../../../../misc/readme-images/egress.png)

 1. From setup go to Certificate and Key Management.

 2. Click on Import from keystore in Certificate section and choose file found in misc folder in this repository(sfglobaltestks.jks) and in keystore password use **salesforce** 

 3. From setup go to Named Credentials and select edit Action on Mulesoft.

 4. In Authentication Section in Certificate choose sfglobaltestks.

 5. In JWT Signing Certificate from the dropdown choose sfglobaltestks.

##### For ingress into Salesforce from Mulesoft

 ![ingress](../../../../misc/readme-images/ingress.png)
Yet to be documented waiting on salesforce [case-27120116](https://help.salesforce.com/mysuccesshub?id=supportCases&caseId=5003y00000t1dRJAAY) to enable mtls in scratch orgs using snapshots. 
