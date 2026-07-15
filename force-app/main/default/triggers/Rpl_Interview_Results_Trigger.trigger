trigger Rpl_Interview_Results_Trigger on Rpl_Interview_Result__c (after insert) {
	Rpl_Interview_Result_Handler.updateAfterInsert(Trigger.New);
}