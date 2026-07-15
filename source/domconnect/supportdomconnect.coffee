supportdomconnect = {name: "supportdomconnect"}

############################################################
supportdomconnect.initialize = () ->
    global.doctorregistrationBlock = document.getElementById("doctorregistration-block")
    global.patientregistrationBlock = document.getElementById("patientregistration-block")
    global.svnLoginError404 = document.getElementById("svn-login-error404")
    global.svnLoginError401 = document.getElementById("svn-login-error401")
    global.nosvnLoginError = document.getElementById("nosvn-login-error")
    global.pinRenewError = document.getElementById("pin-renew-error")
    global.requestCodeSuccess = document.getElementById("request-code-success")
    return
    
module.exports = supportdomconnect