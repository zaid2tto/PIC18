#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=gnumkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=cof
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=cof
FINAL_IMAGE=dist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=delays32.asm lcd18.asm InterfaceMain.asm delays.asm

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/delays32.o ${OBJECTDIR}/lcd18.o ${OBJECTDIR}/InterfaceMain.o ${OBJECTDIR}/delays.o
POSSIBLE_DEPFILES=${OBJECTDIR}/delays32.o.d ${OBJECTDIR}/lcd18.o.d ${OBJECTDIR}/InterfaceMain.o.d ${OBJECTDIR}/delays.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/delays32.o ${OBJECTDIR}/lcd18.o ${OBJECTDIR}/InterfaceMain.o ${OBJECTDIR}/delays.o

# Source Files
SOURCEFILES=delays32.asm lcd18.asm InterfaceMain.asm delays.asm


CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
	${MAKE} ${MAKE_OPTIONS} -f nbproject/Makefile-default.mk dist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=18f4620
MP_LINKER_DEBUG_OPTION=-r=ROM@0xFDC0:0xFFFF -r=RAM@GPR:0xEF4:0xEFF
# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/delays32.o: delays32.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/delays32.o.d 
	@${RM} ${OBJECTDIR}/delays32.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/delays32.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PICKIT2=1 -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/delays32.lst\" -e\"${OBJECTDIR}/delays32.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/delays32.o\" \"delays32.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/delays32.o"
	@${FIXDEPS} "${OBJECTDIR}/delays32.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/lcd18.o: lcd18.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/lcd18.o.d 
	@${RM} ${OBJECTDIR}/lcd18.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/lcd18.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PICKIT2=1 -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/lcd18.lst\" -e\"${OBJECTDIR}/lcd18.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/lcd18.o\" \"lcd18.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/lcd18.o"
	@${FIXDEPS} "${OBJECTDIR}/lcd18.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/InterfaceMain.o: InterfaceMain.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/InterfaceMain.o.d 
	@${RM} ${OBJECTDIR}/InterfaceMain.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/InterfaceMain.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PICKIT2=1 -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/InterfaceMain.lst\" -e\"${OBJECTDIR}/InterfaceMain.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/InterfaceMain.o\" \"InterfaceMain.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/InterfaceMain.o"
	@${FIXDEPS} "${OBJECTDIR}/InterfaceMain.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/delays.o: delays.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/delays.o.d 
	@${RM} ${OBJECTDIR}/delays.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/delays.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -d__DEBUG -d__MPLAB_DEBUGGER_PICKIT2=1 -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/delays.lst\" -e\"${OBJECTDIR}/delays.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/delays.o\" \"delays.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/delays.o"
	@${FIXDEPS} "${OBJECTDIR}/delays.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
else
${OBJECTDIR}/delays32.o: delays32.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/delays32.o.d 
	@${RM} ${OBJECTDIR}/delays32.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/delays32.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/delays32.lst\" -e\"${OBJECTDIR}/delays32.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/delays32.o\" \"delays32.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/delays32.o"
	@${FIXDEPS} "${OBJECTDIR}/delays32.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/lcd18.o: lcd18.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/lcd18.o.d 
	@${RM} ${OBJECTDIR}/lcd18.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/lcd18.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/lcd18.lst\" -e\"${OBJECTDIR}/lcd18.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/lcd18.o\" \"lcd18.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/lcd18.o"
	@${FIXDEPS} "${OBJECTDIR}/lcd18.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/InterfaceMain.o: InterfaceMain.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/InterfaceMain.o.d 
	@${RM} ${OBJECTDIR}/InterfaceMain.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/InterfaceMain.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/InterfaceMain.lst\" -e\"${OBJECTDIR}/InterfaceMain.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/InterfaceMain.o\" \"InterfaceMain.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/InterfaceMain.o"
	@${FIXDEPS} "${OBJECTDIR}/InterfaceMain.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
${OBJECTDIR}/delays.o: delays.asm  nbproject/Makefile-${CND_CONF}.mk
	@${MKDIR} ${OBJECTDIR} 
	@${RM} ${OBJECTDIR}/delays.o.d 
	@${RM} ${OBJECTDIR}/delays.o 
	@${FIXDEPS} dummy.d -e "${OBJECTDIR}/delays.err" $(SILENT) -c ${MP_AS} $(MP_EXTRA_AS_PRE) -q -p$(MP_PROCESSOR_OPTION)  -l\"${OBJECTDIR}/delays.lst\" -e\"${OBJECTDIR}/delays.err\" $(ASM_OPTIONS)   -o\"${OBJECTDIR}/delays.o\" \"delays.asm\" 
	@${DEP_GEN} -d "${OBJECTDIR}/delays.o"
	@${FIXDEPS} "${OBJECTDIR}/delays.o.d" $(SILENT) -rsi ${MP_AS_DIR} -c18 
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
dist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)   -p$(MP_PROCESSOR_OPTION)  -w -x -u_DEBUG -z__ICD2RAM=1 -m"${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map"   -z__MPLAB_BUILD=1  -z__MPLAB_DEBUG=1 -z__MPLAB_DEBUGGER_PICKIT2=1 $(MP_LINKER_DEBUG_OPTION) -odist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
else
dist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} dist/${CND_CONF}/${IMAGE_TYPE} 
	${MP_LD} $(MP_EXTRA_LD_PRE)   -p$(MP_PROCESSOR_OPTION)  -w  -m"${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map"   -z__MPLAB_BUILD=1  -odist/${CND_CONF}/${IMAGE_TYPE}/Interface2.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/default
	${RM} -r dist/default

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
