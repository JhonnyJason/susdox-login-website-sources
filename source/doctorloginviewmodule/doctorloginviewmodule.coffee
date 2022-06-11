############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("doctorloginviewmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import {loginURL, loginRedirectURL} from "./configmodule.js"
import * as utl from "./utilmodule.js"
import * as tbut from "thingy-byte-utils"

############################################################
export initialize = ->
    log "initialize"
    doctorloginHeading.addEventListener("click", backButtonClicked)
    doctorloginSubmitButton.addEventListener("click", loginClicked)
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
loginClicked = (evt) ->
    log "loginClicked"
    evt.preventDefault()
    try
        loginBody = await extractLoginBody()
        olog {loginBody}
        response = await doLoginRequest(loginBody)
        responseBody = await response.json()
        responseHeaders = response.headers

        log " - - - - received response"
        olog response
        log "url: "+response.url
        log "status: "+response.status
        log "type: "+response.type
        log "redirected: "+response.redirected
        olog { responseHeaders }
        olog { responseBody }

        log "cookie:\n" + document.cookie
        # document.cookie = "webviewToken:"+responseBody.webviewToken+";"

        params = new URLSearchParams()
        params.append('webviewToken', 'responseBody.webviewToken')

        # response.redirect(loginRedirectURL+responseBody.redirect)
        location.href = loginRedirectURL+"?"+params.toString()

    catch err then return errorFeedback(err)
    return

############################################################
extractLoginBody = ->
    vpn = vpnInput.value.toLowerCase()
    # TODO check if vpn is valid - ignoring for now
    isMedic = true
    rememberMe = saveLoginInput.checked
    username = usernameInput.value.toLowerCase()
    password = passwordInput.value

    hashedPw = await computeHashedPw(vpn, username, password)
    
    return {vpn, username, hashedPw, isMedic, rememberMe}


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
computeHashedPw = (vpn, username, pwd) -> 
    if vpn == 'wfpi'
        if username == 'engi' then return hashUsernamePw(vpn+username, pwd)
        else return hashUsernamePw(username+'.'+vpn, pwd)
    else return hashUsernamePw(username, pwd)

hashUsernamePw = (username, pwd) ->
    if username.length < 4 then username = username + username + username
    if username.length < 8 then username = username + username

    # hashOne = generatePBKDF2CryptoJS(username, pwd)
    hashTwo = await generatePBKDF2SubtleCrypto(username, pwd)
    # olog {hashOne, hashTwo}
    # return hashOne
    return hashTwo

############################################################
generatePBKDF2CryptoJS = (username, pwd) ->
    crypto = window.Crypto

    binuser = crypto.charenc.UTF8.stringToBytes(username)
    binpwd = crypto.charenc.UTF8.stringToBytes(pwd)

    hashHex = crypto.PBKDF2(binpwd, binuser, 20, {iterations: 1000});
    hashBytes = tbut.hexToBytes(hashHex)
    hashBase64a = utl.bufferToBase64(hashBytes)
    # hashBase64b = crypto.util.bytesToBase64(hashBytes)
    # olog {hashBase64a, hashBase64b}
    return hashBase64a

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
    # redirect =  'manual'
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


