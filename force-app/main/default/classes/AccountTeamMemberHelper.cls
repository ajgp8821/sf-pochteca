/*---------------------------------------------------------------------------------------------------------------
--- Company: Zaga System 
--- Author: Jesús Azuaje
--- Update for: Jesús Azuaje
--- Description: Helper trigger tu grant access to Inventary, Apext Test AccountTeamMemberHelper
--- CreateDate: 21/05/2021 - JIRA CAM-2085
--- UpdateDate: 
--- Version: 1.0
---------------------------------------------------------------------------------------------------------------*/
public with sharing class AccountTeamMemberHelper {
    public class AuraHandledException extends exception {
        
    }

    public static void evaluateAccess(List<AccountTeamMember > listAccountTeam) {
        try {
            System.debug('print ');
            Id accountId, idUsuario;
            Boolean readInventario = false;
            Boolean editInventario = false;
            for (AccountTeamMember input: listAccountTeam){
                System.debug('print AccountAccessLevel: ' + input.AccountAccessLevel);
                accountId = input.AccountId;
                idUsuario = input.UserId;
            }

        }catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar insert de AccountTeamMember: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar insert de AccountTeamMember: '
                                           + e.getMessage());    
        }
    }

    public static void deleteAccess(List<AccountTeamMember> listAccountTeam) {
        try {

        } catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar delete de AccountTeamMember: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar delete de AccountTeamMember: '
                                           + e.getMessage());    
        }
    }

    public static void updateAccountTeam(List<AccountTeamMember> listAccountTeam, List<AccountTeamMember> listAccountTeamOld) {
        try {

        } catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            String msg = 'Ocurrio un error al ejecutar update de AccountTeamMember: '+ e.getMessage();
            throw new AuraHandledException('Ocurrio un error al ejecutar  update de AccountTeamMember: '
                                           + e.getMessage());    
        }
    }

}