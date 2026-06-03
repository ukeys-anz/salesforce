/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Model class for Pega Case Request Payload
 **/
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class PegaCaseRequestModel extends CalloutModel {
  public String OpportunityID;
  public String NewToBank;
  public String TransactionBankingProcess;
  public String OpportunityOwner;
  public String OpportunityNotes;
  public Customer CustomerInfo;
  public Entity EntityInfo;
  public List<Product> ProductList;

  /**
   * @description This is the Customer class.
   */
  public class Customer {
    public String Name;
    public String Type;
    public String SourceSystemID;
    public String SourceSystem;

    /**
     * @description Constructor for Customer Info.
     * @param opportunity The Opportunity record.
     */
    public Customer(Opportunity opportunity) {
      this.Name = opportunity.Account.Name;
      this.Type = opportunity.Account.RecordType.Name;
      this.SourceSystemID = opportunity.Account.Source_System_ID__c;
      this.SourceSystem = opportunity.Account.Source_System_Name__c;
    }
  }

  /**
   * @description This is the Entity class.
   */
  public class Entity {
    public String Name;
    public String Type;
    public String SourceSystemID;
    public String SourceSystem;
    public List<Entity> RelatedEntities;

    /**
     * @description Constructor for Entity Info.
     * @param opportunity The Opportunity record.
     * @param entities The list of related CLG Entities.
     */
    public Entity(
      Opportunity opportunity,
      List<FinServ__AccountAccountRelation__c> entities
    ) {
      this.Name = opportunity.CLG__r.Name;
      this.Type = opportunity.CLG__r.RecordType.Name;
      this.SourceSystemID = opportunity.CLG__r.Source_System_ID__c;
      this.SourceSystem = opportunity.CLG__r.Source_System_Name__c;
      this.RelatedEntities = constructRelatedEntities(entities);
    }

    /**
     * @description Constructor for Entity Info.
     * @param entity The FinServ__AccountAccountRelation__c record.
     */
    public Entity(FinServ__AccountAccountRelation__c entity) {
      this.Name = entity.FinServ__Account__r.Name;
      this.Type = entity.FinServ__Account__r.RecordType.Name;
      this.SourceSystemID = entity.FinServ__Account__r.Source_System_ID__c;
      this.SourceSystem = entity.FinServ__Account__r.Source_System_Name__c;
    }

    /**
     * @description Construct all the related Entity records.
     * @param entities The List of FinServ__AccountAccountRelation__c records.
     * @return List<Entity> related entities list.
     */
    private List<Entity> constructRelatedEntities(
      List<FinServ__AccountAccountRelation__c> entities
    ) {
      if (entities.isEmpty()) {
        return null;
      }
      List<Entity> relatedEntities = new List<Entity>();
      for (FinServ__AccountAccountRelation__c rel : entities) {
        relatedEntities.add(new Entity(rel));
      }
      return relatedEntities;
    }
  }

  /**
   * @description This is the Product class.
   */
  public class Product {
    public String ProductType;
    public String ProductCode;
    public String ProductSubtype;

    /**
     * @description Constructor for Product Info.
     * @param product The OpportunityLineItem record.
     */
    public Product(OpportunityLineItem product) {
      this.ProductType = product.Product2.Name;
      this.ProductCode = product.Product2.ProductCode;
      this.ProductSubtype = product.Product2.Sub_Product_Code__c;
    }
  }

  /**
   * @description Constructor for PegaCaseRequestModel payload.
   * @param opportunity The Opportunity record.
   * @param opportunityLineItems The related Products.
   * @param relatedEntities The selected CLG Entities.
   */
  public PegaCaseRequestModel(
    Opportunity opportunity,
    List<OpportunityLineItem> opportunityLineItems,
    List<FinServ__AccountAccountRelation__c> relatedEntities
  ) {
    this.OpportunityID = opportunity.Opp_Id__c;
    this.NewToBank = opportunity.New_to_Bank__c;
    this.TransactionBankingProcess = opportunity.Transaction_Banking_Process__c;
    this.OpportunityOwner = opportunity.Owner.Name;
    this.OpportunityNotes = opportunity.LegalEntitiesandProductNotes__c;
    this.CustomerInfo = new Customer(opportunity);
    this.EntityInfo = opportunity.CLG__c != null
      ? new Entity(opportunity, relatedEntities)
      : null;
    this.ProductList = constructProductsList(opportunityLineItems);
  }

  /**
   * @description Initializes Products list.
   * @param opportunityLineItems The related Products.
   * @return List<Product> products list.
   */
  private List<Product> constructProductsList(
    List<OpportunityLineItem> opportunityLineItems
  ) {
    List<Product> products = new List<Product>();
    for (OpportunityLineItem oli : opportunityLineItems) {
      products.add(new Product(oli));
    }
    return products;
  }
}
