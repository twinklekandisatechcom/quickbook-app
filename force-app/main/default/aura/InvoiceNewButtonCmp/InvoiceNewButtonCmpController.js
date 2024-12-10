({
    doInit: function(component, event, helper) {
       /* var ref = component.get("v.pageReference");
        var state = ref.state; 
        var context = state.inContextOfRef;
        if (context.startsWith("1\.")) {
            context = context.substring(2);
            var addressableContext = JSON.parse(window.atob(context));
            component.set("v.recordId", addressableContext.attributes.recordId);
        }

        // var db = component.find("newtag");

        // $A.createComponent(
        //     'c:invoiceMainCmp', {recId : component.get("v.recordId")},
        //     function(lwcCmp, status, errorMessage) {
        //         if (status === "SUCCESS") {
        //             var body = db.get("v.body");
        //             body.push(lwcCmp);
        //             db.set("v.body", body);
        //         }
        //         else if (status === "INCOMPLETE") {
        //             console.log("No response from server or client is offline.");
        //         }
        //         else if (status === "ERROR") {
        //             console.error("Error: " + errorMessage);
        //         }
        //     }
        //   );

        document.addEventListener("aura://refreshView", () => {
            $A.get('e.force:refreshView').fire();
        }); */
    },
})