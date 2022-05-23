supportdomconnect = {name: "supportdomconnect"}

############################################################
supportdomconnect.initialize = () ->
    global.registrationBlock = document.getElementById("registration-block")
    global.registrationview = document.getElementById("registrationview")
    global.registrationviewHeading = document.getElementById("registrationview-heading")
    global.nameInput = document.getElementById("name-input")
    global.registrationSubmitButton = document.getElementById("registration-submit-button")
    return
    
module.exports = supportdomconnect