/**
* @ClassName    : QA_On_OpportunityController
* @CreatedOn    : 4/14/2015
* @Description  : Controller class for QA_On_OpportunityPage. Controller for assessment of associated Question and Answer for closed deal of opportunity.
*/
public with sharing class QA_On_OpportunityController {
	
	
	public boolean pageMessage								{get;set;}
	public List<QA_Wrapper> lstOfQA_On_OpportunityWrapper	{get;set;}
	public String strOpportunityId;
	
	//Wrapper Class
	public class QA_Wrapper	{
		
		public Questions__c objQuestion 					{get;set;}
		public Answer__c objAnswer							{get;set;}
		public String strQuestionType						{get;set;}
		
		//Wrapper Constructor
		public QA_Wrapper(Questions__c question, Answer__c answer, String questionType) {
		
			objQuestion = question;
			objAnswer = answer;
			strQuestionType = questionType;
		}
	}
	
	//*Constructor
	public QA_On_OpportunityController() {
		
		set<Id> setOfOppRelatedProductIds = new set<Id>();
		lstOfQA_On_OpportunityWrapper = new List<QA_Wrapper>();
		map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
		pageMessage = false;
		
		strOpportunityId = Apexpages.currentPage().getParameters().get('Id');
		
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
		    	
		    	fetchProductGroupQuestionAnswer(setOfOppRelatedProductIds);
		    }
		} 
	}
	
	public void fetchProductGroupQuestionAnswer(set<Id> setOfOppRelatedProductIds) {
		
		set<Id> setOfProductGroup = new set<Id>();
		map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
		
		for(Product2 objProduct : [	Select Id ,Product_Group__c 
									From Product2 
									Where  Id In : setOfOppRelatedProductIds] )	{
		
			setOfProductGroup.add(objProduct.Product_Group__c);
		}
		
		for(Questions__c objQuestion : [ Select Type__c, Question__c, Product_Group__c, Name ,Id
									 From Questions__c 
									 Where Product_Group__c In : setOfProductGroup]) {
									 	
		 	mapQuesId_Question.put(objQuestion.Id,objQuestion);
		}
		
		for(Answer__c objAnswer : [	Select Questions__c,Questions__r.Type__c,Questions__r.Question__c, Product__c,Product__r.Name, 
									Opportunity__c,Questions__r.Related_Picklist_Values__c,Questions__r.Name  
									From Answer__c
									Where Opportunity__c =: strOpportunityId
									AND Questions__c = : mapQuesId_Question.keySet() ]){
										
			lstOfQA_On_OpportunityWrapper.add(new QA_Wrapper(mapQuesId_Question.get(objAnswer.Questions__c),objAnswer,''));
			
		}
	}
}