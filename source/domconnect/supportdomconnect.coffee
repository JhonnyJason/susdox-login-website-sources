supportdomconnect = {name: "supportdomconnect"}

############################################################
supportdomconnect.initialize = () ->
    global.doctorregistrationBlock = document.getElementById("doctorregistration-block")
    global.patientregistrationBlock = document.getElementById("patientregistration-block")
    global.patientregistrationview = document.getElementById("patientregistrationview")
    global.patientregistrationviewHeading = document.getElementById("patientregistrationview-heading")
    global.patientsupportForm = document.getElementById("patientsupport-form")
    global.doctorregistrationview = document.getElementById("doctorregistrationview")
    global.doctorregistrationviewHeading = document.getElementById("doctorregistrationview-heading")
    global.doctorregistrationForm = document.getElementById("doctorregistration-form")
    global.svnLoginError404 = document.getElementById("svn-login-error404")
    global.svnLoginError401 = document.getElementById("svn-login-error401")
    global.nosvnLoginError = document.getElementById("nosvn-login-error")
    global.pinRenewError = document.getElementById("pin-renew-error")
    return
    
module.exports = supportdomconnect