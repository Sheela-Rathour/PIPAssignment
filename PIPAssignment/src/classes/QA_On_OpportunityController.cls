/**
* @ClassName    : QA_On_OpportunityController
* @CreatedOn    : 4/14/2015
* @Description  : Controller class for QA_On_OpportunityPage. Controller for assessment of associated Question and Answer for closed deal of opportunity.
*/
public with sharing class QA_On_OpportunityController {
	
	//Public Varibales
	public map<String,List<QA_Wrapper>> mapProductName_lstWrapper 	{get;set;}
	public boolean pageMessage										{get;set;}
	public List<SelectOption> lstSelectOption						{get;set;}
	public List<SelectOption> lstAssociatedSelectOption				{get;set;}
	public String strValueSelcted									{get;set;}
	public String strOpportunityId;
	
	//Wrapper Class
	public class QA_Wrapper	{
		
		public Questions__c objQuestion 							{get;set;}
		public Answer__c objAnswer									{get;set;}
		public String strQuestionType								{get;set;}
		
		//Wrapper Constructor
		public QA_Wrapper(Questions__c question, Answer__c answer, String questionType) {
		
			objQuestion = question;
			objAnswer = answer;
			strQuestionType = questionType;
		}
	}
	
	//*Constructor
	public QA_On_OpportunityController(apexPages.standardController objOpportunity) {
		
		map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
		mapProductName_lstWrapper = new map<String,List<QA_Wrapper>>(); 
		set<Id> setOfOppRelatedProductIds = new set<Id>();
		lstSelectOption =  new list<SelectOption>();  
		pageMessage = false;
		
		strOpportunityId = Apexpages.currentPage().getParameters().get('Id');
		
		Schema.DescribeFieldResult QuestionrelatedPicklist = Questions__c.Related_Picklist_Values__c.getDescribe();

		List<Schema.PicklistEntry> lstOfQuestions_PicklistEntry = QuestionrelatedPicklist.getPicklistValues();
		
		SelectOption firstOption = new SelectOption('', ' - Select Options' + ' -');
	     
		lstSelectOption.add(firstOption);
		
		for (Schema.PicklistEntry selectPickListValues : lstOfQuestions_PicklistEntry) { //for all values in the picklist list
	      
			lstSelectOption.add(new SelectOption(selectPickListValues.getValue(),selectPickListValues.getValue()));
		}
		
		if(strOpportunityId == null) {
			
		    pageMessage = true;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Id Is Null'));
		}
		else {
			
		    for(OpportunityLineItem  objOLI : [	SELECT Name,OpportunityId, Product2Id
 	     									   	FROM OpportunityLineItem 
         								       	WHERE OpportunityId =: strOpportunityId ]) {
 	   					  			  	
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
	
	/**
	* Name			: fetchProductGroupQuestionAnswer
	* Parameters	: setOfOppRelatedProductIds(set of Ids of related product of opportunity)
	* Description 	: Fetch the opportunity related product Question and answer and bind to the Vf page.
	*/
	public void fetchProductGroupQuestionAnswer(set<Id> setOfOppRelatedProductIds) {
		
		try {
			
			map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
			map<Id,Id> mapProductGroupId_ProductId = new map<Id,Id>();
			
			for(Product2 objProduct : [	SELECT Id ,Product_Group__c 
										FROM Product2 
										WHERE  Id In : setOfOppRelatedProductIds
										AND Product_Group__c <> NULL] )	{
			
				mapProductGroupId_ProductId.put(objProduct.Id,objProduct.Product_Group__c);
			}
			
			for(Questions__c objQuestion : [ SELECT Type__c, Question__c, Product_Group__c, Name ,Id
										 	 FROM Questions__c 
										  	 WHERE Product_Group__c In : mapProductGroupId_ProductId.values()]) {
										 	
			 	mapQuesId_Question.put(objQuestion.Id,objQuestion);
			}
			
			for(Answer__c objAnswer : [	SELECT Questions__c,Questions__r.Type__c,Questions__r.Question__c, Product__c,Product__r.Name, 
										Opportunity__c,Questions__r.Related_Picklist_Values__c,Questions__r.Name ,Answer__c,ShowCount__c,Questions__r.Associated_Picklist_Values__c 
										FROM Answer__c
										WHERE Opportunity__c =: strOpportunityId
										AND Questions__c = : mapQuesId_Question.keySet() ]) {
				
				if(mapProductGroupId_ProductId.containskey(objAnswer.Product__c)){
					
					if(mapProductName_lstWrapper.containsKey(objAnswer.Product__r.Name)) {
					
						List<QA_Wrapper> lstOfQA_On_OpportunityWrapper = mapProductName_lstWrapper.get(objAnswer.Product__r.Name);
						lstOfQA_On_OpportunityWrapper.add(new QA_Wrapper(mapQuesId_Question.get(objAnswer.Questions__c),objAnswer,objAnswer.Questions__r.Type__c));
						mapProductName_lstWrapper.put(objAnswer.Product__r.Name,lstOfQA_On_OpportunityWrapper);
						
					} else {
						
						mapProductName_lstWrapper.put(objAnswer.Product__r.Name,new List<QA_Wrapper>{new QA_Wrapper(mapQuesId_Question.get(objAnswer.Questions__c),objAnswer,objAnswer.Questions__r.Type__c)});
					}
				}
			}
		}
		catch(Exception e) {
    	
    		system.debug('==========Exception==============='+e.getLineNumber());
    	}
	}
	/**
	* Name			: SaveAnswerRecords
	* Parameters	: None
	* Description 	: Update the answer records in database
	*/
	public Pagereference SaveAnswerRecords() {
		
		try {
			list<Answer__c> lstAnswerToUpdate = new list<Answer__c>();
			
			for(List<QA_Wrapper> lstWrapper : mapProductName_lstWrapper.values()) {
				
				for(QA_Wrapper objWrapper : lstWrapper) {
					
					if(objWrapper.objAnswer.Answer__c != null &&(objWrapper.objAnswer.Answer__c != 'false') && (objWrapper.objAnswer.Answer__c != '' || objWrapper.objAnswer.Answer__c == 'true')) {
						
						objWrapper.objAnswer.ShowCount__c = true;
					}
					else {
						
						objWrapper.objAnswer.ShowCount__c = false;
					}
					
					lstAnswerToUpdate.add(objWrapper.objAnswer);
				}
			}
			if(!lstAnswerToUpdate.isEmpty()) {
				
				update lstAnswerToUpdate;
			}
			
			PageReference objPageReference = new PageReference('/' + strOpportunityId);
			return objPageReference;
		}
		catch(Exception e) {
    	
    		system.debug('==========Exception==============='+e.getLineNumber());
    		return null;
    	}
	}
	
	/**
	* Name			: cancelAnswerRecords
	* Parameters	: None
	* Description 	: cancel all the process
	*/
	public Pagereference cancelAnswerRecords() {
		
		PageReference objPageReference = new PageReference('/' + strOpportunityId);
		return objPageReference;
	}
}