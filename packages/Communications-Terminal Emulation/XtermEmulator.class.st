"
I emulate a xterm terminal.  The xterm is a modern member of the DEC VT200 family with additional ANSI functions including support for ISO 6429 colour escape sequences.  I am particularly useful for full-screen programs that know how to use colour highlighting (such as Emacs version 21 and higher).

I inherit from VT102Emulator because I implement a proper superset of its capabilities.

See the class comments in my superclasses (VT102Emulator in particular) for further information on how to use me.
"
Class {
	#name : #XtermEmulator,
	#superclass : #VT102Emulator,
	#instVars : [
		'savedBuffer'
	],
	#category : #'Communications-Terminal Emulation'
}

{ #category : #'class initialization' }
XtermEmulator class >> initialize [
	"XtermEmulator initialize"

	super initialize.
	States _ self protocol compile
]

{ #category : #'instance creation' }
XtermEmulator class >> new [
	"XtermEmulator new"

	^super new initialState: States
]

{ #category : #'class initialization' }
XtermEmulator class >> protocol [
	"XtermEmulator initialize"
	"XTerm is just a glorified VT102."

	| desc |
	desc _ super protocol.	"Vanilla VT102"

	"Additional control sequences"
	(desc at: #csi)
		addInteger:		$@			-> (#ich:					-> #relax);	"insert character"
		addInteger:		$d			-> (#lpa:					-> #relax);	"line position abs"
		addInteger:		$G			-> (#cha:					-> #relax);	"char position abs"
		addInteger:		$L			-> (#il:						-> #relax);	"insert line(s)"
		addInteger:		$P			-> (#dch:					-> #relax).	"delete character(s)"

	"Operating system commands"
	(desc at: #esc)
		addInteger:		$]			-> (#clearArguments:		-> #csix).

	"Xterm CSI has a numeric prefix delimited by `;' and textual suffix delimited by BEL"
	(desc newState:		#csix		-> (nil						-> nil))	"ignore everything except..."
		addAllInteger:	'0123456789'	-> (#addArgument:			-> nil);
		addInteger:		$;			-> (#newStringArgument:	-> #csix2);
		add:				8r007		-> (nil						-> #relax).	"premature BEL"

	(desc newState:		#csix2		-> (#addStringArgument:		-> nil))		"eat everything except..."
		add:				8r007		-> (#osc:					-> #relax).	"OSC complete"
	^desc
]

{ #category : #accessing }
XtermEmulator class >> terminalTypeName [

	^'xterm'
]

{ #category : #arguments }
XtermEmulator >> addStringArgument: arg [

	arguments
		at: arguments size
		put: (arguments last , (String with: arg asCharacter))
]

{ #category : #'control sequences' }
XtermEmulator >> cha: arg [
	"Character Position Absolute"

	self trace: 'CHA ' , (arguments first max: 1) printString.
	window activeColumn: (arguments first max: 1)
]

{ #category : #'control sequences' }
XtermEmulator >> dch: arg [
	"Delete Character(s)"

	| n |
	n _ (arguments at: 1 ifAbsent: [1]) max: 1.
	window deleteForward: n
	
]

{ #category : #'control sequences' }
XtermEmulator >> decrmSingle: param [

	self trace: 'DECSM' with: param.
	param == 1047 ifTrue: [^self restoreBuffer].
	param == 1048 ifTrue: [^self restoreState].
	param == 1049 ifTrue: [^self restoreBuffer; restoreState.].
	super decrmSingle: param
]

{ #category : #'control sequences' }
XtermEmulator >> decsmSingle: param [

	self trace: 'DECSM' with: param.
	param == 1047 ifTrue: [^self saveBuffer].
	param == 1048 ifTrue: [^self saveState].
	param == 1049 ifTrue: [self saveState; saveBuffer. ^window clearScreen; activePosition: 1@1].
	super decsmSingle: param
]

{ #category : #'control sequences' }
XtermEmulator >> ich: arg [
	"Insert Character(s)"

	| n |
	n _ (arguments at: 1 ifAbsent: [1]) max: 1.
	self trace: 'ICH ' , n printString.
	window insert: n
	
]

{ #category : #'control sequences' }
XtermEmulator >> il: arg [
	"Insert Line(s)"

	| n |
	n _ (arguments at: 1 ifAbsent: [1]) max: 1.
	window insertLines: n
	
]

{ #category : #'initialize-release' }
XtermEmulator >> initialize [

	super initialize.
	savedBuffer _ nil
]

{ #category : #'control sequences' }
XtermEmulator >> lpa: arg [
	"Line Position Absolute"

	| y x |
	y _ 1.
	x _ window activeColumn.
	arguments size > 0 ifTrue: [y _ arguments first].
	arguments size > 1 ifTrue: [x _ arguments at: 2].
	window activePosition: x@y
]

{ #category : #arguments }
XtermEmulator >> newStringArgument: arg [

	arguments addLast: ''
]

{ #category : #protocol }
XtermEmulator >> note: aSymbol with: anObject [

	super note: aSymbol with: anObject.
	aSymbol == #endpointClosed ifTrue: [^self restoreBuffer].
]

{ #category : #'control sequences' }
XtermEmulator >> osc: arg [
	"Operating System Command"

	| type |
	type _ arguments first.
	(type == 0 or: [type == 1]) ifTrue: [window setIconTitle: arguments last].
	(type == 0 or: [type == 2]) ifTrue: [window setWindowTitle: arguments last].
	"All others are silently ignored"
]

{ #category : #private }
XtermEmulator >> restoreBuffer [
	"Restore the tty to its previously saved state."

	savedBuffer isNil ifFalse: [window bufferState: savedBuffer].
	window setEmacsColours: false
]

{ #category : #private }
XtermEmulator >> restoreState [
	"Pretend we saw Restore Cursor"

	^self decrc: nil
]

{ #category : #private }
XtermEmulator >> saveBuffer [
	"Save a copy of the current state of the tty."

	savedBuffer _ window bufferState.
	window setEmacsColours: true
]

{ #category : #private }
XtermEmulator >> saveState [
	"Pretend we saw Save Cursor"

	^self decsc: nil
]

{ #category : #'control sequences' }
XtermEmulator >> sgrSingle: arg [

	self trace: 'SGR' with: arg.
	"ANSI colour codes"
	arg == 24 ifTrue: [^window setEmphasis: 4 to: 0].
	arg == 25 ifTrue: [^window setEmphasis: 5 to: 0].
	arg == 27 ifTrue: [^window setEmphasis: 7 to: 0].
	(arg >= 30 and: [arg <= 37]) ifTrue: [^window setForeground: arg - 30].
	arg == 39 ifTrue: [^window setForeground: 0].
	(arg >= 40 and: [arg <= 47]) ifTrue: [^window setBackground: arg - 40].
	arg == 49 ifTrue: [^window setBackground: 7].
	super sgrSingle: arg
]

{ #category : #identification }
XtermEmulator >> terminalTypeString [
	"Viz: RFCs 930 (Telnet Terminal Type Option) and 1700 (Assigned Numbers)"

	^'XTERM'
]
