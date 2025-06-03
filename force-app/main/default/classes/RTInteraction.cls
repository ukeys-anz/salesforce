/**
 * @author Vishnu Kasu
 * @since May 2025
 * @description Holds cached Interaction Record Types.
 */
public class RTInteraction {
    static QueryRT base = QueryRT.of(Interaction.SObjectType);
    public static Id rbmBrokerInteraction = base.getId('RBM_Broker_Interaction');
}