public with sharing class OrderTriggerHandler {

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