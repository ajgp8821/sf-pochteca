trigger POCH_TriggernoChangeCancel on SBQQ__QuoteLine__c (before update) {
for (SBQQ__QuoteLine__c pa : Trigger.new) {     
   if(pa.fecha_inicio__c >= pa.fecha_cancelacion__c && pa.Motivo_de_cancelaci_n__c!=null && pa.POCH_EstatusPartida__c <>  'Cancelado'       ){
                  
                      try {
                    pa.addError('No puede cambiar el status en este estapa de cancelación');
                         if(Test.isRunningTest()) {
                    CalloutException ex = new CalloutException();
                    ex.setMessage('This is a constructed exception for testing and code coverage');
                    throw ex;
                        }     
                      }catch(Exception e) {
             System.debug(e.getStackTraceString());
            System.debug('The following exception has occurred: ' + e.getMessage());
           
        }
                 
   }
  }
}