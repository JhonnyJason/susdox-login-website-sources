indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.patientLoginBlock = document.getElementById("patient-login-block")
    global.doctorLoginBlock = document.getElementById("doctor-login-block")
    global.doctorloginview = document.getElementById("doctorloginview")
    global.doctorloginHeading = document.getElementById("doctorlogin-heading")
    global.vpnInput = document.getElementById("vpn-input")
    global.usernameInput = document.getElementById("username-input")
    global.passwordInput = document.getElementById("password-input")
    global.doctorloginSubmitButton = document.getElementById("doctorlogin-submit-button")
    global.patientloginview = document.getElementById("patientloginview")
    global.patientloginHeading = document.getElementById("patientlogin-heading")
    global.patientSvnLoginForm = document.getElementById("patient-svn-login-form")
    global.patientAuthcodeLoginForm = document.getElementById("patient-authcode-login-form")
    global.patientRenewPinForm = document.getElementById("patient-renew-pin-form")
    global.patientNoAuthcode = document.getElementById("patient-no-authcode")
    global.patientSvnFormButton = document.getElementById("patient-svn-form-button")
    global.patientAuthcodeFormButton = document.getElementById("patient-authcode-form-button")
    global.patientRenewPinButton = document.getElementById("patient-renew-pin-button")
    global.patientNoAuthcodeButton = document.getElementById("patient-no-authcode-button")
    return
    
module.exports = indexdomconnect