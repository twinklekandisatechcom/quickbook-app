({
    doInit: function(component, event, helper) {
        // Close the quick action
        $A.get("e.force:closeQuickAction").fire();

        var recordId = component.get("v.recordId");
        var objectName = "";
        var url = "";
		console.log('recordId is =',recordId);
        if (recordId) {
            var prefix = recordId.substring(0, 3);

            if (prefix === "001") {
                objectName = "account";
                var randomNum = Math.random().toString(36).substring(7);
                url = "/lightning/n/KTQB__Generate_Invoice#/?type=" + objectName + "&accid=" + recordId + "&t=" + randomNum;
                window.location.href = url;
            } else if (prefix === "006") {
                objectName = "opportunity";
                var randomNum = Math.random().toString(36).substring(7);
                url = "/lightning/n/KTQB__Generate_Invoice#/?type=" + objectName + "&oppid=" + recordId + "&t=" + randomNum;
                window.location.href = url;
            } else {
                objectName = "Unknown";
                url = "/lightning/n/KTQB__Generate_Invoice/";
                window.location.href = url;
            }
        }
        else{
            url = "/lightning/n/KTQB__Generate_Invoice/";
            window.location.href = url;
        }
    }
})