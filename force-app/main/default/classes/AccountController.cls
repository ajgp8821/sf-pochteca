public class AccountController{
    @AuraEnabled
    public static void createAccounts(List<Account> accounts) {
        system.debug('accounts' + accounts);
        if(!accounts.isEmpty())
        {
            insert accounts;
            
            for(Account act:accounts)
            {
                //Contact Creation logic
                //or other logic
            }
        }
    }
    
    @AuraEnabled
    public static List<String> getPickList(String objectName, String fieldName) {
        List<String> values = new List<String>();
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.add(entry.getValue());
                }
            }
        }
        return values;
    }
}