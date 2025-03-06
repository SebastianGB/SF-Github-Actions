public with sharing class OpportunityActions {

    public static Decimal calculateContributionMargin(Opportunity opportunity, Decimal totalCosts) {

        system.debug(opportunity.Contribution_Margin__c);

        // Calculate the Contribution Margin field using the total costs
        opportunity.Contribution_Margin__c = opportunity.GMV__c - opportunity.Purchase_Price__c - totalCosts;

        system.debug(opportunity.Contribution_Margin__c);


        return opportunity.Contribution_Margin__c;
    }
}