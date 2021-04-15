trigger lead on Lead (after update) {
    if (trigger.isAfter && trigger.isUpdate) {
        //leadTriggerHelper.checkLeadConversion(trigger.oldMap, trigger.new);
    }
}