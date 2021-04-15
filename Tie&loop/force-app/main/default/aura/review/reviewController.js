({  init : function(component, event, helper){
        var locale = $A.get("$Locale.userLocaleLang");

        if (!$A.util.isEmpty($A.get("$Locale.userLocaleCountry"))) {
            locale += '_' + $A.get("$Locale.userLocaleCountry");
        }

        var datePatternMap = {
            'ar': 'dd/MM/yyyy',
            'ar_AE': 'dd/MM/yyyy',
            'ar_BH': 'dd/MM/yyyy',
            'ar_JO': 'dd/MM/yyyy',
            'ar_KW': 'dd/MM/yyyy',
            'ar_LB': 'dd/MM/yyyy',
            'ar_SA': 'dd/MM/yyyy',
            'bg_BG': 'yyyy-M-d',
            'ca': 'dd/MM/yyyy',
            'ca_ES': 'dd/MM/yyyy',
            'ca_ES_EURO': 'dd/MM/yyyy',
            'cs': 'd.M.yyyy',
            'cs_CZ': 'd.M.yyyy',
            'da': 'dd-MM-yyyy',
            'da_DK': 'dd-MM-yyyy',
            'de': 'dd.MM.yyyy',
            'de_AT': 'dd.MM.yyyy',
            'de_AT_EURO': 'dd.MM.yyyy',
            'de_CH': 'dd.MM.yyyy',
            'de_DE': 'dd.MM.yyyy',
            'de_DE_EURO': 'dd.MM.yyyy',
            'de_LU': 'dd.MM.yyyy',
            'de_LU_EURO': 'dd.MM.yyyy',
            'el_GR': 'd/M/yyyy',
            'en_AU': 'd/MM/yyyy',
            'en_B': 'M/d/yyyy',
            'en_BM': 'M/d/yyyy',
            'en_CA': 'dd/MM/yyyy',
            'en_GB': 'dd/MM/yyyy',
            'en_GH': 'M/d/yyyy',
            'en_ID': 'M/d/yyyy',
            'en_IE': 'dd/MM/yyyy',
            'en_IE_EURO': 'dd/MM/yyyy',
            'en_NZ': 'd/MM/yyyy',
            'en_SG': 'M/d/yyyy',
            'en_US': 'M/d/yyyy',
            'en_ZA': 'yyyy/MM/dd',
            'es': 'd/MM/yyyy',
            'es_AR': 'dd/MM/yyyy',
            'es_BO': 'dd-MM-yyyy',
            'es_CL': 'dd-MM-yyyy',
            'es_CO': 'd/MM/yyyy',
            'es_CR': 'dd/MM/yyyy',
            'es_EC': 'dd/MM/yyyy',
            'es_ES': 'd/MM/yyyy',
            'es_ES_EURO': 'd/MM/yyyy',
            'es_GT': 'd/MM/yyyy',
            'es_HN': 'MM-dd-yyyy',
            'es_MX': 'd/MM/yyyy',
            'es_PE': 'dd/MM/yyyy',
            'es_PR': 'MM-dd-yyyy',
            'es_PY': 'dd/MM/yyyy',
            'es_SV': 'MM-dd-yyyy',
            'es_UY': 'dd/MM/yyyy',
            'es_VE': 'dd/MM/yyyy',
            'et_EE': 'd.MM.yyyy',
            'fi': 'd.M.yyyy',
            'fi_FI': 'd.M.yyyy',
            'fi_FI_EURO': 'd.M.yyyy',
            'fr': 'dd/MM/yyyy',
            'fr_BE': 'd/MM/yyyy',
            'fr_CA': 'yyyy-MM-dd',
            'fr_CH': 'dd.MM.yyyy',
            'fr_FR': 'dd/MM/yyyy',
            'fr_FR_EURO': 'dd/MM/yyyy',
            'fr_LU': 'dd/MM/yyyy',
            'fr_MC': 'dd/MM/yyyy',
            'hr_HR': 'yyyy.MM.dd',
            'hu': 'yyyy.MM.dd.',
            'hy_AM': 'M/d/yyyy',
            'is_IS': 'd.M.yyyy',
            'it': 'dd/MM/yyyy',
            'it_CH': 'dd.MM.yyyy',
            'it_IT': 'dd/MM/yyyy',
            'iw': 'dd/MM/yyyy',
            'iw_IL': 'dd/MM/yyyy',
            'ja': 'yyyy/MM/dd',
            'ja_JP': 'yyyy/MM/dd',
            'kk_KZ': 'M/d/yyyy',
            'km_KH': 'M/d/yyyy',
            'ko': 'yyyy. M. d',
            'ko_KR': 'yyyy. M. d',
            'lt_LT': 'yyyy.M.d',
            'lv_LV': 'yyyy.d.M',
            'ms_MY': 'dd/MM/yyyy',
            'nl': 'd-M-yyyy',
            'nl_BE': 'd/MM/yyyy',
            'nl_NL': 'd-M-yyyy',
            'nl_SR': 'd-M-yyyy',
            'no': 'dd.MM.yyyy',
            'no_NO': 'dd.MM.yyyy',
            'pl': 'yyyy-MM-dd',
            'pt': 'dd-MM-yyyy',
            'pt_AO': 'dd-MM-yyyy',
            'pt_BR': 'dd/MM/yyyy',
            'pt_PT': 'dd-MM-yyyy',
            'ro_RO': 'dd.MM.yyyy',
            'ru': 'dd.MM.yyyy',
            'sk_SK': 'd.M.yyyy',
            'sl_SI': 'd.M.y',
            'sv': 'yyyy-MM-dd',
            'sv_SE': 'yyyy-MM-dd',
            'th': 'M/d/yyyy',
            'th_TH': 'd/M/yyyy,',
            'tr': 'dd.MM.yyyy',
            'ur_PK': 'M/d/yyyy',
            'vi_VN': 'dd/MM/yyyy',
            'zh': 'yyyy-M-d',
            'zh_CN': 'yyyy-M-d',
            'zh_HK': 'yyyy-M-d',
            'zh_TW': 'yyyy/M/d'
        }
        component.set('v.dateFormat', datePatternMap[locale]);
       
    },
    handleEditButtonClick : function(component, event, helper) {
        var buttonClicked = event.getSource().get('v.value');
        var totalSteps = component.get('v.totalSteps');
        switch(buttonClicked) {
            case 'recipients':
                component.set('v.errorMessage', '');
                component.set('v.activeStep', 0);
                component.set('v.progressPercent', 0);
                break;
            case 'teamCollection':
                component.set('v.errorMessage', '');
                component.set('v.activeStep', 1);
                var progressPercent = (100 / (totalSteps - 1)) * 1;
                component.set('v.progressPercent', progressPercent);
                break;
            case 'message':
                component.set('v.errorMessage', '');
                component.set('v.activeStep', 2);
                var progressPercent = (100 / (totalSteps - 1)) * 2;
                component.set('v.progressPercent', progressPercent);
                break;
            case 'design':
                component.set('v.errorMessage', '');
                component.set('v.activeStep', 3);
                var progressPercent = (100 / (totalSteps - 1)) * 3;
                component.set('v.progressPercent', progressPercent);
                break;
        }
    },
    handleViewAll : function(component, event, helper) {
        component.set('v.viewAllModalShown', true);
    },
    formatSelectedDate : function(component, event, helper){
        var selectedDate = component.get('v.selectedDate');
        var strArray = selectedDate.split("-");
        var dateStr = ""+ strArray[1] + "-" + strArray[2] + "-" + strArray[0]+"";
        component.set('v.displayDate', dateStr);
    }
})