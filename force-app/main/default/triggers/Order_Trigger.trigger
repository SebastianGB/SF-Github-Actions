trigger Order_Trigger on Order (after insert, after update, after delete, after undelete) {

    // GITHUB ACTIONS
    OrderTriggerHandler handler = new OrderTriggerHandler();

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            handler.OnAfterInsert(Trigger.newMap);
        }
    } else if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            handler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    } 
    else if (Trigger.isDelete){
        if (Trigger.isAfter) {
            handler.onAfterDelete(Trigger.oldMap);
        }
    }
    else if (Trigger.isUndelete){
        if (Trigger.isAfter) {
            handler.OnAfterUndelete(Trigger.newMap);
        }
    }
}   