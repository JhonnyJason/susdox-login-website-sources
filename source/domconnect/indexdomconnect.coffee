indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.doctorLoginBlock = document.getElementById("doctor-login-block")
    global.patientLoginBlock = document.getElementById("patient-login-block")
    global.doctorloginview = document.getElementById("doctorloginview")
    global.doctorloginHeading = document.getElementById("doctorlogin-heading")
    global.doctormiscContinueButton = document.getElementById("doctormisc-continue-button")
    global.doctorloginForm = document.getElementById("doctorlogin-form")
    global.vpnInput = document.getElementById("vpn-input")
    global.usernameInput = document.getElementById("username-input")
    global.passwordInput = document.getElementById("password-input")
    global.saveLoginInput = document.getElementById("save-login-input")
    global.doctorloginSubmitButton = document.getElementById("doctorlogin-submit-button")
    global.patientloginview = document.getElementById("patientloginview")
    global.patientloginHeading = document.getElementById("patientlogin-heading")
    global.patientCodeLoginForm = document.getElementById("patient-code-login-form")
    global.birthdayInput = document.getElementById("birthday-input")
    global.codeInput = document.getElementById("code-input")
    global.codeErrorFeedbackText = document.getElementById("code-error-feedback-text")
    global.codeSubmitButton = document.getElementById("code-submit-button")
    global.noCodeQuestion = document.getElementById("no-code-question")
    global.renewCodeForm = document.getElementById("renew-code-form")
    global.codeRenewSvnPartInput = document.getElementById("code-renew-svn-part-input")
    global.codeRenewBirthdayPartInput = document.getElementById("code-renew-birthday-part-input")
    global.codeRenewErrorFeedbackText = document.getElementById("code-renew-error-feedback-text")
    global.codeRenewSubmitButton = document.getElementById("code-renew-submit-button")
    global.svnLoginError404 = document.getElementById("svn-login-error404")
    global.svnLoginError401 = document.getElementById("svn-login-error401")
    global.nosvnLoginError = document.getElementById("nosvn-login-error")
    global.pinRenewError = document.getElementById("pin-renew-error")
    return
    
module.exports = indexdomconnect