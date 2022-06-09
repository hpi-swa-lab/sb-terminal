Class {
	#name : #SBBashTerminal,
	#superclass : #SBBlock,
	#instVars : [
		'commandBlocks',
		'commands',
		'pty',
		'closed',
		'state',
		'monitorSemaphor',
		'synopsis',
		'synopsisBlock'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTerminal >> attributesFrom: aString [

	(aString = '' or: (aString = '0' or: aString = '00')) ifTrue: [^ OrderedCollection newFrom: {TextColor black}].
	^ (aString findTokens: $;) collect: [:attribute |
		attribute
			caseOf: {
				[#'30'] -> [TextColor black].
				[#'31'] -> [TextColor red].
				[#'32'] -> [TextColor green].
				[#'33'] -> [TextColor yellow].
				[#'34'] -> [TextColor blue].
				[#'35'] -> [TextColor magenta].
				[#'36'] -> [TextColor cyan].
				[#'37'] -> [TextColor white].
				[#'97'] -> [TextColor white].
				[#'96'] -> [TextColor cyan].
				[#'95'] -> [TextColor magenta].
				[#'94'] -> [TextColor blue].
				[#'93'] -> [TextColor yellow].
				[#'92'] -> [TextColor green].
				[#'91'] -> [TextColor red].
				[#'90'] -> [TextColor black]}
			otherwise: [TextColor black]]
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
SBBashTerminal >> evaluateEscapeSequence: sequence prevState: prevState [
	"set title"

	(sequence upTo: $;) = ']0' ifTrue: [ | title |
		title := 'm', sequence upTo: (Character value: 7).
		state := prevState].
	"set ps1"
	sequence = ']81' ifTrue: [state := #ps1].
	"set output"
	sequence = ']80' ifTrue: [state := #output].
	"don't set anything"
	sequence = ']82' ifTrue: [state := #hidden]
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

	| scroll |
	super initialize.
	
	self
		addMorphBack: (scroll := ScrollPane new
			hResizing: #spaceFill;
			vResizing: #rigid;
			height: 150);
		addMorphBack: (synopsisBlock := SBTextBubble multiLine);
		listDirection: #leftToRight;
		cellGap: 4;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		minWidth: 600;
		changeTableLayout;
		layoutInset: 4.
	
	scroll scroller addMorphBack: (commandBlocks := SBBlock new
		changeTableLayout;
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		cellGap: 4).
	commands := OrderedCollection new.
	monitorSemaphor := Semaphore new.
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
	pty nextPutAll: 'PS1="\e]81m${PS1}\e]80m"'.
	pty nextPut: Character return.
	state := #output.
	process := [[self readDataFromBash] doWhileFalse: [closed]] fork
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> monitorSemaphor [

	^ monitorSemaphor
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
	(ps1 = '') not ifTrue: [
		Project current addDeferredUIMessage: [ | newCommandBlock |
			commandBlocks addMorphBack: (newCommandBlock := SBBashCommandBlock new).
			newCommandBlock ps1: ps1.
			newCommandBlock focus]]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> readFrom: input writeInto: ps1 and: output [

	| sequence attributes prevState |
	attributes := {TextColor black}.
	"TODO: escape code lesen als eigene Methode und dann direkt hinter state = #output oder #ps1 aufrufen statt eigenen State dafür zu machen"
	[input atEnd] whileFalse: [
		state
			caseOf: {
				[#escape] -> [
					sequence := input upTo: $m.
					(sequence beginsWith: '[')
						ifTrue: [
							"text attributes"
							attributes := self attributesFrom: (sequence from: 2).
							state := prevState]
						ifFalse: [
							"side effects"
							(sequence beginsWith: ']0;') ifTrue: [sequence := sequence, (input upTo: (Character value: 7))].
							self evaluateEscapeSequence: sequence prevState: prevState]].
				[#output] -> [ | outBuffer |
					outBuffer := input upTo: Character escape.
					outBuffer = Character lf asString ifFalse: [
						output append: (outBuffer asText
							addAllAttributes: attributes;
							addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont))].
					input atEnd ifFalse: [
						prevState := state.
						state := #escape]].
				[#ps1] -> [
					ps1 append: ((input upTo: Character escape) asText
						addAllAttributes: attributes;
						addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
					input atEnd ifFalse: [
						prevState := state.
						state := #escape]].
				[#autocomplete] -> [
					"This is the part the user wrote"
					self currentCommandBlock input: (input upTo: Character return).
					state := #autocomplete2].
				[#autocomplete2] -> [
					"This is the part we autocomplete"
					self currentCommandBlock addInput: input upToEnd.
					state := #hidden.
					pty nextPut: (Character value: 21).
					self currentCommandBlock inputBlock moveCursorToEnd.
					monitorSemaphor signal].
				[#hidden] -> [
					input upToEnd.
					SBToggledCode comment: '' active: 0 do: {[input upTo: Character return]}.
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

{ #category : #'as yet unclassified' }
SBBashTerminal >> synopsis [

	^ synopsis
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> synopsis: aString [

	Transcript showln: aString.
	synopsisBlock contents: aString.
	synopsis := aString
]
