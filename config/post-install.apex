//Reset the default admin user password because Scratch orgs don't supply password to be able to login directly
User u = [SELECT id FROM User WHERE firstName='User' AND IsActive=true AND Profile.Name='System Administrator' limit 1];
System.resetPassword (u.Id, true);


//Enable Person Account in FSC as per https://developer.salesforce.com/docs/atlas.en-us.financial_services_cloud_admin_guide.meta/financial_services_cloud_admin_guide/fsc_admin_enable_person_acct.htm
//Insert record in Custom Setting
    FinServ__UsePersonAccount__c usePersonAccount = new FinServ__UsePersonAccount__c();
    usePersonAccount.Name = 'Use Person Account';
    usePersonAccount.FinServ__Enable__c = true;
    insert usePersonAccount;

//Set Up Lead Conversion and Referral Management for Person Accounts as per the above page..
    FinServ__B2CLeadCompanyNameConfig__c forAdmin = [SELECT FinServ__OverrideCompanyName__c FROM FinServ__B2CLeadCompanyNameConfig__c LIMIT 1];
    forAdmin.FinServ__OverrideCompanyName__c = false;
    update forAdmin;