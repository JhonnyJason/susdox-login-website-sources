supportdomconnect = {name: "supportdomconnect"}

############################################################
supportdomconnect.initialize = () ->
    global.doctorregistrationBlock = document.getElementById("doctorregistration-block")
    global.patientregistrationBlock = document.getElementById("patientregistration-block")
    global.patientregistrationview = document.getElementById("patientregistrationview")
    global.patientregistrationviewHeading = document.getElementById("patientregistrationview-heading")
    global.patientsupportForm = document.getElementById("patientsupport-form")
    global.patientregistrationSubmitButton = document.getElementById("patientregistration-submit-button")
    global.requestcodeformblock = document.getElementById("requestcodeformblock")
    global.noPinQuestion = document.getElementById("no-pin-question")
    global.requestCodeForm = document.getElementById("request-code-form")
    global.requestPhoneInput = document.getElementById("request-phone-input")
    global.requestCodeErrorFeedbackText = document.getElementById("request-code-error-feedback-text")
    global.requestCodeSubmitButton = document.getElementById("request-code-submit-button")
    global.doctorregistrationview = document.getElementById("doctorregistrationview")
    global.doctorregistrationviewHeading = document.getElementById("doctorregistrationview-heading")
    global.doctorregistrationForm = document.getElementById("doctorregistration-form")
    global.doctorregistrationSubmitButton = document.getElementById("doctorregistration-submit-button")
    global.svnLoginError404 = document.getElementById("svn-login-error404")
    global.svnLoginError401 = document.getElementById("svn-login-error401")
    global.nosvnLoginError = document.getElementById("nosvn-login-error")
    global.pinRenewError = document.getElementById("pin-renew-error")
    global.requestCodeSuccess = document.getElementById("request-code-success")
    return
    
module.exports = supportdomconnect