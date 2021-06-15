/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga
--- Author: 
--- Update for: Jesús Azuaje
--- Description: Se ajusta metodo accountRecord para realizar busqueda en el object Opportunity y verificar si existen registros
--- CreateDate: 
--- UpdateDate: 16/03/2021 - JIRA RN-6502 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
public class AccountTeamTriggerHandler {
    
    public static void accountRecord(List<POCH_HojaInventario__c> invRecList, Map<Id,POCH_HojaInventario__c> mapOldInv){
        Id accountId, sucursalId;
        Set<String> accId  = new Set<String>();
        
        for(POCH_HojaInventario__c invRec : invRecList){
            accId.add(invRec.POCH_Cuenta__c);
            accountId = invRec.POCH_Cuenta__c;
			sucursalId = invRec.POCH_Sucursal__c;            
        }
        
        /*
        List<Id> userIdList = new List<Id>();
        for(AccountTeamMember teamMember : [SELECT Id, UserId FROM AccountTeamMember where accountId IN : accId]){
            userIdList.add(teamMember.UserId);
        }
       
        for(POCH_HojaInventario__c inv : invRecList){
            AccountTeamTriggerHelper.addUserToGroup(inv.id, userIdList);
        }*/
        
        for(Opportunity spancop : [SELECT 
                                   	Id,
                                   	POCH_MaterialHojaInventario__c 
                                   FROM Opportunity
                                   WHERE AccountId =: accountId 
                                   AND POCH_Sucursal__c =: sucursalId 
                                   AND (StageName = 'Sospechoso' OR StageName = 'Prospecto')]){
            spancop.POCH_MaterialHojaInventario__c = true;
            update spancop;
        }
        
        
        // Map<Id, AccountTeamMember> teamMap = new Map<Id, AccountTeamMember> ();
        // teamMap.put(teamMember.UserId, teamMember);
        //List<Account> accountsList = [SELECT Id, POCH_IDClienteSAP__c FROM Account where id IN : accId];
        //system.debug('--->size'+accountsList.size());
        //List<AccountTeamMember> teamMemberIdList = [SELECT Id, UserId, Account.Id, Account.POCH_IDClienteSAP__c FROM AccountTeamMember where accountId IN : accId];
        //system.debug(teamMemberIdList);	
        // for(AccountTeamMember teamMember : teamMemberIdList){
        
        //   GroupMember groups = new GroupMember();
        // groups.GroupId = objGroup.id;
        
        //groups.UserOrGroupId = teamMember.userId;
        
        // groupList.add(groups);
        //}
        //  insert groupList;
        
        // List<POCH_HojaInventario__Share> shareList = new List<POCH_HojaInventario__Share>();
        //for(POCH_HojaInventario__c inv : invList){
        //  System.debug('--->inv ' +inv.Id);
        
        //System.debug('---> team ' +teamMemberId);
        //POCH_HojaInventario__Share invShare = new POCH_HojaInventario__Share();
        //invShare.ParentId = inv.Id;
        //System.debug('---> parentid ' +invShare.ParentId);
        //invShare.UserOrGroupId = teamMemberId.UserId;
        //System.debug('---> usergroupid ' +invShare.UserOrGroupId);
        //invShare.AccessLevel = 'Edit';
        //invShare.RowCause = 'Manual';
        //shareList.add(invShare);  	   
        // }
        // }
        // insert shareList;
        
    }
    
}