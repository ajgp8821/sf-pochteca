({

    fetchQuoteHelper : function(component, event, helper) {

        component.set('v.mycolumns', [

            {label: 'Quote Number', fieldName: 'Name', type: 'Auto Number'},

                {label: 'Account', fieldName: 'SBQQ__Account__c', type: 'text'},

            ]);

        var action = component.get("c.fetchQuotes");

        action.setParams({

        });

        action.setCallback(this, function(response){

            var state = response.getState();

            if (state === "SUCCESS") {

                component.set("v.qtList", response.getReturnValue());

            }

        });

        $A.enqueueAction(action);

    },

})