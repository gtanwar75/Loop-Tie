public with sharing class responseData {
    public Boolean isSuccess;
    public Map<String, Object> results;
    public String errMsg;
    public Integer statusCode;

    public responseData() {
        this.isSuccess = true;
        this.results = new Map<String, Object>();
    }

    public void addError(String errMsg){
        this.errMsg = errMsg;
        this.isSuccess = false;
    }

    public void addError(Exception e){

        this.errMsg = e.getMessage();
        this.isSuccess = false;
    }

    public void put(String key, Object val){
        results.put(key, val);
    }

    public void setStatusCode(Integer statusCode){
        this.statusCode = statusCode;
    }

    public String getJsonString() {
        String jsonString = JSON.serialize(this);
        return jsonString.replaceAll('"' + constants.NAMESPACE_API + '([a-zA-Z0-9_]+?__(c|r))":', '"$1":');
    }
}