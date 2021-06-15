public class InventoryClienteTriggerHandler {
    
    public static void shareRecord(List<POCH_HojaInventario__c> invList, Map<Id,POCH_HojaInventario__c> mapOldInventro){
        List<String> invAccId  = new List<String>();
        for(POCH_HojaInventario__c inv : invList){
            if(mapOldInventro == null || (mapOldInventro.get(inv.Id).POCH_Cuenta__c != inv.POCH_Cuenta__c)){
                invAccId.add(inv.POCH_Cuenta__c);
            }
        }
        
            List<AccountTeamMember> teamMemberIdList = [SELECT Id, UserId FROM AccountTeamMember where accountId IN : invAccId];
            system.debug(teamMemberIdList);
            
            List<POCH_HojaInventario__Share> shareList = new List<POCH_HojaInventario__Share>();
            for(POCH_HojaInventario__c inv : invList){
                System.debug('--->inv ' +inv.Id);
                for(AccountTeamMember teamMemberId : teamMemberIdList){
                    System.debug('---> team ' +teamMemberId);
                    POCH_HojaInventario__Share invShare = new POCH_HojaInventario__Share();
                    invShare.ParentId = inv.Id;
                    System.debug('---> parentid ' +invShare.ParentId);
                    invShare.UserOrGroupId = teamMemberId.UserId;
                    System.debug('---> usergroupid ' +invShare.UserOrGroupId);
                    invShare.AccessLevel = 'Edit';
                    invShare.RowCause = 'Manual';
                    shareList.add(invShare);  	   
                }
            }
            insert shareList;
        
    }
    
    /* Map<Id, List<AccountTeamMember>> accountIdToTeamMembers = new Map<Id, List<AccountTeamMember>>();
List<AccountTeamMember>  accountTeamMembers = new List<AccountTeamMember>();

for(Account acct :[SELECT Id, (SELECT Id FROM AccountTeamMembers) FROM Account]){
//null check for account team members
accountIdToTeamMembers.put(acct.Id, new List<AccountTeamMember>());
//List<Id> atmIdList = new List<Id>();
for(AccountTeamMember atm :acct.AccountTeamMembers){
accountIdToTeamMembers.get(acct.Id).add(atm);

}

accountTeamMembers = [Select id, User.Name,TeamMemberRole,Title From AccountTeamMember Where AccountId = :acct.Id];
system.debug(accountIdToTeamMembers.get(acct.Id).size());
//system.debug(atmList)
}*/
    
    
}