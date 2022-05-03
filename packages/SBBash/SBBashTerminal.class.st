Class {
	#name : #SBBashTerminal,
	#superclass : #SBBlock,
	#instVars : [
		'commandBlocks',
		'pty',
		'closed',
		'state'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTerminal >> colorFrom: parameter [

	parameter = '30' ifTrue: [^ TextColor black].
	parameter = '31' ifTrue: [^ TextColor red].
	parameter = '32' ifTrue: [^ TextColor green].
	parameter = '33' ifTrue: [^ TextColor yellow].
	parameter = '34' ifTrue: [^ TextColor blue].
	parameter = '35' ifTrue: [^ TextColor magenta].
	parameter = '36' ifTrue: [^ TextColor cyan].
	parameter = '37' ifTrue: [^ TextColor white].
	parameter = '90' ifTrue: [^ TextColor gray].
	parameter = '91' ifTrue: [^ TextColor red].
	parameter = '92' ifTrue: [^ TextColor green].
	parameter = '93' ifTrue: [^ TextColor yellow].
	parameter = '94' ifTrue: [^ TextColor blue].
	parameter = '95' ifTrue: [^ TextColor magenta].
	parameter = '96' ifTrue: [^ TextColor cyan].
	parameter = '97' ifTrue: [^ TextColor white].
	^ TextColor black
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBButton new onClick: [self startREPL]);
		addMorphBack: (commandBlocks := SBBlock new
			changeTableLayout;
			listDirection: #topToBottom;
			hResizing: #spaceFill;
			vResizing: #shrinkWrap;
			cellGap: 4);
		cellGap: 4;
		hResizing: #rigid;
		vResizing: #shrinkWrap;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		width: 600;
		changeTableLayout;
		layoutInset: 4.
	
	self launchBash
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> launchBash [

	(pty := PseudoTTY command: '/bin/bash' arguments: {'-i'}) isNil ifTrue: [^ self error: 'could not create process'].
	
	closed := false.
	pty nextPutAll: 'PS1="\e[81m${PS1}\e[80m"'.
	pty nextPut: Character return.
	state := #initial.
	[[self readDataFromBash] doWhileFalse: [closed]] fork
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	closed := true.
	pty close
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> readDataFromBash [

	| buf output ps1 |
	(pty isConnected not or: [closed]) ifTrue: [^ nil].
	Processor yield.
	(buf := pty peekUpToEnd) isNil ifTrue: [buf := pty upToEnd].
	ps1 := '' asText.
	output := '' asText.
	self readFrom: buf asString readStream writeInto: ps1 and: output.
	ps1 = '' ifFalse: [ | newCommandBlock |
		commandBlocks addMorphBack: (newCommandBlock := SBBashCommandBlock new).
		newCommandBlock ps1: ps1].
	commandBlocks submorphs size = 0 ifFalse: [Project current addDeferredUIMessage: [commandBlocks lastSubmorph output: output]]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> readFrom: input writeInto: ps1 and: output [

	| sequence prevState |
	color := TextColor black.
	"TODO: escape code lesen als eigene Methode und dann direkt hinter state = #output oder #ps1 aufrufen statt eigenen State dafür zu machen"
	[input atEnd] whileFalse: [
		input peek = Character escape ifTrue: [
			prevState := state.
			state := #escape.
			input next].
		state
			caseOf: {
				[#escape] -> [
					sequence := input upToAnyOf: #($; $m).
					"color"
					"TODO: weitere Attribute mit ; getrennt beachten!"
					sequence = '[01' ifTrue: [
						color := self colorFrom: (input upTo: $m).
						state := prevState].
					"reset all attributes"
					(sequence = '[00' or: sequence = '[0') ifTrue: [
						color := TextColor black.
						state := prevState].
					"set title"
					sequence = ']0' ifTrue: [ | title |
						title := input upTo: (Character value: 7).
						state := prevState].
					"set ps1"
					sequence = '[81' ifTrue: [state := #ps1].
					"set output"
					sequence = '[80' ifTrue: [state := #output]].
				[#output] -> [
					output append: ((input upTo: Character escape) asText
						addAttribute: color;
						addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
					prevState := state.
					state := #escape].
				[#ps1] -> [
					ps1 append: ((input upTo: Character escape) asText
						addAttribute: color;
						addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
					prevState := state.
					state := #escape]}
			otherwise: [input next]]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> startREPL [

	| input |
	pty.
	[
		[
			input := UIManager default request: 'input'.
			pty nextPutAll: input.
			pty nextPut: Character return] doWhileFalse: [input isEmpty]] fork
]
