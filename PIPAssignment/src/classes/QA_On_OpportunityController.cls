/**
* @ClassName    : QA_On_OpportunityController
* @CreatedOn    : 4/14/2015
* @Description  : Controller class for QA_On_OpportunityPage. Controller for assessment of associated Question and Answer for 
                  closed deal of opportunity.
*/
public with sharing class QA_On_OpportunityController {
    
    //Public get, set type Varibales
    public map<String,List<QA_Wrapper>> mapProductName_lstWrapper   {get;set;}
    public boolean pageMessage                                      {get;set;}
    public Opportunity objOpportunity                               {get;set;}
    
    //Wrapper Class
    public class QA_Wrapper {
        
        //Wrapper Class Variables
        public Questions__c objQuestion                             {get;set;}
        public Answer__c objAnswer                                  {get;set;}
        public String strQuestionType                               {get;set;}
        public List<SelectOption> lstSelectOption					{get;set;}
        public String strValueSelcted								{get;set;}
        
        //Wrapper Constructor
        public QA_Wrapper(Questions__c question, Answer__c answer, String questionType, List<SelectOption> lstSelectOption,String strValueSelcted) {
            
            objQuestion = question;
            objAnswer = answer;
            strQuestionType = questionType;
            this.lstSelectOption = lstSelectOption;
            this.strValueSelcted = strValueSelcted;
        }
    }
    
    //*Constructor
    public QA_On_OpportunityController() {
        
        //Local Variable Declaration
        map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
        set<Id> setOfOppRelatedProductIds = new set<Id>();
        String strOpportunityId ;
        
        //Public Variable initialisation
        mapProductName_lstWrapper = new map<String,List<QA_Wrapper>>(); 
        pageMessage = false;
        objOpportunity = new Opportunity();
        
        strOpportunityId = Apexpages.currentPage().getParameters().get('Id');
        
        //Check For Opportunity Id is null or not
        if(strOpportunityId == null || strOpportunityId == '' ) {
            
            pageMessage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Id does not exist'));
        }
        else {
        	
        	objOpportunity  = [ SELECT Id,ShowAnsweredCount__c,ShowBlankCount__c
                                FROM Opportunity 
                                WHERE Id = : strOpportunityId];
            
            for(OpportunityLineItem  objOLI : [ SELECT Name, OpportunityId, Product2Id
                                                FROM OpportunityLineItem 
                                                WHERE OpportunityId =: objOpportunity.Id ]) {
                                        
                setOfOppRelatedProductIds.add(objOLI.Product2Id);
            }
            
            //check for product exist related to the opportunity or not
            if(setOfOppRelatedProductIds.isEmpty()) {
            
                pageMessage = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info,'No Questions to answer yet. Please add Products to the Opportunity.'));
            }
            else {
                //calling method
                fetchProductGroupQuestionAnswer(setOfOppRelatedProductIds);
            }
        } 
    }
    
    /**
    * Name          : fetchProductGroupQuestionAnswer
    * Parameters    : setOfOppRelatedProductIds(set of Ids of related product of opportunity)
    * Description   : Fetch the opportunity related product Question and answer and bind to the Vf page.
    */
    public void fetchProductGroupQuestionAnswer(set<Id> setOfOppRelatedProductIds) {
        
        try {
            
            //Local variables
            map<Id,Questions__c> mapQuesId_Question = new map<Id,Questions__c>();
            map<Id,Id> mapProductGroupId_ProductId = new map<Id,Id>();
            map<Id,List<String>> mapQuesId_lstSelection = new map<Id,List<String>>();
            String strValueSelcted = '';
            
            for(Product2 objProduct : [ SELECT Id ,Product_Group__c 
                                        FROM Product2 
                                        WHERE  Id In : setOfOppRelatedProductIds
                                        AND Product_Group__c <> NULL] ) {
            
                mapProductGroupId_ProductId.put(objProduct.Id,objProduct.Product_Group__c);
            }
            
            for(Questions__c objQuestion : [ SELECT Type__c, Question__c, Product_Group__c, Name ,Id,Related_Picklist_Values__c 
                                             FROM Questions__c 
                                             WHERE Product_Group__c In : mapProductGroupId_ProductId.values()]) {
                                            
                mapQuesId_Question.put(objQuestion.Id,objQuestion);
                
				if(objQuestion.Type__c == 'Picklist') {
					
					List<String> lstSelectString = objQuestion.Related_Picklist_Values__c.split(',');
					mapQuesId_lstSelection.put(objQuestion.Id,lstSelectString);
				}
            }
            
            for(Answer__c objAnswer : [ SELECT Questions__c,Questions__r.Type__c,Questions__r.Question__c, Product__c,Product__r.Name, 
                                        Opportunity__c,Questions__r.Associated_Picklist_Values__c,Questions__r.Name ,Answer__c,ShowCount__c 
                                        FROM Answer__c
                                        WHERE Opportunity__c =: objOpportunity.Id
                                        AND Questions__c = : mapQuesId_Question.keySet() ]) {
                                        	
            	List<SelectOption> lstSelectOptions = new List<SelectOption>();
            	
				if(mapQuesId_lstSelection.containsKey(objAnswer.Questions__c)) {
					
    				lstSelectOptions.add(new SelectOption('', ' - Select Options' + ' -'));
					
					for(String option : mapQuesId_lstSelection.get(objAnswer.Questions__c)) {
						
						lstSelectOptions.add(new SelectOption(option, option));
					}
				}
                
                if(mapProductGroupId_ProductId.containskey(objAnswer.Product__c)){
                    
                    if(mapProductName_lstWrapper.containsKey(objAnswer.Product__r.Name)) {
                    
                        List<QA_Wrapper> lstOfQA_On_OpportunityWrapper = mapProductName_lstWrapper.get(objAnswer.Product__r.Name);
                        
                        lstOfQA_On_OpportunityWrapper.add(new QA_Wrapper(mapQuesId_Question.get(objAnswer.Questions__c),objAnswer,objAnswer.Questions__r.Type__c,lstSelectOptions,strValueSelcted));
                        
                        //map consist the product name and list of related question and answer 
                        mapProductName_lstWrapper.put(objAnswer.Product__r.Name,lstOfQA_On_OpportunityWrapper);
                        
                    } else {
                        
                        mapProductName_lstWrapper.put(objAnswer.Product__r.Name,new List<QA_Wrapper>{new QA_Wrapper(mapQuesId_Question.get(objAnswer.Questions__c),objAnswer,objAnswer.Questions__r.Type__c,lstSelectOptions,strValueSelcted)});
                    }
                }
            }
        }
        catch(Exception e) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage()+e.getLineNumber()));
        }
    }
    /**
    * Name          : SaveAnswerRecords
    * Parameters    : None
    * Description   : Update the answer records in database
    */
    public Pagereference SaveAnswerRecords() {
        
        try {
        	//Local Variable
            list<Answer__c> lstAnswerToUpdate = new list<Answer__c>();
            
            for(List<QA_Wrapper> lstWrapper : mapProductName_lstWrapper.values()) {
                
                for(QA_Wrapper objWrapper : lstWrapper) {
                    
                    if(objWrapper.objAnswer.Questions__r.Type__c == 'Picklist'){
                        	
                    	objWrapper.objAnswer.Answer__c = objWrapper.strValueSelcted;
                    }
                    
                    if(objWrapper.objAnswer.Answer__c != null &&(objWrapper.objAnswer.Answer__c != 'false') && (objWrapper.objAnswer.Answer__c != '' || objWrapper.objAnswer.Answer__c == 'true')) {
                        
                        objWrapper.objAnswer.ShowCount__c = true;
                    }
                    else {
                        
                        objWrapper.objAnswer.ShowCount__c = false;
                    }
                    lstAnswerToUpdate.add(objWrapper.objAnswer);
                }
            }
            
            //Update the Answer records
            if(!lstAnswerToUpdate.isEmpty()) {
                
                update lstAnswerToUpdate;
            }
            
            //Redirect page to the opportunity detail page
            PageReference objPageReference = new PageReference('/' + objOpportunity.Id);
            return objPageReference;
        }
        catch(Exception e) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage()+e.getLineNumber()));
            return null;
        }
    }
    
    /**
    * Name          : cancelAnswerRecords
    * Parameters    : None
    * Description   : cancel all the process
    */
    public Pagereference cancelAnswerRecords() {
        
        PageReference objPageReference = new PageReference('/' + objOpportunity.Id);
        return objPageReference;
    }
}