public with sharing class OrderTriggerHandler {

    // If this comment can be retrieved from the org Github Actions has succesfully deployed this code.
    public void OnAfterInsert(Map<Id, Order> newOrders) {
        OrderActions.updateOpportunityCM(newOrders);
    }

    public void onAfterUpdate(Map<Id, Order> newOrders, Map<Id, Order> oldOrders) {
        OrderActions.updateOpportunityCM(newOrders);
        
    }
    
    public void onAfterDelete(Map<Id, Order> deletedOrders) {
        OrderActions.updateOpportunityCM(deletedOrders);
    }

    public void onAfterUndelete(Map<Id, Order> newOrders) {
        OrderActions.updateOpportunityCM(newOrders);
    }
}