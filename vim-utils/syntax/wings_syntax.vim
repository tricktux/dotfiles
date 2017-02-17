" Vim syntax file
" Language:     Reinaldo Molina
" Maintainer:   Reinaldo Molina
" Last Change:  2016 08 24
" Revision:     0.21

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword wingsTodo NOTE TODO XXX contained

syn case ignore

" Directives
syn match wingsIdentifier 	"[a-z_$][a-z0-9_$]*"

syn match wingsLabel      	"_^:[A-Z]_$"

syn match decNumber		"0\+[1-7]\=[\t\n$,; ]"
syn match decNumber		"[1-9]\d*"
syn match decNumber		"0.\d*"
syn match octNumber		"0[oO][0-7]\+"
syn match octNumber		"0[0-7][0-7]\+"
syn match hexNumber		"0[xX][0-9A-Fa-f]\+"
syn match hexNumber     	"\$[0-9A-Fa-f]\+\>"
syn match binNumber		"0[bB][0-1]*"

" syn match wingsComment    	"^[^:\/\$\s].*$" contains=wingsTodo
" syn match wingsComment    	"^[^:\/\$].*$" contains=@wingsCommands
syn match wingsComment    	"/.*"

syn region wingsString    	start=+"+ end=+"+
syn region wingsChar    	start=+'+ end=+'+

" Rx, Fx, Lx, Sx
syn match wingsRegister           "\<[Rr]\([0-9a-f]\|[0-9a-f][0-9a-f]\|[0-9a-f][0-9a-f][0-9a-f]\)\>" 
syn match wingsRegister           "\<[Ff]\([0-9a-f]\|[0-9a-f][0-9a-f]\|[0-9a-f][0-9a-f][0-9a-f]\)\>" 
syn match wingsRegister           "\<[Ss]\([0-9a-f]\|[0-9a-f][0-9a-f]\|[0-9a-f][0-9a-f][0-9a-f]\)\>" 
syn match wingsRegister           "\<[Ll]\([0-9a-f]\|[0-9a-f][0-9a-f]\|[0-9a-f][0-9a-f][0-9a-f]\)\>" 

" List of commands
syn keyword wingsCommands  	 1394 1394B 1394MONITOR ADD ALTITUDE AND ASL SL ASR SR
syn keyword wingsCommands  	 BIT BROWSE BUSMSG BUSRESET CAPTURE CALL LCALL CHECKSUM 
syn keyword wingsCommands  	 CLEARALL CLEARCOMMANDWINDOW CLEARSTATUSWINDOW CLEARPHMWINDOW
syn keyword wingsCommands  	 CLEARPRINTLOG CLOSE CLEAR CMP CMPL COMMDLL COMMTS COMPORT
syn keyword wingsCommands  	 CONTINUE COMMENT DBE DB DIO DIO1553 DIONI DIR
syn keyword wingsCommands  	 SET GET INI OSCOPE SHARED SHOW DEFAULT DSDATABASE
syn keyword wingsCommands  	 DSHSRECORD DSINPUT INI DSMAIN DSMSGSUM DSNAV
syn keyword wingsCommands  	 DSOUTPUT DSPHM DSPLOT DSLSRECORD DOPWR EMERGENCY ENABLE EXTRACT
syn keyword wingsCommands  	 EXIT FC FCSTAT FILE FSPRMESSAGE FSPRPMESSAGE FSUBTRACT FTP
syn keyword wingsCommands  	 GOTO UUT IODETECT LOAD GF LOADL LSL LSRECFILENAME
syn keyword wingsCommands  	 LSRECEN LSR MATH MDFILE MD MP MSGCPY MESSAGE
syn keyword wingsCommands  	 NOT OD OPERATOR OR PLOGFILE PLOG ELOGFILE ELOG
syn keyword wingsCommands  	 PATTERN PLOT POSTDATA POST OUT POUT PRINT PRINTLOG
syn keyword wingsCommands  	 SNAP PAUSE PHMLOGFILE PPOS RUN SCR HSPB HSRECSIM
syn keyword wingsCommands  	 HSRCSV HSRECFILE HSRECM HSRECPATH HSRECEN HSRECTIME HSRECRATE RECORD
syn keyword wingsCommands  	 PLAY PROMPT RELAY RL RR RESET RETURN LRETURN
syn keyword wingsCommands  	 LSPRMESSAGE LSPRPMESSAGE SAVEWINGSINFO SATCOVCLEAR SN SPRMESSAGE SPRPMESSAGE STRINGLENGTH
syn keyword wingsCommands  	 STRINGPOSITION STRINGTRIM STATUSLOG STEP STOP SUBSTRING SUBTRACT
syn keyword wingsCommands  	 TESTSTAND TEST TITLE TN TRACE TRANSMIT TX TRIM
syn keyword wingsCommands  	 UPDATE VMC VPC WAIT WINGSKEYSENCODE WINGSKEYSDECODE XGRID XMAXIMUM
syn keyword wingsCommands  	 XMINIMUM XOR XOFF XUNITS XMULTIPLY XALIAS XINTERVAL YALIAS
syn keyword wingsCommands  	 YAUTO YDESCRIPTION YENABLE YGRID YMAXIMUM YMINMUM YPENCOLOR YPENWIDTH
syn keyword wingsCommands  	 YMULTIPLY YOFF YSTAIR YUNITS RET JMP STACKPUSH PMESS FSPRP
syn keyword wingsCommands  	 INJECT IN OFP SPRP PMESSAGE JUMP CI FILESEARCH DMM

syn keyword wingsLog    	 STATUS

syn keyword wingsOk             OK PASS

syn keyword wingsFail           FAIL
syn match wingsFail           "Syntax Error.*$"
syn match wingsFail           "Script Error.*$"

" syn match wingsLabel      	"_^:[A-Z]_$"
syn match wingsFail           "/\_^[a-zA-Z].*$"
                                  
syn match wingsFlgas          "\sZ\s"
syn match wingsFlgas          "\sN\s"
syn match wingsFlgas          "\sG\s"
syn match wingsFlgas          "\sL\s"
syn match wingsFlgas          "\sS\s"
syn match wingsFlgas          "\sC\s"
syn match wingsFlgas          "\sE\s"

" OpCodes...
" So that only wingsCommands are recognized
syn match wingsOpcode  		"\$[a-z]*"
syn match wingsOpcode  		"&"
syn match wingsOpcode  		"\*"

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_wings_syntax_inits")
  if version < 508
    let did_wings_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink wingsTodo		Todo
  HiLink wingsLabel		Type
  HiLink wingsString		String
  HiLink wingsChar		String
  HiLink wingsOpcode		Statement
  HiLink wingsCommands		Statement
  HiLink wingsRegister		StorageClass
  HiLink hexNumber		Number
  HiLink decNumber		Number
  HiLink octNumber		Number
  HiLink binNumber		Number
  HiLink wingsIdentifier	Identifier
  HiLink wingsFlgas		Special
  HiLink wingsLog		Identifier
  HiLink wingsOk		PreProc
  HiLink wingsFail		Error
  HiLink wingsComment		Comment

  delcommand HiLink
endif

let b:current_syntax = "wings_syntax"

" vim: ts=8
