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
		
		//Wrapper class variable Contains Account and List Of contact,asset and entitlement
		webservice List<ContactWrapper> lstContactWrapper;
		webservice List<AssetWrapper> lstAssetWrapper;
		webservice List<EntitlementWrapper> lstEntitlementWrapper;
		webservice string AccountFax;
		webservice String AccountPhone;
		webservice string AccountName;
		webservice string AccountId;
		webservice string errorMessage;
		
		//AccountWrapper Constructor
		global AccountWrapper(string AccountFax, String AccountPhone , string AccountName,string AccountId,List<ContactWrapper> lstContactWrapper,List<AssetWrapper> lstAssetWrapper, List<EntitlementWrapper> lstEntitlementWrapper,string errorMessage) {
			
			this.AccountFax = AccountFax;
			this.AccountPhone = AccountPhone;
			this.AccountName = AccountName;
			this.AccountId = AccountId;
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
		webservice string ContactName;
		webservice string ContactEmail;
		webservice string ContactDepartment ;
		
		//ContactWrapper Constructor
		global ContactWrapper(string AccountId, string ContactName, string ContactEmail,string ContactDepartment ) {
			
			this.AccountId = AccountId;
			this.ContactName = ContactName;
			this.ContactEmail = ContactEmail;
			this.ContactDepartment = ContactDepartment;
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
		webservice string AssetStatus;
		webservice Decimal AssetPrice;
		webservice Decimal AssetQuantity;
		webservice string AccountId;
		
		//AssetWrapper Constructor
		global AssetWrapper(string AssetName, string AssetStatus, Decimal AssetPrice, Decimal AssetQuantity,String AccountId) {
			
			this.AssetName = AssetName;
			this.AssetStatus = AssetStatus;
			this.AssetPrice = AssetPrice;
			this.AssetQuantity = AssetQuantity;
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
	webservice static AccountWrapper getCaseRelatedRecords(String CaseId, String PhoneNo , String strAccountNumber) {
		
		try {
			
			//Local Variables
			List<ContactWrapper> lstContactWrapper = new List<ContactWrapper>();
			List<AssetWrapper> lstAssetWrapper = new List<AssetWrapper>();
			List<EntitlementWrapper> lstEntitlementWrapper = new List<EntitlementWrapper>();
			AccountWrapper objAccountWrapper ;
			
			if((strAccountNumber != null) && (strAccountNumber != '') ) {
				
				List<Account> lstAccount = [ SELECT Phone, Name, Id, AccountNumber,Fax
											 FROM Account
											 WHERE AccountNumber = : strAccountNumber
											 limit 1];
				
				//check for Account is exist or not related to the accountId
				if(!lstAccount.isEmpty()) {
					
					List<Contact> lstContact = [ SELECT Name, Email, Department, AccountId, phone
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
					objAccountWrapper = new AccountWrapper(lstAccount[0].Fax,lstAccount[0].Phone,lstAccount[0].Name,lstAccount[0].Id ,lstContactWrapper,lstAssetWrapper,lstEntitlementWrapper,'');
				}
				else {
					
					//If Account is not exist related to the AccountId then display the error message
					objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,'Invalid Account Number');
				}
			}
			else {
				
				//fetch Account related to the given caseId
				List<Case> lstCase = [ SELECT Account.Fax, Account.Phone, Account.Name, Account.Id, AccountId, Account.AccountNumber
									   FROM Case
									   WHERE Id =: CaseId limit 1];
				
				//check for Case is exist or not related to the given caseId
				if(!lstCase.isEmpty()) {
					
					List<Account> lstAccount = [ SELECT Phone, Name, Id
												 FROM Account
												 WHERE Id = : lstCase[0].AccountId
												 limit 1];
					
					if(!lstAccount.isEmpty()) {
						
						List<Contact> lstContact = [ SELECT Name, Email, Department, AccountId, phone
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
						objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,'Account Id Does Not Exist Or Invalid Account Id');
					}
				}
				else {
					//When the Case record is not exist related to the given case Id
					objAccountWrapper = new AccountWrapper(null,null,null,null,null,null,null,'Invalid Case Id OR Case Id Does not Exist');
				}
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