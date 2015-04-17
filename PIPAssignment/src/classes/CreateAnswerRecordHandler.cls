/**
@ClassName      : CreateAnswerRecordHandler
@CreatedOn    	: 4/16/2015
@Description    : Controller for the CreateAnswerRecordsTrigger Trigger
*/
public with sharing class CreateAnswerRecordHandler {
	
	/*
	Method Name : insertAnswerRecord
	Description : get the product related to opportunity and insert the Anser record related to the question and product
	Parameters	: List<OpportunityLineItem> lstOpportunityLineItem
	*/
	public void insertAnswerRecord(List<OpportunityLineItem> lstOpportunityLineItem) {
		
		//Local Varibales
		map<Id,Id> mapProductId_OppId = new map<Id,Id>();
		set<Id> setOfProductGroup = new set<Id>();
		list<Answer__c> lstAnswer = new list<Answer__c>();
		
		for(OpportunityLineItem objOLI : lstOpportunityLineItem) {
			
			mapProductId_OppId.put(objOLI.Product2Id,objOLI.OpportunityId);
		}
		
		for(Product2 objProduct : [	SELECT Id ,Product_Group__c 
									FROM Product2 
									WHERE  Id In : mapProductId_OppId.KeySet()
									AND Product_Group__c <> NULL ] ) {
		
			setOfProductGroup.add(objProduct.Product_Group__c);
		}
		
		for(Product_Group__c objProductGroup : [ SELECT Id,(SELECT Id FROM Products__r), (SELECT Id FROM Questions__r)
												 FROM Product_Group__c
												 WHERE Id In : setOfProductGroup ]) {
			
			for(Product2 objProduct: objProductGroup.Products__r ) {
				
				for(Questions__c objQues : objProductGroup.Questions__r) {
					
					if(mapProductId_OppId.get(objProduct.Id) != null) {
						
						Answer__c objAnswer = new Answer__c(Product__c = objProduct.Id, Questions__c = objQues.Id, Opportunity__c = mapProductId_OppId.get(objProduct.Id));
						lstAnswer.add(objAnswer);
					}
				}
			}
	 	}
	 	//Check For List Of answer is empty or not
	 	if(!lstAnswer.isEmpty()) {
	 		
	 		insert lstAnswer;
	 	}
	}
}