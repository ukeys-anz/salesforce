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
    }


}