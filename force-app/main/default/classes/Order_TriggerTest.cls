/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
public class Order_TriggerTest {
    @testSetup
    static void setup() {
        // Insert an Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            GMV__c = 1000,
            Purchase_Price__c = 500
        );
        insert testOpportunity;

        // Insert an Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a new Order linked to the Opportunity
        Order testOrder = new Order(
        OpportunityId = testOpportunity.Id,
        AccountId = testAccount.Id,
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Transport_Costs__c = 10.00,
        Storage__c = 10.00,
        Sorting__c = 10.00,
        Hedging__c = 10.00
        );
        insert testOrder;
    }

    @IsTest
    static void testAfterInsert() {
        // Query the Opportunity created in @testSetup
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity'];

        // Query a new Order linked to the Opportunity
        Order testOrder = [SELECT Id, OpportunityId, Total_Costs__c FROM Order WHERE OpportunityId = :testOpportunity.Id];

        // Verify the expected behavior
        testOpportunity = [SELECT Id, Name, Contribution_Margin__c, GMV__c, Purchase_Price__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals(testOpportunity.Contribution_Margin__c, OpportunityActions.calculateContributionMargin(testOpportunity, testOrder.Total_Costs__c), 'The CM should be set correctly.');
    }

    @IsTest
    static void testAfterUpdate() {
        // Query the Opportunity created in @testSetup
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity'];

        // Query a new Order linked to the Opportunity
        Order testOrder = [SELECT Id, OpportunityId, Total_Costs__c FROM Order WHERE OpportunityId = :testOpportunity.Id];

        // Update the Order
        testOrder.Transport_Costs__c = 15.00;
        update testOrder;

        // Verify the expected behavior
        testOpportunity  = [SELECT Id, Name, Contribution_Margin__c, GMV__c, Purchase_Price__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        testOrder = [SELECT Id, Name, OpportunityId, Total_Costs__c FROM Order WHERE Id = :testOrder.Id];
        System.assertEquals(testOpportunity.Contribution_Margin__c, OpportunityActions.calculateContributionMargin(testOpportunity, testOrder.Total_Costs__c), 'The CM should be set correctly.');
    }

    @IsTest
    static void testAfterDelete() {
        // Query the Opportunity created in @testSetup
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity'];

        // Query a new Order linked to the Opportunity
        Order testOrder = [SELECT Id, OpportunityId, Total_Costs__c FROM Order WHERE OpportunityId = :testOpportunity.Id];

        // Delete the Order
        delete testOrder;

        // Verify the expected behavior
        testOpportunity  = [SELECT Id, Name, Contribution_Margin__c, GMV__c, Purchase_Price__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals(testOpportunity.Contribution_Margin__c, OpportunityActions.calculateContributionMargin(testOpportunity, 0), 'The CM should be set correctly.');
    }

    @IsTest
    static void testAfterUndelete() {
        // Query the Opportunity created in @testSetup
        Opportunity testOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opportunity'];

        // Query a new Order linked to the Opportunity
        Order testOrder = [SELECT Id, OpportunityId, Total_Costs__c FROM Order WHERE OpportunityId = :testOpportunity.Id];

        // Delete the Order
        delete testOrder;

         // Verify the expected behavior
         testOpportunity  = [SELECT Id, Name, Contribution_Margin__c, GMV__c, Purchase_Price__c FROM Opportunity WHERE Id = :testOpportunity.Id];
         System.assertEquals(testOpportunity.Contribution_Margin__c, OpportunityActions.calculateContributionMargin(testOpportunity, 0), 'The CM should be set correctly.');
         
        // Undelete the Order
        undelete testOrder;

         // Verify the expected behavior
         testOpportunity  = [SELECT Id, Name, Contribution_Margin__c, GMV__c, Purchase_Price__c FROM Opportunity WHERE Id = :testOpportunity.Id];
         testOrder = [SELECT Id, Name, OpportunityId, Total_Costs__c FROM Order WHERE Id = :testOrder.Id];
         System.assertEquals(testOpportunity.Contribution_Margin__c, OpportunityActions.calculateContributionMargin(testOpportunity, testOrder.Total_Costs__c), 'The CM should be set correctly.');
    }
}
