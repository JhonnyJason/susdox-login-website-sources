############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("patientloginviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import {loginURL} from "./configmodule.js"
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
    # TODO sophisticated error feedback
    log error
    return

############################################################
authcodeSubmitClicked = (evt) ->
    log "authcodeSubmitClicked"
    evt.preventDefault()
    try
        loginBody = await extractNoSVNFormBody()
        olog {loginBody}
        await doLoginRequest(loginBody)
    catch err then return errorFeedback(err)
    return

svnSubmitClicked = (evt) ->
    log "svnSubmitClicked"
    evt.preventDefault()
    try
        loginBody = await extractSVNFormBody()
        olog {loginBody}
        await doLoginRequest(loginBody)
    catch err then return errorFeedback(err)
    return

############################################################
extractSVNFormBody = ->

    isMedic = false
    username = ""+svnPartInput.value+birthdayPartInput.value
    password = ""+pinInput.value

    hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic}

extractNoSVNFormBody = ->

    isMedic = false
    username = ""+authcodeBirthdayInput.value
    password = "AT-"+authcodeInput.value

    hashedPw = await computeHashedPw(username, password)
    
    return {username, hashedPw, isMedic}


############################################################
# function computeHashedPw(vpn: string, username: string, clearPw: string) {
#     if (vpn.toUpperCase() === 'WFPI') {
#         if (username.toUpperCase() === 'ENGI') {
#             return hashUsernamePw(vpn + username, clearPw);
#         } else {
#             return hashUsernamePw(username + '.' + vpn, clearPw);
#         }
#     } else {
#         if (username.toUpperCase() === 'DZW') {
#             return hashUsernamePw(username, clearPw);
#         } else {
#             return hashUsernamePw(username, clearPw);
#         }
#     }
# }
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


