/**
 * @author       : Advait Yermalkar
 * @since        : 09-02-2024
 * @description  : Controller class for OpportunityRelatedApplication lwc Component
 **/
public with sharing class RelatedAppOnOppController {
  /**
   * @description Instance of Repository class RelatedAppOnOppControllerRepository
   **/
  private static final RelatedAppOnOppControllerRepository OPP_DATA_CONTROLLER_REPOSITORY = (RelatedAppOnOppControllerRepository) Lib_InstanceProvider.forType(
    RelatedAppOnOppControllerRepository.class
  );

  /**
   * @description Wrapper class to store Application Form and related Products
   **/
  public class ApplicationFormWrapper {
    /**
     * @description id Field
     **/
    @AuraEnabled
    public String id { get; set; }

    /**
     * @description name Field
     **/
    @AuraEnabled
    public String name { get; set; }

    /**
     * @description applicationAmount Field
     **/
    @AuraEnabled
    public Decimal applicationAmount { get; set; }

    /**
     * @description applicationNumber Field
     **/
    @AuraEnabled
    public String applicationNumber { get; set; }

    /**
     * @description applicationStatus Field
     **/
    @AuraEnabled
    public String applicationStatus { get; set; }

    /**
     * @description ApplicationFormProductWrapper Field
     **/
    @AuraEnabled
    public List<ApplicationFormProductWrapper> applicationFormProducts {
      get;
      set;
    }

    /**
     * @description Constructor for ApplicationFormWrapper
     * @param form ApplicationForm instance
     **/
    public ApplicationFormWrapper(ApplicationForm form) {
      this.id = form.Id;
      this.name = form.Name;
      this.applicationAmount = form.Application_Amount__c;
      this.applicationNumber = form.Application_Number__c;
      this.applicationStatus = form.Application_Status__c;
      this.applicationFormProducts = new List<ApplicationFormProductWrapper>();

      for (ApplicationFormProduct product : form.ApplicationFormProducts) {
        this.applicationFormProducts.add(
          new ApplicationFormProductWrapper(product)
        );
      }
    }
  }

  /**
   * @description  Wrapper class to store Application Form Product and related Product
   **/
  public class ApplicationFormProductWrapper {
    /**
     * @description id Field
     **/
    @AuraEnabled
    public String id { get; set; }

    /**
     * @description name Field
     **/
    @AuraEnabled
    public String name { get; set; }

    /**
     * @description nameUrl Field - contains Url of the ApplicationFormProduct
     **/
    @AuraEnabled
    public String nameUrl { get; set; }

    /**
     * @description stage Field
     **/
    @AuraEnabled
    public String stage { get; set; }

    /**
     * @description productId Field
     **/
    @AuraEnabled
    public String productId { get; set; }

    /**
     * @description productName Field
     **/
    @AuraEnabled
    public String productName { get; set; }

    /**
     * @description productUrl Field - Contains url to the product
     **/
    @AuraEnabled
    public String productUrl { get; set; }

    /**
     * @description closeDate Field
     **/
    @AuraEnabled
    public Date closeDate { get; set; }

    /**
     * @description Constructor for ApplicationFormProductWrapper
     * @param product ApplicationFormProduct
     **/
    public ApplicationFormProductWrapper(ApplicationFormProduct product) {
      this.id = product.Id;
      this.name = product.Name;
      this.stage = product.Stage;
      this.productId = product.ProductId;
      this.productName = product.Product.Name;
      this.productUrl = '/lightning/r/Product/' + product.ProductId + '/view';
      this.closeDate = product.Close_Date__c;
      this.nameUrl =
        '/lightning/r/ApplicationFormProduct/' +
        product.Id +
        '/view';
    }
  }

  /**
   * @description returns List of ApplicationForm with Products
   * @param opportunityId opportunity Id
   * @param pageSize page size
   * @param pageNumber page number
   * @return List<ApplicationFormWrapper> List of ApplicationFormWrapper
   **/
  @AuraEnabled(cacheable=true)
  public static List<ApplicationFormWrapper> getApplicationFormsWithProducts(
    Id opportunityId,
    Integer pageSize,
    Integer pageNumber
  ) {
    try {
      List<ApplicationFormWrapper> wrappers = new List<ApplicationFormWrapper>();
      Integer offSet = ((pageNumber - 1) * pageSize);
      List<ApplicationForm> forms = OPP_DATA_CONTROLLER_REPOSITORY.getApplicationForms(
        opportunityId,
        pageSize,
        offSet
      );
      for (ApplicationForm form : forms) {
        wrappers.add(new ApplicationFormWrapper(form));
      }
      return wrappers;
    } catch (Exception e) {
      Logger.error(
          'Error occured while getting ApplicationFormsWithProducts',
          e
        )
        .save();
      throw new AuraHandledException(e.getMessage());
    }
  }
}
