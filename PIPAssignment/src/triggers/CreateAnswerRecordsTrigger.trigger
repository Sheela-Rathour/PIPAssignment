/**
* @ClassName    : CreateAnswerRecordsTrigger
* @CreatedOn    : 4/16/2015
* @Description  : Trigger for create the Blank Answer record .
*/

trigger CreateAnswerRecordsTrigger on OpportunityLineItem (after insert, before delete) {
	
	CreateAnswerRecordHandler objAnswerRecordHandler = new CreateAnswerRecordHandler();
	
	//Trigger Fire on After Insert
	if(Trigger.isAfter && Trigger.isInsert) {
			
		objAnswerRecordHandler.insertAnswerRecord(Trigger.new); 
	}
}