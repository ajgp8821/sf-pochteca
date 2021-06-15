public class QuoteReportWrapper { 
    public List<SBQQ__Quote__c> quoteList { get; set; }
    public List<SBQQ__QuoteLine__c> quoteLineList { get; set; }
    public Map<Id, List<SBQQ__QuoteLine__c>> quoteLineListMap { get; set; }
    public List<Order> orderList {get; set;}
    public Map<Id, List<Order>> orderListMap {get; set;}
    Set<Id> quoteIds = new Set<Id>();
    Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
    
    public List<QuoteReportWrapperCls> quoteReportWrapperList { get; set; }

    public QuoteReportWrapper() {   
        quoteList = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 100];
        quoteLineListMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        quoteReportWrapperList = new List<QuoteReportWrapperCls>();
        if(quoteList.size() > 0) {
            for(SBQQ__Quote__c qot : quoteList) {
                quoteIds.add(qot.Id);
                quoteMap.put(qot.Id, qot);
            }
            quoteLineList = [SELECT Name, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIds];
            orderList = [Select Id, Status, Name FROM Order WHERE SBQQ__Quote__c IN:quoteIds];
            system.debug('quoteLineList List is ' + quoteLineList);
        }
        if(quoteLineList.size() > 0) {
            for(SBQQ__QuoteLine__c qotLine : quoteLineList) {
                if(!quoteLineListMap.containsKey(qotLine.SBQQ__Quote__c)){
                    quoteLineListMap.put(qotLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
                }
                quoteLineListMap.get(qotLine.SBQQ__Quote__c).add(qotLine);
            }
            for(Id quoteLineId : quoteLineListMap.keySet()) {
                quoteReportWrapperList.add(new QuoteReportWrapperCls(quoteMap.get(quoteLineId), quoteLineListMap.get(quoteLineId)));
            }
        }
   /*      if(orderList.size() > 0) {
            for(Order ord : orderList) {
                if(!orderListMap.containsKey(ord.SBQQ__Quote__c)){
                    orderListMap.put(ord.SBQQ__Quote__c, new List<Order>());
                }
                orderListMap.get(ord.SBQQ__Quote__c).add(ord);
            }
            for(Id orderId : orderListMap.keySet()) {
                quoteReportWrapperList.add(new QuoteReportWrapperCls(quoteMap.get(orderId), orderListMap.get(orderId)));
            }
        }*/
    } 
    
    public class QuoteReportWrapperCls {
        public SBQQ__Quote__c quoteVal { get; set; }
        public List<SBQQ__QuoteLine__c> quoteLineListVal { get; set; }
       // public List<Order> orderListVal {get; set;}
        
        public QuoteReportWrapperCls(SBQQ__Quote__c quoteVal, List<SBQQ__QuoteLine__c> quoteLineListVal) {
            this.quoteVal = quoteVal;
            this.quoteLineListVal = quoteLineListVal;
           // this.orderListVal = orderListVal;
        }
    }
}