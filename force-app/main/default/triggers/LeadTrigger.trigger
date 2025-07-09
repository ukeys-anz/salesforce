trigger LeadTrigger on Lead(
  before delete,
  before insert,
  before update,
  after insert,
  after update
) {
  LeadTriggerHandler handler = new LeadTriggerHandler();
  MobileLendingLeadTriggerHandler mobileLendingHandler = new MobileLendingLeadTriggerHandler();
  CommercialLeadTriggerHandler commercialHandler = new CommercialLeadTriggerHandler();
  CommercialReferralLeadTriggerHandler referralLeadHandler = new CommercialReferralLeadTriggerHandler();
  BOHLeadTriggerHandler bohLeadHandler = new BOHLeadTriggerHandler();
}
