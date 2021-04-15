public with sharing class sendGiftsExtension {
    public String selectedIds {get; set;}
    public String namespace {
        get { return constants.NAMESPACE; }
    }
    private ApexPages.StandardSetController sc;

    public sendGiftsExtension(ApexPages.StandardSetController sc) {
        this.sc = sc;
        List<String> objIds = new List<String>();
        for(sObject obj : sc.getSelected()){
            objIds.add((String)obj.get('Id'));
        }

        selectedIds = JSON.serialize(objIds);
    }
}