Class {
	#name : #SBBashTerminal,
	#superclass : #SBBlock,
	#instVars : [
		'commandBlocks',
		'commands',
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
SBBashTerminal >> commands [

	^ commands
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> commands: anObject [

	commands := anObject
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> currentCommandBlock [

	^ commandBlocks lastSubmorph
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> example [

	SBMorphExample
		setUp: [self class new]
		cases: {SBMorphExampleCase name: 'example 1' caseBlock: [:m | m]}
		extent: 300 @ 300
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> initialize [

	super initialize.
	
	self
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
	
	commands := OrderedCollection new.
	self launchBash
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> launchBash [

	| process |
	(pty := PseudoTTY command: '/bin/bash' arguments: {'-i'}) isNil ifTrue: [^ self error: 'could not create process'].
	
	closed := false.
	pty nextPutAll: 'PS1="\e[81m${PS1}\e[80m"'.
	pty nextPut: Character return.
	state := #initial.
	process := [[self readDataFromBash] doWhileFalse: [closed]] fork
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	closed := true.
	pty close
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> pty [

	^ pty
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
	((commandBlocks submorphs size = 0) not and: (output = '') not) ifTrue: [Project current addDeferredUIMessage: [self currentCommandBlock output: output]].
	(ps1 = '') not ifTrue: [ | newCommandBlock |
		commandBlocks addMorphBack: (newCommandBlock := SBBashCommandBlock new).
		newCommandBlock ps1: ps1.
		Project current addDeferredUIMessage: [newCommandBlock focus]]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> readFrom: input writeInto: ps1 and: output [

	| sequence foreGround prevState |
	foreGround := TextColor black.
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
						foreGround := self colorFrom: (input upTo: $m).
						state := prevState].
					"reset all attributes"
					(sequence = '[00' or: sequence = '[0') ifTrue: [
						foreGround := TextColor black.
						state := prevState].
					"set title"
					sequence = ']0' ifTrue: [ | title |
						title := input upTo: (Character value: 7).
						state := prevState].
					"set ps1"
					sequence = '[81' ifTrue: [state := #ps1].
					"set output"
					sequence = '[80' ifTrue: [state := #output].
					"don't set anything"
					sequence = '[82' ifTrue: [state := #hidden]].
				[#output] -> [
					output append: ((input upTo: Character escape) asText
						addAttribute: foreGround;
						addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
					input atEnd ifFalse: [
						prevState := state.
						state := #escape]].
				[#ps1] -> [
					ps1 append: ((input upTo: Character escape) asText
						addAttribute: foreGround;
						addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
					input atEnd ifFalse: [
						prevState := state.
						state := #escape]].
				[#autocomplete] -> [
					"This is the part the user wrote"
					(input upTo: Character return) size.
					state := #autocomplete2].
				[#autocomplete2] -> [ | toBeDeleted |
					"This is the part we autocomplete"
					Transcript showln: self currentCommandBlock input.
					self currentCommandBlock input: (input upTo: Character backspace).
					toBeDeleted := self currentCommandBlock input size.
					Transcript showln: toBeDeleted.
					Transcript showln: self currentCommandBlock input.
					(1 to: toBeDeleted) do: [:e | pty nextPut: Character backspace].
					"TODO: Cursor an die letzte Position"
					state := #output].
				[#hidden] -> [
					input upTo: Character return.
					state := #output]}
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

{ #category : #'as yet unclassified' }
SBBashTerminal >> state [

	^ state
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> state: aSymbol [

	state := aSymbol
]
