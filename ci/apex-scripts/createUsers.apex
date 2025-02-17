// Define default email
String email = 'anzx-salesforce@anz.com';

// Define user data
String userDataJSON =
  '[' +
  // Aegis test users
  // '{"FirstName":"Test","LastName":"Aegis FraudX Agent 1","Username":"_aegis.fraudxagent.1","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"aegis_user5@anznp.com","PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Aegis FraudX Agent 2","Username":"_aegis.fraudxagent.2","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"aegis_user2@anznp.com","PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Aegis FraudX Agent 3","Username":"_aegis.fraudxagent.3","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"aegis_user3@anznp.com","PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Aegis FraudX Agent 4","Username":"_aegis.fraudxagent.4","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"aegis_user4@anznp.com","PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Aegis Join Operations Reader 1","Username":"_aegis.joinoperationsreader.1","UserRole":"Join_Operations_Reader","Profile":"ANZx Standard User","FederationId":"aegias_user1@anznp.com","PermissionSetGroups":["Join_Operations_Reader"]},' +
  // '{"FirstName":"Test","LastName":"Aegis Support Coach 1","Username":"_aegis.supportcoach.1","UserRole":"Support_Coach","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"aegis_user6@anznp.com","PermissionSetGroups":["Support_Coach"]}' +
  // ANZx automation test users
  // '{"FirstName":"Test","LastName":"Automation BOH Coach","Username":"_automation.bohcoach","UserRole":"BOH_Coach","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["BOH_Coach"]},' +
  // '{"FirstName":"Test","LastName":"Automation Business Admin","Username":"_automation.businessadmin","UserRole":"Business_Admin","Profile":"ANZx Standard Automation User","KnowledgeUser":true,"PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Business_Admin"]},' +
  // '{"FirstName":"Test","LastName":"Automation Coach","Username":"_automation.coach","UserRole":"Coach","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"Automation Coach Lead","Username":"_automation.coachlead","UserRole":"Coach_Lead","Profile":"ANZx Standard Automation User","KnowledgeUser":true,"PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Coach_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Automation Content Writer","Username":"_automation.contentwriter","UserRole":"Content_Writer","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Content_Author_PSG"]},' +
  // '{"FirstName":"Test","LastName":"Automation FinCrime Agent","Username":"_automation.fincrimeagent","UserRole":"FinCrime_Agent","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["FinCrime_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Automation FraudX Agent","Username":"_automation.fraudxagent","UserRole":"FraudX_Agent","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Automation Join Lead","Username":"_automation.joinlead","UserRole":"Join_Lead","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["FraudX_Agent","Join_Lead","Quality_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"Automation Quality Analyst","Username":"_automation.qualityanalyst","UserRole":"Quality_Analyst","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Quality_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"Automation Qualtrics Integration","Username":"_automation.qualtricsintegration","UserRole":"ANZx","Profile":"ANZx Standard Automation User","PermissionSets":["ActionPlans","Backup_and_Restore","BoH_Read_Write","Broker_Details_Integration","Bypass_TSP","Case_Read_Write_KYC_QA_Integration","Case_Read_Write_All","Case_Read_Write_Customer_Onboarding_Integration","Case_Read_Write_Qualtrics_Integration","Coach_Nudge_Integration","Customer_Feedback_Read_Write","Customer_Onboarding_Integration","FinancialServicesCloudExtension","Interaction_Read_Write","Lead_Read_Write","Lead_Read_Write_Qualtrics_Integration","Loan_app_Integration","Mortgage","Password_Never_Expires","PEGA_Integration","Qualtrics_Admin","Read_Only_Admin","Read_Write_Customer_Details","Settlements_Read_Write","SFDX_Deploy","SFDX_Full_Dev_Hub_Access","Streaming_Monitor"]},' +
  // '{"FirstName":"Test","LastName":"Automation Residential Broker Manager","Username":"_automation.residentialbrokermanager","UserRole":"Residential_Broker_Manager","Profile":"ANZx Standard User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Residential_Broker_Manager"]},' +
  // '{"FirstName":"Test","LastName":"Automation Support Coach","Username":"_automation.supportcoach","UserRole":"Support_Coach","Profile":"ANZx Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["Support_Coach"]}' +
  // ANZx manual test users
  // '{"FirstName":"Test","LastName":"3rd Party Mobile Support Team 1","Username":"_3rdpartymobilesupportteam.1","UserRole":"X3rd_Party_Mobile_Support_Team","Profile":"ANZx Standard User","PermissionSetGroups":["Third_Party_Mobile_Support_Team"]},' +
  // '{"FirstName":"Test","LastName":"3rd Party Mobile Support Team 2","Username":"_3rdpartymobilesupportteam.2","UserRole":"X3rd_Party_Mobile_Support_Team","Profile":"ANZx Standard User","PermissionSetGroups":["Third_Party_Mobile_Support_Team"]},' +
  // '{"FirstName":"Test","LastName":"ANZ Plus Operations - Read Only 1","Username":"_anzplusoperationsreadonly.1","UserRole":"ANZ_Plus_Operations_Read_Only","Profile":"ANZx Standard User","PermissionSetGroups":["ANZ_Plus_Operations_Read_Only"]},' +
  // '{"FirstName":"Test","LastName":"ANZ Plus Operations - Read Only 2","Username":"_anzplusoperationsreadonly.2","UserRole":"ANZ_Plus_Operations_Read_Only","Profile":"ANZx Standard User","PermissionSetGroups":["ANZ_Plus_Operations_Read_Only"]},' +
  // '{"FirstName":"Test","LastName":"BOH Coach 1","Username":"_bohcoach.1","UserRole":"BOH_Coach","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["BOH_Coach"]},' +
  // '{"FirstName":"Test","LastName":"BOH Coach 2","Username":"_bohcoach.2","UserRole":"BOH_Coach","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["BOH_Coach"]},' +
  // '{"FirstName":"Test","LastName":"Business Admin 1","Username":"_businessadmin.1","UserRole":"Business_Admin","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"PermissionSetGroups":["Business_Admin"]},' +
  // '{"FirstName":"Test","LastName":"Business Admin 2","Username":"_businessadmin.2","UserRole":"Business_Admin","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"PermissionSetGroups":["Business_Admin"]},' +
  // '{"FirstName":"Test","LastName":"Card Dispute Agent 1","Username":"_carddisputeagent.1","UserRole":"Card_Dispute_Agent","Profile":"ANZx Standard User","PermissionSetGroups":["Card_Dispute_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Card Dispute Agent 2","Username":"_carddisputeagent.2","UserRole":"Card_Dispute_Agent","Profile":"ANZx Standard User","PermissionSetGroups":["Card_Dispute_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Coach 1","Username":"_coach.1","UserRole":"Coach","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"Coach 2","Username":"_coach.2","UserRole":"Coach","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"Coach Lead 1","Username":"_coachlead.1","UserRole":"Coach_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"PermissionSetGroups":["Coach_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Coach Lead 2","Username":"_coachlead.2","UserRole":"Coach_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"PermissionSetGroups":["Coach_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Content Viewer 1","Username":"_contentviewer.1","UserRole":"Content_Viewer","Profile":"ANZx Standard User","PermissionSetGroups":["Content_Viewer"]},' +
  // '{"FirstName":"Test","LastName":"Content Viewer 2","Username":"_contentviewer.2","UserRole":"Content_Viewer","Profile":"ANZx Standard User","PermissionSetGroups":["Content_Viewer"]},' +
  // '{"FirstName":"Test","LastName":"Content Writer 1","Username":"_contentwriter.1","UserRole":"Content_Writer","Profile":"ANZx Standard User","PermissionSetGroups":["Content_Author_PSG"]},' +
  // '{"FirstName":"Test","LastName":"Content Writer 2","Username":"_contentwriter.2","UserRole":"Content_Writer","Profile":"ANZx Standard User","PermissionSetGroups":["Content_Author_PSG"]},' +
  // '{"FirstName":"Test","LastName":"Credit Assessment Officer 1","Username":"_creditassessmentofficer.1","UserRole":"Credit_Assessment_Officer","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["Credit_Assessment_Officer"]},' +
  // '{"FirstName":"Test","LastName":"Credit Assessment Officer 2","Username":"_creditassessmentofficer.2","UserRole":"Credit_Assessment_Officer","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["Credit_Assessment_Officer"]},' +
  // '{"FirstName":"Test","LastName":"Credit Assessor Lead 1","Username":"_creditassessorlead.1","UserRole":"Credit_Assessor_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"PermissionSetGroups":["Credit_Assessor_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Credit Assessor Lead 2","Username":"_creditassessorlead.2","UserRole":"Credit_Assessor_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"PermissionSetGroups":["Credit_Assessor_Lead"]},' +
  // '{"FirstName":"Test","LastName":"FinCrime Agent 1","Username":"_fincrimeagent.1","UserRole":"FinCrime_Agent","Profile":"ANZx Standard User","PermissionSetGroups":["FinCrime_Agent"]},' +
  // '{"FirstName":"Test","LastName":"FinCrime Agent 2","Username":"_fincrimeagent.2","UserRole":"FinCrime_Agent","Profile":"ANZx Standard User","PermissionSetGroups":["FinCrime_Agent"]},' +
  // '{"FirstName":"Test","LastName":"FraudX Agent 1","Username":"_fraudxagent.1","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"FraudX Agent 2","Username":"_fraudxagent.2","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Join Lead 1","Username":"_joinlead.1","UserRole":"Join_Lead","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["FraudX_Agent","Join_Lead","Quality_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"Join Lead 2","Username":"_joinlead.2","UserRole":"Join_Lead","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["FraudX_Agent","Join_Lead","Quality_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"Quality & Capability Lead 1","Username":"_qualitycapabilitylead.1","UserRole":"Quality_Capability_Lead","Profile":"ANZx Standard User","PermissionSetGroups":["Quality_Capability_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Quality & Capability Lead 2","Username":"_qualitycapabilitylead.2","UserRole":"Quality_Capability_Lead","Profile":"ANZx Standard User","PermissionSetGroups":["Quality_Capability_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Quality Analyst 1","Username":"_qualityanalyst.1","UserRole":"Quality_Analyst","Profile":"ANZx Standard User","PermissionSetGroups":["Quality_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"Quality Analyst 2","Username":"_qualityanalyst.2","UserRole":"Quality_Analyst","Profile":"ANZx Standard User","PermissionSetGroups":["Quality_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"Residential Broker Manager 1","Username":"_residentialbrokermanager.1","UserRole":"Residential_Broker_Manager","Profile":"ANZx Standard User","PermissionSetGroups":["Residential_Broker_Manager"]},' +
  // '{"FirstName":"Test","LastName":"Residential Broker Manager 2","Username":"_residentialbrokermanager.2","UserRole":"Residential_Broker_Manager","Profile":"ANZx Standard User","PermissionSetGroups":["Residential_Broker_Manager"]},' +
  // '{"FirstName":"Test","LastName":"Settlement Officer 1","Username":"_settlementofficer.1","UserRole":"Settlement_Officer","Profile":"ANZx Standard User","PermissionSetGroups":["Settlement_Officer"]},' +
  // '{"FirstName":"Test","LastName":"Settlement Officer 2","Username":"_settlementofficer.2","UserRole":"Settlement_Officer","Profile":"ANZx Standard User","PermissionSetGroups":["Settlement_Officer"]},' +
  // '{"FirstName":"Test","LastName":"Settlement Officer Lead 1","Username":"_settlementofficerlead.1","UserRole":"Settlement_Officer_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"PermissionSetGroups":["Settlement_Officer_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Settlement Officer Lead 2","Username":"_settlementofficerlead.2","UserRole":"Settlement_Officer_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"PermissionSetGroups":["Settlement_Officer_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Support Coach 1","Username":"_supportcoach.1","UserRole":"Support_Coach","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["Support_Coach"]},' +
  // '{"FirstName":"Test","LastName":"Support Coach 2","Username":"_supportcoach.2","UserRole":"Support_Coach","Profile":"ANZx Standard User","CallCenter":true,"PermissionSetGroups":["Support_Coach"]}' +
  // CMOS automation test users
  // '{"FirstName":"Test","LastName":"Automation CMOS L1","Username":"_automation.cmos.l1","UserRole":"Customer_Resolution","Profile":"ANZ Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"Automation CMOS L2","Username":"_automation.cmos.l2","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"Automation CMOS L3","Username":"_automation.cmos.l3","UserRole":"Banker","Profile":"ANZ Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"Automation CMOS SI","Username":"_automation.cmos.si","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard Automation User","PermissionSets":["Bypass_TSP","Password_Never_Expires","SFDX_Full_Dev_Hub_Access"],"PermissionSetGroups":["IDR_SI_User"]}' +
  // CMOS manual test users
  // '{"FirstName":"Test","LastName":"CMOS Coach","Username":"_cmos.coach","UserRole":"Coach","Profile":"ANZx Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"CMOS CQL 1","Username":"_cmos.cql.1","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS CQL 2","Username":"_cmos.cql.2","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS CRPLT 1","Username":"_cmos.crplt.1","UserRole":"Customer_Resolution_Leadership","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS CRPLT 2","Username":"_cmos.crplt.2","UserRole":"Customer_Resolution_Leadership","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS CRPTL 1","Username":"_cmos.crptl.1","UserRole":"Customer_Resolution_Team_Leaders","Profile":"ANZ Standard User","Manager":"_cmos.crplt.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS CRPTL 2","Username":"_cmos.crptl.2","UserRole":"Customer_Resolution_Team_Leaders","Profile":"ANZ Standard User","Manager":"_cmos.crplt.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS DA 1","Username":"_cmos.da.1","UserRole":"Data_Analyst","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Data_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"CMOS DA 2","Username":"_cmos.da.2","UserRole":"Data_Analyst","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Data_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"CMOS ECH L2 1","Username":"_cmos.ech.l2.1","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS ECH L2 2","Username":"_cmos.ech.l2.2","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS ECH L3 1","Username":"_cmos.ech.l3.1","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.ech.l2.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS ECH L3 2","Username":"_cmos.ech.l3.2","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.ech.l2.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS KBCO 1","Username":"_cmos.kbco.1","UserRole":"IDR_Content_Writer","Profile":"ANZ Standard User","PermissionSets":["Knowledge_Base_Author","Password_Never_Expires"]},' +
  // '{"FirstName":"Test","LastName":"CMOS KBCO 2","Username":"_cmos.kbco.2","UserRole":"IDR_Content_Writer","Profile":"ANZ Standard User","PermissionSets":["Knowledge_Base_Author","Password_Never_Expires"]},' +
  // '{"FirstName":"Test","LastName":"CMOS L1 1","Username":"_cmos.l1.1","UserRole":"Customer_Resolution","Profile":"ANZ Standard User","Manager":"_cmos.crptl.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS L1 2","Username":"_cmos.l1.2","UserRole":"Customer_Resolution","Profile":"ANZ Standard User","Manager":"_cmos.crptl.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS L2 1","Username":"_cmos.l2.1","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","Manager":"_cmos.l1.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS L2 2","Username":"_cmos.l2.2","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","Manager":"_cmos.l1.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS L3 1","Username":"_cmos.l3.1","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.l2.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS L3 2","Username":"_cmos.l3.2","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.l2.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS QA 1","Username":"_cmos.qa.1","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","Manager":"_cmos.cql.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS QA 2","Username":"_cmos.qa.2","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","Manager":"_cmos.cql.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS SI 1","Username":"_cmos.si.1","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_User"]},' +
  // '{"FirstName":"Test","LastName":"CMOS SI 2","Username":"_cmos.si.2","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_User"]},' +
  // '{"FirstName":"Test","LastName":"CMOS SIBC 1","Username":"_cmos.sibc.1","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_Business_Contact"]},' +
  // '{"FirstName":"Test","LastName":"CMOS SIBC 2","Username":"_cmos.sibc.2","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_Business_Contact"]}' +
  // CMOS UAT manual test users
  // '{"FirstName":"Test","LastName":"CMOS UAT Coach","Username":"_cmos.uat.coach","UserRole":"Coach","Profile":"ANZx Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT CQL 1","Username":"_cmos.uat.cql.1","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT CQL 2","Username":"_cmos.uat.cql.2","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT CRPLT 1","Username":"_cmos.uat.crplt.1","UserRole":"Customer_Resolution_Leadership","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT CRPLT 2","Username":"_cmos.uat.crplt.2","UserRole":"Customer_Resolution_Leadership","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT CRPTL 1","Username":"_cmos.uat.crptl.1","UserRole":"Customer_Resolution_Team_Leaders","Profile":"ANZ Standard User","Manager":"_cmos.uat.crplt.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT CRPTL 2","Username":"_cmos.uat.crptl.2","UserRole":"Customer_Resolution_Team_Leaders","Profile":"ANZ Standard User","Manager":"_cmos.uat.crplt.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_CRP_Team_Leaders"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT DA 1","Username":"_cmos.uat.da.1","UserRole":"Data_Analyst","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Data_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT DA 2","Username":"_cmos.uat.da.2","UserRole":"Data_Analyst","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Data_Analyst"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT ECH L2 1","Username":"_cmos.uat.ech.l2.1","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT ECH L2 2","Username":"_cmos.uat.ech.l2.2","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT ECH L3 1","Username":"_cmos.uat.ech.l3.1","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.uat.ech.l2.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT ECH L3 2","Username":"_cmos.uat.ech.l3.2","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.uat.ech.l2.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT KBCO 1","Username":"_cmos.uat.kbco.1","UserRole":"IDR_Content_Writer","Profile":"ANZ Standard User","PermissionSets":["Knowledge_Base_Author","Password_Never_Expires"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT KBCO 2","Username":"_cmos.uat.kbco.2","UserRole":"IDR_Content_Writer","Profile":"ANZ Standard User","PermissionSets":["Knowledge_Base_Author","Password_Never_Expires"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT L1 1","Username":"_cmos.uat.l1.1","UserRole":"Customer_Resolution","Profile":"ANZ Standard User","Manager":"_cmos.uat.crptl.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT L1 2","Username":"_cmos.uat.l1.2","UserRole":"Customer_Resolution","Profile":"ANZ Standard User","Manager":"_cmos.uat.crptl.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT L2 1","Username":"_cmos.uat.l2.1","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","Manager":"_cmos.uat.l1.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT L2 2","Username":"_cmos.uat.l2.2","UserRole":"Banker_Line_Manager","Profile":"ANZ Standard User","Manager":"_cmos.uat.l1.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_2"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT L3 1","Username":"_cmos.uat.l3.1","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.uat.l2.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT L3 2","Username":"_cmos.uat.l3.2","UserRole":"Banker","Profile":"ANZ Standard User","Manager":"_cmos.uat.l2.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["Extra_Care_Hub","IDR_Level_3"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT QA 1","Username":"_cmos.uat.qa.1","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","Manager":"_cmos.uat.cql.1","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT QA 2","Username":"_cmos.uat.qa.2","UserRole":"Capability_Quality_C_Q_Team","Profile":"ANZ Standard User","Manager":"_cmos.uat.cql.2","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["CMOS_Quality_Assessor","IDR_Level_1"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT SI 1","Username":"_cmos.uat.si.1","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_User"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT SI 2","Username":"_cmos.uat.si.2","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_User"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT SIBC 1","Username":"_cmos.uat.sibc.1","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_Business_Contact"]},' +
  // '{"FirstName":"Test","LastName":"CMOS UAT SIBC 2","Username":"_cmos.uat.sibc.2","UserRole":"Systemic_Issue_Team","Profile":"ANZ Standard User","PermissionSets":["Password_Never_Expires"],"PermissionSetGroups":["IDR_SI_Business_Contact"]}' +
  // Testing team users
  // '{"FirstName":"Lalitha Ravali","LastName":"Chintaluri","Username":"lalitharavali.chintaluri","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"lalitharavali.chintaluri@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Navarose","LastName":"Haneefa Kutty","Username":"navarose.haneefakutty","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"navarose.haneefakutty@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Yogesh","LastName":"Jamgaonkar","Username":"yogesh.jamgaonkar","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"yogesh.jamgaonkar@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Pooja","LastName":"Lunkar","Username":"pooja.lunkar","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"pooja.lunkar@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Rajani","LastName":"Murthy","Username":"rajani.murthy","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"rajani.murthy@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Prasad Reddy","LastName":"Patlolla","Username":"prasad.patlolla","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"prasad.patlolla@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Kevin","LastName":"Tan","Username":"kevin.tan2","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"kevin.tan@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]},' +
  // '{"FirstName":"Anmol","LastName":"Verma","Username":"anmol.verma","UserRole":"Engineer","Profile":"Minimum Access - Salesforce","FederationId":"anmol.verma@anznp.com","PermissionSets":["Password_Never_Expires","Read_Only_Admin"],"PermissionSetGroups":["Engineer"]}' +
  // Twilio test users
  // '{"FirstName":"Test","LastName":"Twilio Coach 1","Username":"_twilio.coach.1","UserRole":"Coach","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"newcoach@anznp.com","PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"Twilio Coach 2","Username":"_twilio.coach.2","UserRole":"Coach","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"expcoach@anznp.com","PermissionSetGroups":["Coach"]},' +
  // '{"FirstName":"Test","LastName":"Twilio Coach Lead 1","Username":"_twilio.coachlead.1","UserRole":"Coach_Lead","Profile":"ANZx Standard User","KnowledgeUser":true,"CallCenter":true,"FederationId":"coach.lead@anznp.com","PermissionSetGroups":["Coach_Lead"]},' +
  // '{"FirstName":"Test","LastName":"Twilio FraudX Agent 1","Username":"_twilio.fraudxagent.1","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"idops@anznp.com","PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Twilio FraudX Agent 2","Username":"_twilio.fraudxagent.2","UserRole":"FraudX_Agent","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"fraudagent@anznp.com","PermissionSetGroups":["FraudX_Agent"]},' +
  // '{"FirstName":"Test","LastName":"Twilio Quality Analyst 1","Username":"_twilio.qualityanalyst.1","UserRole":"Quality_Analyst","Profile":"ANZx Standard User","CallCenter":true,"FederationId":"quality.analyst@anznp.com","PermissionSetGroups":["Quality_Analyst"]}' +
  ']';

