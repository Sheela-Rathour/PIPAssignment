/**
* @ClassName    : CaseId_RelatedEntitlementsController
* @CreatedOn    : 4/20/2015
* @Description  : Controller for fetching the record related to the given CaseId
*/

global class CaseId_RelatedEntitlementsController {
	
	/**
	* @ClassName    : AccountWrapper
	* @CreatedOn    : 4/20/2015
	* @Description  : Wrapper class contains the Account related info and list of Contact,Asset and entitlement wrapper 
	*/
	global class AccountWrapper {
		
		//Wrapper class variable
		webservice List<ContactWrapper> lstContactWrapper;	
		webservice List<AssetWrapper> lstAssetWrapper;	
		webservice List<EntitlementWrapper> lstEntitlementWrapper;			
		webservice string Fax;						
		webservice String Phone	;					
		webservice string Name;					
		webservice string Id;
		webservice string errorMessage; 						
		
		//AccountWrapper Constructor
		global AccountWrapper(string Fax, String Phone , string Name,string Id,List<ContactWrapper> lstContactWrapper,List<AssetWrapper> lstAssetWrapper, List<EntitlementWrapper> lstEntitlementWrapper,string errorMessage) {
		    
		    this.Fax = Fax;
		    this.Phone = Phone;
		    this.Name = Name;
		    this.Id = Id;
		    this.lstContactWrapper = lstContactWrapper;
		    this.lstAssetWrapper = lstAssetWrapper;
		    this.lstEntitlementWrapper = lstEntitlementWrapper;
		    this.errorMessage = errorMessage;
		}
	}
	
	/**
	* @ClassName    : ContactWrapper
	* @CreatedOn    : 4/20/2015
	* @Description  : Wrapper class contains the Contact related Field  
	*/
	global class ContactWrapper {
		
		//Contact Wrapper variables
		webservice string AccountId	;				
		webservice string conName;					
		webservice string Email;					
		webservice string Department ;	
		
		//ContactWrapper Constructor
		global ContactWrapper(string AccountId, string conName, string Email,string Department ) {
		    
		    this.AccountId = AccountId;
		    this.conName = conName;
		    this.Email = Email;
		    this.Department = Department;
		}		
	}
	
	/**
	* @ClassName    : AssetWrapper
	* @CreatedOn    : 4/20/2015
	* @Description  : Wrapper class contains the Assets related Field  
	*/
	global class AssetWrapper {
		
		//AssetWrapper Variables
		webservice string AssetName;				
		webservice string AsstStatus;					
		webservice Decimal AsstPrice;					
		webservice Decimal AsstQuantity;
		webservice string AccountId;
		
		//AssetWrapper Constructor
		global AssetWrapper(string AssetName, string AsstStatus, Decimal AsstPrice,Decimal AsstQuantity,String AccountId) {
		    
		    this.AssetName = AssetName;
		    this.AsstStatus = AsstStatus;
		    this.AsstPrice = AsstPrice;
		    this.AsstQuantity = AsstQuantity;
		    this.AccountId = AccountId;
		}	
	}
	
	/**
	* @ClassName    : EntitlementWrapper
	* @CreatedOn    : 4/20/2015
	* @Description  : Wrapper class contains the Entitlement related Field  
	*/
	global class EntitlementWrapper {
		
		//EntitlementWrapper Variable
		webservice string EntitlementName;				
		webservice string EntitlementAccountId;					
		webservice String EntitlementType;					
		webservice Boolean EntitlementIsPerIncident;
		webservice String EntitlementStatus;
		
		//EntitlementWrapper Constructor
		global EntitlementWrapper(string EntitlementName, string EntitlementAccountId,String EntitlementType,Boolean EntitlementIsPerIncident,String EntitlementStatus) {
		    
		    this.EntitlementName = EntitlementName;
		    this.EntitlementAccountId = EntitlementAccountId;
		    this.EntitlementType = EntitlementType;
		    this.EntitlementIsPerIncident = EntitlementIsPerIncident;
		    this.EntitlementStatus = EntitlementStatus;
		}	
	}
	
	/**
	* @MethodName   : getCaseRelatedRecords
	* @CreatedOn	: 4/20/2015
	* @Parameters	: String CaseId, String PhoneNo
	* @Description  : fetching all the records associated with the account related to given caseId and Contact related to the given phone no 
	*/
	webservice static AccountWrapper getCaseRelatedRecords(String CaseId, String PhoneNo) {
		
		try {
			
			//Local Variables
			List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();
			List<AssetWrapper> lstAssetWrapper = new List<AssetWrapper>();
			List<EntitlementWrapper> lstEntitlementWrapper = new List<EntitlementWrapper>();
			AccountWrapper objAccountWrapper ;
			
			//fetch Account related to the given caseId
			List<Case> lstCase = [  SELECT Account.Fax, Account.Phone, Account.Name, Account.Id, AccountId, Account.AccountNumber  
							 		FROM Case 
							 		WHERE Id =: CaseId limit 1];			
			
			//check for Case is exist or not related to the given caseId				  
			if(!lstCase.isEmpty()) {
				
				//check for associated Account Number field of account is empty or not. if Empty, Fetch all the related contact,assets ,Entitlement records based on the AccountId
				if(lstCase[0].Account.AccountNumber == null || lstCase[0].Account.AccountNumber == '') {
					
					
					List<Account> lstAccount = [ SELECT Phone, Name, Id, AccountNumber 
												 FROM Account
												 WHERE Id = : lstCase[0].AccountId 
												 limit 1];
					
					//check for Account is exist or not related to the accountId							 
					if(!lstAccount.isEmpty()) {
						
						List<Contact> lstContact = [ SELECT Name, Email, Department, AccountId,phone
													 FROM Contact
													 WHERE AccountId = : lstAccount[0].Id
													 AND phone =: PhoneNo];
						
					 	if(!lstContact.isEmpty()) {
					 		
					 		for(Contact objContact : lstContact) {
					 			
					 			lstContactWrapper.add(new ContactWrapper(objContact.AccountId, objContact.Name, objContact.Email, objContact.Department));
					 		}
					 	}
					 	
					 	List<Asset> lstAssets = [ SELECT Status, Quantity, Price, Name, AccountId 
					 							  FROM Asset
					 							  WHERE AccountId =: lstAccount[0].Id];
		 				if(!lstAssets.isEmpty()) {
		 					
		 					for(Asset objAsset : lstAssets) {
		 						
		 						lstAssetWrapper.add(new AssetWrapper(objAsset.Name,objAsset.Status,objAsset.Price,objAsset.Quantity,objAsset.AccountId));
		 					}
		 				}
		 				
		 				List<Entitlement> lstEntitlement = [  SELECT Type, Status, Name, IsPerIncident, AccountId 
		 													  FROM Entitlement
		 													  WHERE AccountId =: lstAccount[0].Id];
		 				if(!lstEntitlement.isEmpty()) {
		 					 
		 					for(Entitlement objEntitlement : lstEntitlement ) {
		 						 
		 						lstEntitlementWrapper.add(new EntitlementWrapper(objEntitlement.Name,objEntitlement.AccountId,objEntitlement.Type,objEntitlement.IsPerIncident,objEntitlement.Status));
		 					}
		 				}
		 				objAccountWrapper = new AccountWrapper(lstCase[0].Account.Fax,lstCase[0].Account.Phone,lstCase[0].Account.Name,lstCase[0].Account.Id ,lstContactWrapper,lstAssetWrapper,lstEntitlementWrapper,'');
					}
					else {
						
						//If Account is not exist related to the AccountId then display the error message
						objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,'Invalid Account Id');
					}
				}
				else {
					
					List<Account> lstAccount = [ SELECT Phone, Name, Id, AccountNumber 
												 FROM Account
												 WHERE Id = : lstCase[0].Account.AccountNumber  
												 limit 1 ];
					
					if(!lstAccount.isEmpty()) {
						
						List<Contact> lstContact = [ SELECT Name, Email, Department, AccountId,phone
													 FROM Contact
													 WHERE AccountId = : lstAccount[0].Id
													 AND phone =: PhoneNo];
						
					 	if(!lstContact.isEmpty()) {
					 		
					 		for(Contact objContact : lstContact) {
					 			
					 			lstContactWrapper.add(new ContactWrapper(objContact.AccountId, objContact.Name, objContact.Email, objContact.Department));
					 		}
					 	}
					 	List<Asset> lstAssets = [ SELECT Status, Quantity, Price, Name, AccountId 
					 							  FROM Asset
					 							  WHERE AccountId =: lstCase[0].Account.AccountNumber];
		 				if(!lstAssets.isEmpty()) {
		 					
		 					for(Asset objAsset : lstAssets) {
		 						
		 						lstAssetWrapper.add(new AssetWrapper(objAsset.Name,objAsset.Status,objAsset.Price,objAsset.Quantity,objAsset.AccountId));
		 					}
		 				}
		 				List<Entitlement> lstEntitlement = [  SELECT Type, Status, Name, IsPerIncident, AccountId 
		 													  FROM Entitlement
		 													  WHERE AccountId =: lstCase[0].Account.AccountNumber];
		 				if(!lstEntitlement.isEmpty()) {
		 					 
		 					for(Entitlement objEntitlement : lstEntitlement ) {
		 						 
		 						lstEntitlementWrapper.add(new EntitlementWrapper(objEntitlement.Name,objEntitlement.AccountId,objEntitlement.Type,objEntitlement.IsPerIncident,objEntitlement.Status));
		 					}
		 				}
		 				objAccountWrapper = new AccountWrapper(lstCase[0].Account.Fax,lstCase[0].Account.Phone,lstCase[0].Account.Name,lstCase[0].Account.Id ,lstContactWrapper,lstAssetWrapper,lstEntitlementWrapper,'');
					}
					else {
						//When the Account Number Field value i account is not Valid then show the error Message
						objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,'Invalid Account Number');
					}
				}
			}
			else {
				//When the Case record is not exist related to the given case Id
				objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,'Invalid Case Id');
			}
			return objAccountWrapper;
		}
		catch(Exception e) {
			
            AccountWrapper objAccountWrapper ;
            objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,e.getMessage());
            return objAccountWrapper;
        }
	}
}