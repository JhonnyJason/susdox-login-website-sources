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
    global.usedUrlSelect = document.getElementById("used-url-select")
    global.doctorloginSubmitButton = document.getElementById("doctorlogin-submit-button")
    global.patientloginview = document.getElementById("patientloginview")
    global.patientloginHeading = document.getElementById("patientlogin-heading")
    global.patientAuthcodeLoginForm = document.getElementById("patient-authcode-login-form")
    global.authcodeBirthdayInput = document.getElementById("authcode-birthday-input")
    global.authcodeInput = document.getElementById("authcode-input")
    global.authcodeSubmitButton = document.getElementById("authcode-submit-button")
    global.patientSvnLoginForm = document.getElementById("patient-svn-login-form")
    global.svnPartInput = document.getElementById("svn-part-input")
    global.birthdayPartInput = document.getElementById("birthday-part-input")
    global.pinInput = document.getElementById("pin-input")
    global.svnSubmitButton = document.getElementById("svn-submit-button")
    global.patientRenewPinForm = document.getElementById("patient-renew-pin-form")
    return
    
module.exports = indexdomconnect