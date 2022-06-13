############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientloginviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import { loginURL, loginRedirectURL } from "./configmodule.js"
import * as utl from "./utilmodule.js"
import * as tbut from "thingy-byte-utils"

############################################################
export initialize = ->
    log "initialize"
    patientloginHeading.addEventListener("click", backButtonClicked)
    svnSubmitButton.addEventListener("click", svnSubmitClicked)
    authcodeSubmitButton.addEventListener("click", authcodeSubmitClicked)
    return

############################################################
# using History
# backButtonClicked = -> window.history.back()

############################################################
# no History
backButtonClicked = -> S.save("loginView", "none")


############################################################
errorFeedback = (error) ->
    log "errorFeedback" 
    if error.authcode
        doctorloginForm.classList.remove("error")
        patientAuthcodeLoginForm.classList.add("error")
        patientSvnLoginForm.classList.remove("error")
        patientRenewPinForm.classList.remove("error")
        log error.msg
        return

    if error.svnLogin
        doctorloginForm.classList.remove("error")
        patientAuthcodeLoginForm.classList.remove("error")
        patientSvnLoginForm.classList.add("error")
        patientRenewPinForm.classList.remove("error")
        log error.msg
        return

    if error.renewPin
        doctorloginForm.classList.remove("error")
        patientAuthcodeLoginForm.classList.remove("error")
        patientSvnLoginForm.classList.remove("error")
        patientRenewPinForm.classList.add("error")
        log error.msg
        return

    log error.msg
    return

############################################################
authcodeSubmitClicked = (evt) ->
    log "authcodeSubmitClicked"
    evt.preventDefault()
    try
        loginBody = await extractNoSVNFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback({authcode:true, msg: "Response was not OK!"})
        else location.href = loginRedirectURL

    catch err then return errorFeedback({authcode:true, msg: err.message})
    return

svnSubmitClicked = (evt) ->
    log "svnSubmitClicked"
    evt.preventDefault()
    try
        loginBody = await extractSVNFormBody()
        olog {loginBody}

        if !loginBody.hashedPw and !loginBody.username then return

        response = await doLoginRequest(loginBody)
        
        if !response.ok then errorFeedback({svnLogin:true, msg: "Response was not OK!"})
        else location.href = loginRedirectURL

    catch err then return errorFeedback({svnLogin:true, msg: err.message})
    return

############################################################
extractSVNFormBody = ->

    isMedic = false
    rememberMe = false
    username = ""+svnPartInput.value+birthdayPartInput.value
    password = ""+pinInput.value

    if !password then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic, rememberMe}

extractNoSVNFormBody = ->

    isMedic = false
    username = ""+authcodeBirthdayInput.value
    password = "AT-"+authcodeInput.value
    
    if password == "AT-" then hashedPw = ""
    else hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic}


############################################################
computeHashedPw = (username, pwd) -> 
    return hashUsernamePw(username, pwd)

hashUsernamePw = (username, pwd) ->
    if username.length < 4 then username = username + username + username
    if username.length < 8 then username = username + username

    hash = await generatePBKDF2SubtleCrypto(username, pwd)
    return hash

############################################################
generatePBKDF2SubtleCrypto = (username, pwd) ->
    crypto = window.crypto.subtle
    
    # saltBytes = crypto.getRandomValues(new Uint8Array(8))
    
    saltBytes = tbut.utf8ToBytes(username)
    rawKeyBytes = tbut.utf8ToBytes(pwd)

    keyBytes = await crypto.importKey(
        'raw',
        rawKeyBytes, 
        {name: 'PBKDF2'}, 
        false, 
        ['deriveBits', 'deriveKey']
    )

    derivedKeyObj = await crypto.deriveKey(
        { 
            "name": 'PBKDF2',
            "salt": saltBytes,
            "iterations": 1000,
            # "hash": 'SHA-256'
            "hash": 'SHA-1'
        },
        keyBytes,
        # // Note: we don't actually need a cipher suite,
        # // but the api requires that it must be specified.
        # // For AES the length required to be 128 or 256 bits (not bytes)
        # { "name": 'AES-CBC',"length": 256},
        { 
            "name": 'HMAC', 
            "hash": "SHA-1", 
            "length": 160 
        },
        # Whether or not the key is extractable (less secure) or not (more secure)
        # when false, the key can only be passed as a web crypto object, not inspected
        true,
        # this web crypto object will only be allowed for these functions
        # [ "encrypt", "decrypt" ]
        ["sign", "verify"]
    )

    derivedKeyBytes = await crypto.exportKey("raw", derivedKeyObj)
    derivedKeyBase64 = utl.bufferToBase64(derivedKeyBytes)
    return derivedKeyBase64

############################################################
doLoginRequest = (body) ->
    method = "POST"
    mode = 'cors'
    redirect =  'follow'
    credentials = 'include'
    
    # url encoded
    # headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
    # body = new URLSearchParams(body)

    # json body
    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)

    fetchOptions = { method, mode, redirect, credentials, headers, body }

    try return fetch(loginURL, fetchOptions)
    catch err then log err