public class UserData {
  String FirstName { get; set; }
  String LastName { get; set; }
  String Email { get; set; }
  String Username { get; set; }
  String UserRole { get; set; }
  String Profile { get; set; }
  Boolean KnowledgeUser { get; set; }
  Boolean CallCenter { get; set; }
  String FederationId { get; set; }
  String Manager { get; set; }
  List<String> PermissionSets { get; set; }
  List<String> PermissionSetGroups { get; set; }
}

System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
String sandboxName = domain.getSandboxName();

Id twilioCallCenterId = [
  SELECT Id
  FROM CallCenter
  WHERE Name = 'Twilo Flex Call Center Adapter Open CTI'
  LIMIT 1
]
.Id;

private User createUser(UserData userData) {
  return new User(
    FirstName = !String.isBlank(userData.FirstName) ? userData.FirstName : null,
    LastName = userData.LastName,
    Alias = createAlias(UserData),
    Email = !String.isBlank(userData.Email) ? userData.Email : email,
    Username = userData.Username + '@anzx.com.' + sandboxName,
    UserRoleId = QueryRole.get(userData.UserRole).Id,
    ProfileId = QueryProfile.get(userData.Profile).Id,
    CallCenterId = userData.CallCenter != null &&
      userData.CallCenter == true
      ? twilioCallCenterId
      : null,
    UserPermissionsKnowledgeUser = userData.KnowledgeUser != null &&
      userData.KnowledgeUser == true
      ? true
      : false,
    FederationIdentifier = !String.isBlank(userData.FederationId)
      ? userData.FederationId
      : null,
    LanguageLocaleKey = 'en_US',
    LocaleSidKey = 'en_AU',
    EmailEncodingKey = 'UTF-8',
    TimeZoneSidKey = 'Australia/Sydney'
  );
}

