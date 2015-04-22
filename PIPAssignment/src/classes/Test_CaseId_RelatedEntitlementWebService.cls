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
@isTest
private class Test_CaseId_RelatedEntitlementWebService {

    static testMethod void myUnitTest() {
        
        Account objAccount = new Account(   Name = 'Test Account',
                                            Phone = '354565768'
                                            );
                                            
        insert objAccount;
        
        Account objAccount1 = new Account(  Name = 'Test Account1',
                                            Phone = '76537435684',
                                            AccountNumber = objAccount.Id);
                                            
        insert objAccount1;
        
        Case objCase = new Case( AccountId = objAccount1.Id,
                                 Status = 'Closed', 
                                 Origin = 'Phone'
                                );
        
        insert objCase;
        
        Case objCase1 = new Case( AccountId = objAccount.Id,
                                 Status = 'Closed',
                                 Origin = 'Phone'
                                );
        
        insert objCase1;
        
        Case objCase2 = new Case( 
                                 Status = 'Closed',
                                 Origin = 'Phone'
                                );
        
        insert objCase2;
        
        List<Contact> lstContact = new List<Contact>();
        
        Contact objContact = new Contact(   LastName = 'Test Contact',
                                            AccountId = objAccount1.Id,
                                            Phone = '12323435456',
                                            Department = 'Testing',
                                            Email = 'Test@trekbin.com' );
        
        lstContact.add(objContact);     
        
        Contact objContact1 = new Contact(  LastName = 'Test Contact1',
                                            AccountId = objAccount1.Id,
                                            Phone = '3454657868',
                                            Department = 'Analysis',
                                            Email = 'Testing@trekbin.com' );
        lstContact.add(objContact1);
        
        Contact objContact2 = new Contact(  LastName = 'Test Contact2',
                                            AccountId = objAccount.Id,
                                            Phone = '3454657868',
                                            Department = 'Analysis',
                                            Email = 'Testing@trekbin.com' );
        lstContact.add(objContact2);
        
        insert lstContact;
        
        List<Asset> lstAsset = new List<Asset>();
        
        Asset objAsset = new Asset (    Name = 'Test Asset',
                                        Status = '',
                                        Quantity = 1, 
                                        Price = 100, 
                                        AccountId = objAccount1.Id );
                                        
        lstAsset.add(objAsset);
        
        Asset objAsset1 = new Asset (   Name = 'Test Asset1',
                                        Status = '',
                                        Quantity = 1, 
                                        Price = 100, 
                                        AccountId = objAccount1.Id );
                                        
        lstAsset.add(objAsset1);
        
        Asset objAsset2 = new Asset (   Name = 'Test Asset2',
                                        Status = '',
                                        Quantity = 1, 
                                        Price = 100, 
                                        AccountId = objAccount.Id );
                                        
        lstAsset.add(objAsset2);
        
        insert lstAsset;
        
        List<Entitlement> lstEntitlement = new List<Entitlement>();
        
        Entitlement objEntitlement = new Entitlement( Type = 'Phone Support', 
                                                      StartDate = date.today(),
                                                      EndDate = date.today(),
                                                      Name = 'Test Entitlement', 
                                                      IsPerIncident = true, 
                                                      AccountId = objAccount1.Id,
                                                      RemainingCases = 0,
                                                      CasesPerEntitlement = 2 );
        
        lstEntitlement.add(objEntitlement);
        
        Entitlement objEntitlement1 = new Entitlement( Type = 'Phone Support', 
                                                       StartDate = date.today(),
                                                       EndDate = date.today(),
                                                       Name = 'Test Entitlement1', 
                                                       IsPerIncident = false, 
                                                       AccountId = objAccount.Id);
        
        lstEntitlement.add(objEntitlement1);
        
        insert lstEntitlement;
        
        //When Phone NO of Contact is matched and Account Number field is not contain the given account number 
        CaseId_RelatedEntitlementsController objCaseId_RelatedEntitlements = new CaseId_RelatedEntitlementsController();
        
        CaseId_RelatedEntitlementsController.getCaseRelatedRecords('','3454657868',objAccount1.Id);
        
        //When Phone NO of Contact is matched ,Account Number is null and then fetch all case related records
        CaseId_RelatedEntitlementsController objCaseId_RelatedEntitlements1 = new CaseId_RelatedEntitlementsController();
        
        CaseId_RelatedEntitlementsController.getCaseRelatedRecords(objCase1.Id,'3454657868','');
        
        //When Phone NO of Contact is matched and Account Number field contain the given account number 
        CaseId_RelatedEntitlementsController objCaseId_RelatedEntitlements2 = new CaseId_RelatedEntitlementsController();
        
        CaseId_RelatedEntitlementsController.getCaseRelatedRecords('','3454657868',objAccount.Id);
    }
}