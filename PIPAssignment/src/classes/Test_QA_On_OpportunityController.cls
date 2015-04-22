/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData = true)
private class Test_QA_On_OpportunityController {
    
    /**
    * Name          : TestQAOnOpportunityTrigger
    * Description   : Test the functionality of Oli Trigger 
    */
    static testMethod void TestQAOnOpportunityTrigger() {
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        Opportunity objOpportunity1 = new Opportunity(  Name = 'Test Opportunity 001',
                                                        StageName = 'Closed',
                                                        CloseDate = Date.today()
                                                    );
                                                    
        lstOpportunity.add(objOpportunity1);
        
        Opportunity objOpportunity2 = new Opportunity(  Name = 'Test Opp 002',
                                                        StageName = 'Closed',
                                                        CloseDate = Date.today()
                                                    );
                                                    
        lstOpportunity.add(objOpportunity2); 
        
        insert lstOpportunity;
        
        List<Product_Group__c> lstProductGroup = new List<Product_Group__c>();
        
        Product_Group__c objProductGroup = new Product_Group__c ( Name = 'PG001');
        
        lstProductGroup.add(objProductGroup);
        
        Product_Group__c objProductGroup1 = new Product_Group__c ( Name = 'PG002');
        
        lstProductGroup.add(objProductGroup1);
        
        insert lstProductGroup;
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 objProduct = new Product2( Name ='Alto',
                                            ProductCode ='P001',
                                            IsActive = true,
                                            Product_Group__c = objProductGroup.Id
                                          );
                                          
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = new Product2( Name = 'Spice',
                                             ProductCode = 'S001',
                                             IsActive = true,
                                             Product_Group__c = objProductGroup1.Id
                                            );
                                            
        lstProduct.add(objProduct1);
        
        insert lstProduct;
        
        Pricebook2 objPBE = ([select Id from Pricebook2 where IsActive = true AND IsStandard = true limit 1 ]);
        
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>();
        
        PriceBookEntry objPBEMobile = new PriceBookEntry( Pricebook2Id = objPBE.Id ,
                                                          Product2Id = objProduct1.Id,
                                                          UseStandardPrice = false,
                                                          UnitPrice = 100,
                                                          IsActive = true
                                                        );
                                                        
        lstPriceBookEntry.add(objPBEMobile);
        
        PriceBookEntry objPBEVehicle = new PriceBookEntry(  Pricebook2Id = objPBE.Id ,
                                                            Product2Id = objProduct.Id,
                                                            UseStandardPrice = false,
                                                            UnitPrice = 100,
                                                            IsActive = true
                                                         );
                                                         
        lstPriceBookEntry.add(objPBEVehicle);   
        
        insert lstPriceBookEntry;
        
        List<Questions__c> lstQuestion = new List<Questions__c>();
        
        Questions__c objQuestion1 = new Questions__c ( Product_Group__c = objProductGroup1.Id,
                                                       Type__c = 'Checkbox',
                                                       Question__c = 'This is a Sample Question1?'
                                                       
                                                    );
        lstQuestion.add(objQuestion1);
        
        Questions__c objQuestion2 = new Questions__c ( Product_Group__c = objProductGroup1.Id,
                                                       Type__c = 'Checkbox',
                                                       Question__c = 'This is a Sample Question2?',
                                                       Related_Picklist_Values__c = 'Test1,Test2,Test3'
                                                    );
                                                    
        lstQuestion.add(objQuestion2);
        
        Questions__c objQuestion3 = new Questions__c ( Product_Group__c = objProductGroup.Id,
                                                       Type__c = 'Picklist',
                                                       Question__c = 'This is a Sample Question3?',
                                                       Related_Picklist_Values__c = 'Test1,Test2,Test3'
                                                    );
                                                    
        lstQuestion.add(objQuestion3);
        
        Questions__c objQuestion4 = new Questions__c ( Product_Group__c = objProductGroup.Id,
                                                       Type__c = 'Text',
                                                       Question__c = 'This is a Sample Question4?'
                                                    );
                                                    
        lstQuestion.add(objQuestion4);
        
        insert lstQuestion;
        
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        
        OpportunityLineItem objOLI = new OpportunityLineItem( UnitPrice = objPBEMobile.UnitPrice,
                                                              OpportunityId = objOpportunity1.Id,
                                                              PricebookEntryId = objPBEMobile.Id,
                                                              Quantity = 1
                                                            );
                                                            
        lstOpportunityLineItem.add(objOLI);
        
        OpportunityLineItem objOLI1 = new OpportunityLineItem( UnitPrice = objPBEMobile.UnitPrice,
                                                               OpportunityId = objOpportunity2.Id,
                                                               PricebookEntryId = objPBEVehicle.Id,
                                                               Quantity = 1
                                                            );
                                                            
        lstOpportunityLineItem.add(objOLI1);    
        
        insert  lstOpportunityLineItem  ;   
        
        List<Answer__c> lstAnswer = new List<Answer__c>([SELECT Id,Product__r.Name,Questions__r.Question__c FROM Answer__c WHERE Opportunity__c In : lstOpportunity  ]);    
                
        //***SUCCESS*** : No of inserted Answer records are 4
        system.assertEquals(lstAnswer.size(),4);
        
        //***Success**: Two answer are created to related to one opportunity 
        List<Answer__c> lstAnswerOfProduct = new List<Answer__c>([SELECT Id,Opportunity__c,Questions__r.Question__c,Product__c,Product__r.Name FROM Answer__c WHERE Opportunity__c =: lstOpportunity[0].Id AND Questions__c =: lstQuestion]);
        
        system.assertEquals(lstAnswerOfProduct.size(),2);
        
        //***Success**: Product Name related to that answer is 'Spice'
        system.assertEquals(lstAnswerOfProduct[0].Product__r.Name,'Spice');
        
        //***Success**: Question Name related to that answer is 'This is a Sample Question2?'
        system.assertEquals(lstAnswerOfProduct[0].Questions__r.Question__c,'This is a Sample Question2?');
    }
    
