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

    static testMethod void TestQAOnOpportunity() {
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity objOpportunity1 = new Opportunity(	Name = 'Test Opportunity 001',
														StageName = 'Closed',
        												CloseDate = Date.today()
        											);
		lstOpportunity.add(objOpportunity1);
		Opportunity objOpportunity2 = new Opportunity(	Name = 'Test Opp 002',
														StageName = 'Closed',
        												CloseDate = Date.today()
        											);
		lstOpportunity.add(objOpportunity2);
		
		insert lstOpportunity;
		
		List<Product2> lstProduct = new List<Product2>();
		Product2 objProduct = new Product2( Name ='Alto',
									        ProductCode ='P001',
									        IsActive = true
									      );
        lstProduct.add(objProduct);
        
        Product2 objProduct1 = new Product2( Name = 'Spice',
									         ProductCode = 'S001',
									         IsActive = true
									     	);
     	lstProduct.add(objProduct1);
     	
        insert lstProduct;
        
        Pricebook2 objPBE = ([select Id from Pricebook2 where IsActive = true AND IsStandard=true limit 1 ]);
        
		Pricebook2 objPricebook=new Pricebook2();
		objPricebook.Name='Test';
		objPricebook.IsActive=true;
		insert objPricebook;
        
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>();
        PriceBookEntry objPBEMobile = new PriceBookEntry( Pricebook2Id = objPBE.Id ,
        												  Product2Id = objProduct1.Id,
        												  UseStandardPrice = false,
        												  UnitPrice = 100,
        												  IsActive = true
        												);
        lstPriceBookEntry.add(objPBEMobile);
        
		PriceBookEntry objPBEVehicle = new PriceBookEntry(	Pricebook2Id = objPBE.Id ,
															Product2Id = objProduct.Id,
															UseStandardPrice = false,
															UnitPrice = 100,
															IsActive = true
														 );
		lstPriceBookEntry.add(objPBEVehicle);	
		insert lstPriceBookEntry;
		
		List<Product_Group__c> lstProductGroup = new List<Product_Group__c>();
		
		Product_Group__c objProductGroup = new Product_Group__c ( Name = 'PG001');
		lstProductGroup.add(objProductGroup);
		
		Product_Group__c objProductGroup1 = new Product_Group__c ( Name = 'PG002');
		lstProductGroup.add(objProductGroup1);
		
		insert lstProductGroup;
		
		List<Questions__c> lstQuestion = new List<Questions__c>();
		
		Questions__c objQuestion1 = new Questions__c ( Product_Group__c = objProductGroup.Id,
													   Type__c = 'Text',
													   Question__c = 'This is a Sample Question1?'
													);
		lstQuestion.add(objQuestion1);
		
		Questions__c objQuestion2 = new Questions__c ( Product_Group__c = objProductGroup.Id,
													   Type__c = 'Checkbox',
													   Question__c = 'This is a Sample Question2?'
													);
													
		lstQuestion.add(objQuestion2);
		insert lstQuestion;
		
		OpportunityLineItem objOLI = new OpportunityLineItem( UnitPrice = objPBEMobile.UnitPrice,
													          OpportunityId = objOpportunity1.Id,
													          PricebookEntryId = objPBEMobile.Id,
													          Quantity = 1
         													);
        insert objOLI;								
        
        
    }
}