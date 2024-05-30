require('KDEJSBridgeToolsForUIWebView','NSDictionary','NSString','UIApplication','PALToast','MGJRouter');

defineClass("KDEJSBridgeToolsForUIWebView",{},{
    toZhiNiaoPlayback_in: function(data, viewController){
        
        let controller = viewController;
        let callBack = controller.responseCallback();

        let paramDic = NSDictionary.getDictionaryWithData(data);
        let roomId = paramDic.objectForKey('roomId');
        let courseType = paramDic.objectForKey('courseType');
        let courseName = paramDic.objectForKey('courseName');
        let dataSource = NSString.stringWithFormat("%@", paramDic["dataSource"]);
        let param = {
            "roomId": roomId ? roomId : "",
            "courseType": courseType ? courseType : "", 
            "courseName": courseName ? courseName : "", 
            "dataSource": dataSource ? dataSource : "4"
        };

        if (roomId && roomId.length() > 0) {
            MGJRouter.openURL_withUserInfo_completion("KDE://zhiniao/tool/enterLiveRoom",param,block("id", function(result){
                let dic = NSDictionary.getDictionaryWithData(result);
                let data = dic.objectForKey('data');
                let resultBool = dic.objectForKey('result').isEqualToString("Y");
                if (callBack) {
                    let dic = null;
                    if (resultBool) {
                        dic = NSDictionary.successResponseToWebViewWithData(data);
                    } else {
                        dic = NSDictionary.failedResponseToWebViewWithData(data);
                        PALToast.showToastWithText_superView_toastType((data.objectForKey('reason') ? data.objectForKey('reason') : "进入直播间失败"), UIApplication.sharedApplication().keyWindow(), 1);
                    }
                    callBack(dic);
                }
            }));
        }
        else {
            PALToast.showToastWithText_superView_toastType("房间编号不能为空", UIApplication.sharedApplication().keyWindow(), 1);
        }
    }
});

defineClass('JSPatchFixVersion', {}, {
    fixVersion: function() {
        return "123";
    }
});