private String createAlias(UserData userData) {
  return ((!String.isBlank(userData.FirstName)
      ? userData.FirstName.substring(
          0,
          (userData.FirstName.length() >= 1 ? 1 : 0)
        )
      : '') +
    userData.LastName.substring(
      0,
      (userData.LastName.length() >= 4 ? 4 : userData.LastName.length())
    ))
    .toLowerCase();
}

// Create users
List<UserData> userDatas = (List<UserData>) JSON.deserialize(
  userDataJSON,
  List<UserData>.class
);
List<User> users = new List<User>();
for (UserData userData : userDatas) {
  users.add(createUser(userData));
}
insert (users);
Map<String, User> usersByUsername = new Map<String, User>();
for (User user : users) {
  usersByUsername.put(user.Username.split('@')[0], user);
}

// Assign permission sets and permission set groups
List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
for (UserData userData : UserDatas) {
  if (userData.PermissionSets == null) {
    continue;
  }
  User user = usersByUsername.get(userData.Username);
  for (String permissionSet : userData.permissionSets) {
    permissionSetAssignments.add(
      new PermissionSetAssignment(
        PermissionSetId = QueryPS.get(permissionSet).Id,
        AssigneeId = user.Id
      )
    );
  }
}
for (UserData userData : UserDatas) {
  if (userData.PermissionSetGroups == null) {
    continue;
  }
  User user = usersByUsername.get(userData.Username);
  for (String permissionSetGroup : userData.permissionSetGroups) {
    permissionSetAssignments.add(
      new PermissionSetAssignment(
        PermissionSetGroupId = QueryPSG.get(permissionSetGroup).Id,
        AssigneeId = user.Id
      )
    );
  }
}
insert (permissionSetAssignments);

// Assign manager
List<User> userManagers = new List<User>();
for (UserData userData : UserDatas) {
  if (String.isBlank(userData.Manager) == true) {
    continue;
  }
  User user = usersByUsername.get(userData.Username);
  User manager = usersByUsername.get(userData.Manager);
  user.ManagerId = manager.Id;
  userManagers.add(user);
}
update (userManagers);