    /**
    * Name          : TestQAOnOpportunityController
    * Description   : Test the functionality of OLI Controller and vf page
    */
    static testMethod void TestQAOnOpportunityController() {
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        
        Opportunity objOpportunity1 = new Opportunity(  Name = 'Test Opportunity 001',
                                                        StageName = 'Closed',
                                                        CloseDate = Date.today()
                                                    );
                                                    
        lstOpportunity.add(objOpportunity1);
        
        Opportunity objOpportunity2 = new Opportunity(  Name = 'Test Opp 002',
                                                        StageName = 'Closed',
                                                        CloseDate = Date.today()
                                                    );
                                                    
        lstOpportunity.add(objOpportunity2);
        
        insert lstOpportunity;
        
        List<Product_Group__c> lstProductGroup = new List<Product_Group__c>();
        
        Product_Group__c objProductGroup = new Product_Group__c ( Name = 'PG001');
        
        lstProductGroup.add(objProductGroup);
        
        Product_Group__c objProductGroup1 = new Product_Group__c ( Name = 'PG002');
        
        lstProductGroup.add(objProductGroup1);
        
        insert lstProductGroup;
        
        List<Product2> lstProduct = new List<Product2>();
        
        Product2 objProduct = new Product2( Name ='Alto',
                                            ProductCode ='P001',
                                            IsActive = true,
                                            Product_Group__c = objProductGroup.Id
                                          );
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = new Product2( Name = 'Spice',
                                             ProductCode = 'S001',
                                             IsActive = true,
                                             Product_Group__c = objProductGroup1.Id
                                            );
        lstProduct.add(objProduct1);
        
        insert lstProduct;
        
        Pricebook2 objPBE = ([select Id from Pricebook2 where IsActive = true AND IsStandard=true limit 1 ]);

        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>();
        
        PriceBookEntry objPBEMobile = new PriceBookEntry( Pricebook2Id = objPBE.Id ,
                                                          Product2Id = objProduct1.Id,
                                                          UseStandardPrice = false,
                                                          UnitPrice = 100,
                                                          IsActive = true
                                                        );
                                                        
        lstPriceBookEntry.add(objPBEMobile);
        
        PriceBookEntry objPBEVehicle = new PriceBookEntry(  Pricebook2Id = objPBE.Id ,
                                                            Product2Id = objProduct.Id,
                                                            UseStandardPrice = false,
                                                            UnitPrice = 100,
                                                            IsActive = true
                                                         );
                                                         
        lstPriceBookEntry.add(objPBEVehicle);   
        
        insert lstPriceBookEntry;
        
        List<Questions__c> lstQuestion = new List<Questions__c>();
        
        Questions__c objQuestion1 = new Questions__c ( Product_Group__c = objProductGroup1.Id,
                                                       Type__c = 'Text',
                                                       Question__c = 'This is a Sample Question1?'
                                                    );
                                                    
        lstQuestion.add(objQuestion1);
        
        Questions__c objQuestion2 = new Questions__c ( Product_Group__c = objProductGroup1.Id,
                                                       Type__c = 'Checkbox',
                                                       Question__c = 'This is a Sample Question2?'
                                                    );
                                                    
        lstQuestion.add(objQuestion2);
        
        Questions__c objQuestion3 = new Questions__c ( Product_Group__c = objProductGroup.Id,
                                                       Type__c = 'Text',
                                                       Question__c = 'This is a Sample Question3?'
                                                    );
                                                    
        lstQuestion.add(objQuestion3);
        
        Questions__c objQuestion4 = new Questions__c ( Product_Group__c = objProductGroup.Id,
                                                       Type__c = 'Text',
                                                       Question__c = 'This is a Sample Question4?'
                                                    );
                                                    
        lstQuestion.add(objQuestion4);
        
        insert lstQuestion;
        
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        
        OpportunityLineItem objOLI = new OpportunityLineItem( UnitPrice = objPBEMobile.UnitPrice,
                                                              OpportunityId = objOpportunity1.Id,
                                                              PricebookEntryId = objPBEMobile.Id,
                                                              Quantity = 1
                                                            );
                                                            
        lstOpportunityLineItem.add(objOLI);
        
        OpportunityLineItem objOLI1 = new OpportunityLineItem( UnitPrice = objPBEMobile.UnitPrice,
                                                               OpportunityId = objOpportunity2.Id,
                                                               PricebookEntryId = objPBEVehicle.Id,
                                                               Quantity = 1
                                                            );
                                                            
        lstOpportunityLineItem.add(objOLI1);    
        
        insert  lstOpportunityLineItem  ;   
        
        //Inserted Ansewr Records
        
        List<Answer__c> lstAnswerOfProduct = new List<Answer__c>([  SELECT Id,Answer__c,Opportunity__c,Opportunity__r.ShowAnsweredCount__c,Questions__r.Question__c,Product__c,Product__r.Name,Questions__r.Type__c 
                                                                    FROM Answer__c 
                                                                    WHERE Opportunity__c =: lstOpportunity[0].Id 
                                                                    AND Questions__c =: lstQuestion]);
        
        //Update the Answer Records Answer Value
        lstAnswerOfProduct[0].Answer__c = 'Testing';
         
        update lstAnswerOfProduct[0];
        
        Test.StartTest();
        
        ApexPages.currentPage().getParameters().put('Id','');
        
        //**SUCCESS : check when Id is NULL in url
        QA_On_OpportunityController objTest1 = new QA_On_OpportunityController();
        
        ApexPages.currentPage().getParameters().put('Id',objOpportunity1.id);
        
        //**Success : check when Opportunity Id is not null in url
        QA_On_OpportunityController objTest = new QA_On_OpportunityController();
        
        //update the text Field value
        lstAnswerOfProduct[0].Answer__c = 'Testing Answer After Save';
        
        //Update the checkbox answer value
        lstAnswerOfProduct[1].Answer__c = 'true';
        
        //calling save method
        objTest.SaveAnswerRecords();
        
        //**SUCCESS : Updated value of question from the vf page on save
        system.assertEquals(lstAnswerOfProduct[0].Answer__c,'Testing Answer After Save');
        
        Opportunity objOpportunity = [  SELECT Id, ShowAnsweredCount__c
                                        FROM Opportunity
                                        WHERE Id = : objOpportunity1.Id ];
        
        //**SUCCESS : check for the No of Answered Question 
        system.assertEquals(objOpportunity.ShowAnsweredCount__c,1);
        
        //Calling cancel method
        objTest.cancelAnswerRecords();
        
        Test.StopTest();
    }
}