import { addModulesToDebug } from "thingy-debug"

############################################################
export modulesToDebug = 
    unbreaker: true
    # configmodule: true
    # statemodule: true
    # errorfeedbackmodule: true
    # patientloginviewmodule: true
    patientregistrationviewmodule: true
    # doctorloginviewmodule: true
    doctorregistrationviewmodule: true
    # registrationviewmodule: true
    scrollrolldatepickermodule: true
    # utilmodule: true

addModulesToDebug(modulesToDebug)
