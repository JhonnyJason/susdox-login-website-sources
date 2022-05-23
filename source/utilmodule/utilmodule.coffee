############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("utilmodule")
#endregion

############################################################
charMap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return

# from - MIT LICENSE Copyright 2011 Jon Leighton - https://gist.github.com/jonleighton/958841 
export bufferToBase64 = (buffer) ->
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