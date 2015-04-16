/**
* @ClassName    : CreateAnswerRecordsTrigger
* @CreatedOn    : 4/14/2015
* @Description  : Trigger for create the Blank Answer record .
*/

trigger CreateAnswerRecordsTrigger on OpportunityLineItem (after insert) {
	
	if(Trigger.isInsert) {
		
		map<Id,Id> mapProductId_OppId = new map<Id,Id>();
		map<Id,List<Product2>> mapProductGroup_OppProduct = new map<Id,List<Product2>>();
		map<Id,List<Questions__c>> mapProductGroup_Questions = new map<Id,List<Questions__c>>();
		set<Id> setOfProductGroup = new set<Id>();
		list<Answer__c> lstAnswer = new list<Answer__c>();
		
		for(OpportunityLineItem objOLI : Trigger.new){
			
			mapProductId_OppId.put(objOLI.Product2Id,objOLI.OpportunityId);
		}
		
		for(Product2 objProduct : [	SELECT Id ,Product_Group__c 
									FROM Product2 
									WHERE  Id In : mapProductId_OppId.KeySet()] ) {
		
			setOfProductGroup.add(objProduct.Product_Group__c);
		}
		
		for(Product_Group__c objProductGroup : [ SELECT Id,(SELECT Id FROM Products__r), (SELECT Id FROM Questions__r)
												 FROM Product_Group__c
												 WHERE Id In : setOfProductGroup ]) {
													
			if(mapProductGroup_OppProduct.containskey(objProductGroup.Id)){
				
				mapProductGroup_OppProduct.get(objProductGroup.Id).add(objProductGroup.Products__r);
			}
			else{
				
				mapProductGroup_OppProduct.put(objProductGroup.Id,new List<Product2>{objProductGroup.Products__r});
			}
			
			if(mapProductGroup_Questions.containskey(objProductGroup.Id)){
				
				mapProductGroup_Questions.get(objProductGroup.Id).add(objProductGroup.Questions__r);
			}
			else {
				
				mapProductGroup_Questions.put(objProductGroup.Id,new List<Questions__c>{objProductGroup.Questions__r});
			}
	 	}
	 	/*
	 	for(Product2 objProduct : mapProductGroup_OppProduct.values()) {
	 		
	 		for(Questions__c  objQuestion : mapProductGroup_Questions.values()) {
	 			
	 			Answer__c objAnswer = new Answer__c(Questions__c = objQuestion.Id,Product__c = objProduct.Id, Opportunity__c = mapProductId_OppId.get(objProduct.Id));
	 			lstAnswer.add(objAnswer);
	 		}
	 	}
	 	system.debug('=====lstAnswer============'+lstAnswer); 
	 	if(!lstAnswer.isEmpty()) {
	 		
	 		insert lstAnswer;
	 	}
	 	*/
	}
}