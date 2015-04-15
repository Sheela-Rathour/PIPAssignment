public with sharing class QA_On_Opportunity {
	
	public boolean pageMessage				{get;set;}
	public Opportunity objOpportunity;
	
	
	public class QA_Wrapper	{
		
		public Question objQuestion 		{get;set;}
		public Answer objAnswer				{get;set;}
		public String strQuestionType		{get;set;}
		
		public QA_Wrapper() {}
	}
	
	//*Constructor
	public QA_On_Opportunity() {
		
		set<Id> setOfOppRelatedProductIds = new set<Id>();
		set<Id> setOfProductGroup = new set<Id>();
		lstOfQA_On_OpportunityWrapper = new List<QA_Wrapper>();
		map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
		
		String strOpportunityId = Apexpages.currentPage().getParameters().get('Id');
		
		if(strOpportunityId == null) {
			
		    pageMessage = true;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Id Is Null'));
		}
		else {
			
		    for(OpportunityLineItem  objOLI :	[   SELECT Name,OpportunityId, Product2Id
 	     									   		FROM OpportunityLineItem 
         								       		WHERE OpportunityId =: strOpportunityId
 	   					  			  			]) {
 	   					  			  	
 	   			setOfOppRelatedProductIds.add(objOLI.Product2Id);
 	   		}
		    if(setOfOppRelatedProductIds.isEmpty()) {
		    
		    	pageMessage = true;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No Questions to answer yet. Please add Products to the Opportunity.'));
		    }
		    else {
		    	
		    	for(Product2 objProduct : [	Select Id ,Product_Group__c 
											From Product2 
											Where  Id In : setOfOppRelatedProductIds] )	{
				
					setOfProductGroup.add(objProduct.Product_Group__c);
				}
		    	
		    	for(Question objQuestion : [ Select Type__c, Question__c, Product_Group__c, Name ,Id
		    								 From Questions__c 
		    								 Where Product_Group__c In : setOfProductGroup]) {
		    								 	
				 	mapQuesId_Question.put(objQuestion.Id,objQuestion);
				}
		    	
		    	for(Answer__c objAnswer : [	Select Questions__c,Questions__r.Type__c,Questions__r.Question__c, Product__c,Product__r.Name, 
		    								Opportunity__c,Questions__r.Related_Picklist_Values__c,Questions__r.Name  
		    								From Answer__c
		    								Where Opportunity__c =: objOpportunityId
		    								AND Questions__c = : mapQuesId_Question.keySet() ]){
		    									
					lstOfQA_On_OpportunityWrapper.add(objAnswer.Questions__r.Name,objAnswer.Answer__c,objAnswer.Questions__r.Type__c);
					
				}
		    }
		} 
	}
}