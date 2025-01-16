/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Request Model to be sent to Fabric Seal via Mulesoft from Salesforce
 */
public with sharing class FabricSealRequestModel {
    /**
     * @description account number for which prechecks to be done
     */
    public String account;

    /**
     * @description case number to be sent to Fabric Seal
     */
    public String salesforceCaseNumber;

    /**
     * @description Forwarding Account Details to be sent Fabric Seal
     */
    public ForwardingAccount forwardingAccount;


    /**
     * @description This is wrapper class for Forwarding Account Details
     * @name ForwardingAccount
     * @author Shivam Swaraj
     */
    public class ForwardingAccount {
        public String accountNumber;
        public String accountName;
        public String bsb;

         /**
         * @description Parametrised Constructor to initialize the value of the variables
         * @param accountNumber
         * @param accountName
         * @param bsb
         */
        public ForwardingAccount(
            String accountNumber,
            String accountName,
            String bsb
        )
        {
            this.accountNumber = accountNumber;
            this.accountName = accountName;
            this.bsb = bsb;
        }
    }

    /**
     * @description Parametrised Constructor to initialize the value of the variables
     * @param account
     * @param salesforceCaseNumber
     * @param forwardingAccount
     */
    public FabricSealRequestModel(String account,String salesforceCaseNumber,
    ForwardingAccount forwardingAccount ) {
        this.account = account;
        this.salesforceCaseNumber = salesforceCaseNumber;
        this.forwardingAccount = forwardingAccount;
    }


}