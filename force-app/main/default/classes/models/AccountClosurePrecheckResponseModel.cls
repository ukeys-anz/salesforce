/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description  Model Class for the Fabric Seal Response
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 * ExcessivePublicCount Surpressed : AccountClosurePrecheckResponseModel to have all the public methods and attributes together.
 */
@SuppressWarnings(
    'PMD.ExcessivePublicCount, PMD.FieldNamingConventions'
  )
public with sharing class AccountClosurePrecheckResponseModel extends CalloutModel {
    /**
     * @description acceptance value from Precheck Api
     */
	@AuraEnabled
    public String acceptance {get; set;}
    /**
     * @description salesforceCaseNumber value from Precheck Api
     */
    @AuraEnabled
    public String salesforceCaseNumber  {get; set;}
    /**
     * @description businessProcessId value from Precheck Api
     */
    @AuraEnabled	
    public String businessProcessId  {get; set;}
    /**
     * @description unsatisfiedPreconditions value from Precheck Api
     */
    @AuraEnabled	
    public UnsatisfiedPreconditions unsatisfiedPreconditions  {get; set;}
    /**
     * @description code value from Precheck Api
     */
    @AuraEnabled	
    public String code  {get; set;}
    /**
     * @description message value from Precheck Api
     */
    @AuraEnabled	
    public String message  {get; set;}
    
    /**
     * @description unsatisfied pre conditions values
     */
	public class UnsatisfiedPreconditions {
        /**
         * @description restraints value from Precheck Api
         */    
        @AuraEnabled
		public Restraints restraints { get; set; }
        /**
         * @description bankruptcy value from Precheck Api
         */         
        @AuraEnabled
		public Bankruptcy bankruptcy { get; set; }
        /**
         * @description deceasedEstates value from Precheck Api
         */         
        @AuraEnabled
		public DeceasedEstates deceasedEstates { get; set; }
        /**
         * @description unclearedFunds value from Precheck Api
         */         
        @AuraEnabled
		public UnclearedFunds unclearedFunds { get; set; }
        /**
         * @description nonzeroAvailableBalance value from Precheck Api
         */         
        @AuraEnabled
		public NonzeroAvailableBalance nonzeroAvailableBalance{ get; set; }
        /**
         * @description nonzeroClosureBalance value from Precheck Api
         */         
        @AuraEnabled
		public NonzeroClosureBalance nonzeroClosureBalance{ get; set; }
        /**
         * @description pendingAuths value from Precheck Api
         */        
        @AuraEnabled
		public PendingAuths pendingAuths{ get; set; }
        /**
         * @description loanOffset value from Precheck Api
         */ 
        @AuraEnabled
		public LoanOffset loanOffset{ get; set; }
	}

    /**
     * @description restraint values
     */
	public class Restraints {
        /**
         * @description eligibility value from Precheck Api
         */ 
        @AuraEnabled
		public String eligibility { get; set; }	
	}

    /**
     * @description Bankruptcy values
     */
	public class Bankruptcy {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility { get; set; }	
	}

    /**
     * @description the DeceasedEstates value
     */
	public class DeceasedEstates {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility{ get; set; }
	}

    /**
     * @description UnclearedFunds value
     */
	public class UnclearedFunds {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility{ get; set; }
	}

    /**
     * @description NonzeroAvailableBalance value
     */
	public class NonzeroAvailableBalance {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility{ get; set; }
        /**
         * @description availableBalance value from Precheck Api
         */
        @AuraEnabled	
		public AvailableBalance availableBalance{ get; set; }
	}

    /**
     * @description AvailableBalance value
     */
	public class AvailableBalance {
        /**
         * @description currencyCode value from Precheck Api
         */
        @AuraEnabled
		public String currencyCode{ get; set; }
        /**
         * @description units value from Precheck Api
         */
        @AuraEnabled	
		public String units{ get; set; }
        /**
         * @description nanos value from Precheck Api
         */
        @AuraEnabled	
		public Integer nanos{ get; set; }
	}

    /**
     * @description NonzeroClosureBalance value
     */
	public class NonzeroClosureBalance {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility{ get; set; }
	}

    /**
     * @description PendingAuths value
     */
	public class PendingAuths {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility{ get; set; }
	}

    /**
     * @description LoanOffset value
     */
	public class LoanOffset {
        /**
         * @description eligibility value from Precheck Api
         */
        @AuraEnabled
		public String eligibility{ get; set; }
	}

	/**
     * @param json input string to deserialize
     * @return `List<AccountClosurePrecheckResponseModel>`
     * @description deserializes the input string into the model, using the base method and reserved key replacement
     */
    public static List<AccountClosurePrecheckResponseModel> parse(String json) {
        List<AccountClosurePrecheckResponseModel> model = (List<AccountClosurePrecheckResponseModel>) deserialize(
        json,
        List<AccountClosurePrecheckResponseModel>.class
        );
        return model;
    }

}