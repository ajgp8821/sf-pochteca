public class addDeleteRowDynamicComponnetClass {
    @AuraEnabled
    Public static string insertAccounts(List<Account> accList){
        system.debug(' insertAccounts ==> ');
        system.debug(' accList ==> ' + accList);
        String response = '';
        try{
            for(Account acc : accList){
               acc.NumberOfEmployees = Integer.valueOf(acc.NumberOfEmployees);
            }
            insert accList;
            response = 'SUCCESS';
        }
        catch(Exception ex){
            system.debug(' Ex ==> ' + ex.getMessage());
            response = ex.getMessage();
        }
        return response;
    }
}