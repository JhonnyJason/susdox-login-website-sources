############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("utilmodule")
#endregion

############################################################
import * as tbut from "thingy-byte-utils"
# import libsodium from "libsodium-wrappers-sumo"


############################################################
charMap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
validAlphanumeKeyCodes = null
validBase32KeyCodes = null
alphaNumRegex = new RegExp('^[a-z0-9]*$')
base32Regex = new RegExp('^[a-km-np-z2-9]*$')

# sodium = null

############################################################
argon2Worker = null
argon2HashResolve = null
argon2HashReject = null

############################################################
# count = 10000

# c = count
# before = performance.now()
# while c--
#     operations()
# after = performacne.now()
# dif = after - before
# log "X took #{dif}ms"

############################################################
export initialize = ->
    log "initialize"
    argon2Worker = new Worker("argon2worker.js")
    argon2Worker.addEventListener("message", argon2WorkerResponded)

    # if window.Worker? then argon2Worker = new Worker("argon2worker.js")
    # else
    #     await libsodium.ready
    #     sodium = libsodium

    # await libsodium.ready
    # sodium = libsodium
    # olog Object.keys(sodium)
    prepareValidKeyCodesMap()
    return

############################################################
prepareValidKeyCodesMap = ->
    validAlphanumeKeyCodes = []
    validBase32KeyCodes = []
    # validAlphanumeKeyCodes = new Array(255)
    # validBase32KeyCodes = new Array(255)

    # num = code >= 48 && code <= 57
    for code in [48..57]
        validAlphanumeKeyCodes[code] = true
        if code != 48 and code != 49
            validBase32KeyCodes[code] = true

    # capitalAlpha = code >= 65 && code <= 90
    for code in [65..90]
        validAlphanumeKeyCodes[code] = true

    # smallAlpha = code >= 97 && code <= 122
    for code in [97..122]
        validAlphanumeKeyCodes[code] = true
        if code != 108 and code != 111
            validBase32KeyCodes[code] = true
    return

############################################################
# from - MIT LICENSE Copyright 2011 Jon Leighton - https://gist.github.com/jonleighton/958841 
bufferToBase64 = (buffer) ->
    result = ''

    bytes = new Uint8Array(buffer)
    length = bytes.length

    byteRemainder = length % 3
    mainLength = length - byteRemainder

    # Main loop deals with bytes in chunks of 3
    for i in [0...mainLength] by 3
        # Combine the three bytes into a single integer
        chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]

        # Use bitmasks to extract 6-bit segments from the triplet
        a = (chunk & 16515072) >> 18 # 16515072 = (2^6 - 1) << 18
        b = (chunk & 258048)   >> 12 # 258048   = (2^6 - 1) << 12
        c = (chunk & 4032)     >>  6 # 4032     = (2^6 - 1) << 6
        d = chunk & 63               # 63       = 2^6 - 1

        # Convert the raw binary segments to the appropriate ASCII encoding
        result += charMap[a] + charMap[b] + charMap[c] + charMap[d]

    # Deal with the remaining bytes and padding
    if (byteRemainder == 1)
        chunk = bytes[mainLength]

        a = (chunk & 252) >> 2 # 252 = (2^6 - 1) << 2

        # Set the 4 least significant bits to zero
        b = (chunk & 3)   << 4 # 3   = 2^2 - 1

        result += charMap[a] + charMap[b] + '=='
    
    else if (byteRemainder == 2)
        chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1]

        a = (chunk & 64512) >> 10 # 64512 = (2^6 - 1) << 10
        b = (chunk & 1008)  >>  4 # 1008  = (2^6 - 1) << 4

        # Set the 2 least significant bits to zero
        c = (chunk & 15)    <<  2 # 15    = 2^4 - 1

        result += charMap[a] + charMap[b] + charMap[c] + '='
    
    return result

############################################################
generatePBKDF2SubtleCrypto = (username, pwd) ->
    crypto = window.crypto.subtle
    
    olog {username, pwd}

    # saltBytes = crypto.getRandomValues(new Uint8Array(8))
    
    saltBytes = tbut.utf8ToBytes(username)
    rawKeyBytes = tbut.utf8ToBytes(pwd)

    # olog {saltBytes, rawKeyBytes}

    # rawKeyBytes = new ArrayBuffer()
    # log "setting rawKeyBytes to empty ArrayBuffer"
    
    initialKeyObj = await crypto.importKey(
        'raw',
        rawKeyBytes, 
        {name: 'PBKDF2'}, 
        false, 
        ['deriveBits', 'deriveKey']
    )

    # saltBytes = new ArrayBuffer()
    # log "setting rawSaltBytes to empty ArrayBuffer"

    derivedKeyObj = await crypto.deriveKey(
        { 
            "name": 'PBKDF2',
            "salt": saltBytes,
            "iterations": 1000,
            # "hash": 'SHA-256'
            "hash": 'SHA-1'
        },
        initialKeyObj,
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
    derivedKeyBase64 = bufferToBase64(derivedKeyBytes)

    # olog {derivedKeyBytes, derivedKeyBase64}
    return derivedKeyBase64

argon2WorkerResponded = (evnt) ->
    log "argon2WorkerResponded"
    log evnt.data
    if evnt.data? then { error, hashHex } = evnt.data
    if argon2HashResolve? and hashHex? then return argon2HashResolve(hashHex)
    if argon2HashReject? and error? then return argon2HashReject(error)
    log "argon2Worker response did not cause any effect!"
    return

############################################################
export hashUsernamePw = (username, pwd) ->
    if username.length < 4 then username = username + username + username
    if username.length < 8 then username = username + username

    hash = await generatePBKDF2SubtleCrypto(username, pwd)
    return hash

# export argon2HashPwLocal = (pin, birthdate) ->
#     salt = birthdate + "SUSDOX"
#     log salt

#     hash = sodium.crypto_pwhash(
#         32,        # Output size in bytes
#         pin,       # Will be converted to a UTF-8 Uint8Array by sodium.js
#         salt,      # Dito
#         1,         # Number of hash iterations
#         67108864,  # Use 64MB memory
#         sodium.crypto_pwhash_ALG_ARGON2ID13	# Hash algorithm: argon2id
#     )
#     hashHex = tbut.bytesToHex(hash)
#     return hashHex

export argon2HashPw = (pin, birthdate) ->
    log "argon2HashPw"
    # if !argon2Worker? then return argon2HashPwLocal()
    promisedHash = new Promise (resolve, reject) ->
        argon2HashResolve = resolve
        argon2HashReject = reject
        return
    
    args = {pin, birthdate}
    argon2Worker.postMessage(args)

    try 
        hashHex = await promisedHash
        # olog { hashHex }
        return hashHex
    catch err
        log "Argon2 threw an Error!"
        log err
    finally
        argon2HashResolve = null
        argon2HashReject = null
    return



############################################################
export isAlphanumericCode = (code) -> validAlphanumeKeyCodes[code]

export isBase32Code = (code) -> validBase32KeyCodes[code]


############################################################
export isAlphanumericString = (string) -> alphaNumRegex.test(string)

export isBase32String = (string) -> base32Regex.test(string) 

############################################################
export extractJsonFormData = (form) ->
    if typeof form == "string" then form = document.getElementById(form)

    json = {}
    for el in form.elements when el.type != "submit"
        if el.type == "checkbox" then json[el.name] = el.checked
        else json[el.name] = el.value
    return json