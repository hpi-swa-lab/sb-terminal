Class {
	#name : #SBBashTerminal,
	#superclass : #SBBlock,
	#instVars : [
		'commandBlocks',
		'commands',
		'currentCommandIndex',
		'pty',
		'closed',
		'state',
		'monitorSemaphor',
		'synopsis',
		'synopsisBlock',
		'description',
		'waitingForCommandString',
		'debugOutput',
		'allCommands',
		'examples',
		'pwd'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTerminal class >> registerShortcuts: aProvider [

	aProvider registerShortcut: Character arrowUp do: #recallCommandUp.
	aProvider registerShortcut: Character arrowDown do: #recallCommandDown
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> allCommands [

	^ allCommands
]

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
			otherwise: [TextColor gray]]
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

	^ commandBlocks submorphs at: currentCommandIndex
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> debugOutput: aString [

	self sandblockEditor debugBlock contents: aString.
	debugOutput := aString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> description [

	^ description
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> description: aString [

	self sandblockEditor descriptionBlock contents: (aString ifNil: ['']).
	description := aString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> evaluateEscapeSequence: sequence prevState: prevState [
	"set title"

	(sequence copyUpTo: $;) = ']0' ifTrue: [ | title |
		title := 'm', sequence copyUpTo: (Character value: 7).
		state := prevState].
	"set ps1"
	sequence = ']81' ifTrue: [state := #ps1].
	"set output"
	sequence = ']80' ifTrue: [state := #output].
	"don't set anything"
	sequence = ']82' ifTrue: [state := #hidden]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> examples: aString [

	self sandblockEditor examplesBlock contents: aString.
	examples := aString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> focus [

	self newestCommandBlock focus
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> getPreviousCommandString [

	| commandString |
	currentCommandIndex := currentCommandIndex > 1
		ifTrue: [currentCommandIndex - 1]
		ifFalse: [currentCommandIndex].
	commandString := self currentCommandBlock commandString.
	^ commandString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> getSubsequentCommandString [

	| commandString |
	currentCommandIndex := currentCommandIndex < commandBlocks childSandblocks size
		ifTrue: [currentCommandIndex + 1]
		ifFalse: [currentCommandIndex].
	commandString := self currentCommandBlock commandString.
	^ commandString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> initialize [

	super initialize.
	
	self
		addMorphBack: (commandBlocks := SBBlock new
			changeTableLayout;
			listDirection: #topToBottom;
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			cellGap: 4);
		listDirection: #leftToRight;
		cellGap: 4;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		changeTableLayout;
		layoutInset: 4.
	
	commands := OrderedCollection new.
	currentCommandIndex := 1.
	monitorSemaphor := Semaphore new.
	self launchBash
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> insertCommandRequest: aMorph near: aBlock before: aBoolean [

	^ nil
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
	commands := (Json readFrom: (UnixProcess thisOSProcess waitForCommandOutput: 'cat ', SBBashEditor pathToAllManpageData) readStream) collect: [:cmd | SBBashCommand newFromJson: cmd forTerminal: self].
	pty nextPutAll: ' PS1="\e]81m${PS1}\e]80m"'.
	pty nextPut: Character return.
	state := #output.
	process := [[self readDataFromBash] doWhileFalse: [closed]] fork
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> monitorSemaphor [

	^ monitorSemaphor
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> newestCommandBlock [

	^ commandBlocks lastSubmorph
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
SBBashTerminal >> pwd [

	^ pwd
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> pwd: aText [

	| ps1Parts unexpandedPwd homeIndex |
	ps1Parts := aText string findBetweenSubStrs: ':$'.
	ps1Parts removeLast.
	unexpandedPwd := ps1Parts last.
	homeIndex := unexpandedPwd findString: '~'.
	homeIndex = 1
		ifTrue: [ | pathParts subst |
			pathParts := (UnixProcess thisOSProcess environmentAt: #PWD) findBetweenSubStrs: '/'.
			subst := '/', ((pathParts copyFrom: 1 to: 2) joinSeparatedBy: '/').
			pwd := subst, (unexpandedPwd from: 2)]
		ifFalse: [pwd := unexpandedPwd]
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
	((commandBlocks submorphs size = 0) not and: (output = '') not) ifTrue: [Project current addDeferredUIMessage: [self newestCommandBlock output: output]].
	ps1 ~= ''
		ifTrue: [
			Project current addDeferredUIMessage: [ | newCommandBlock |
				commandBlocks addMorphBack: (newCommandBlock := SBBashCommandBlock new).
				self pwd: ps1.
				newCommandBlock ps1: ps1.
				newCommandBlock focus]]
		ifFalse: [
			((output asString includesSubstring: '[sudo]') and: [output asString includesSubstring: 'password']) ifTrue: [
				pty nextPutAll: (UIManager default requestPassword: 'enter password').
				pty nextPut: Character return
				"otherwise: send cmd + C ?"]]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> readFrom: input writeInto: ps1 and: output [

	| attributes prevState |
	attributes := {TextColor black}.
	"TODO: escape code lesen als eigene Methode und dann direkt hinter state = #output oder #ps1 aufrufen statt eigenen State dafür zu machen"
	[input atEnd] whileFalse: [
		state
			caseOf: {
				[#escape] -> [
					input peek = $[
						ifTrue: [ | sequence |
							"control sequence introducer"
							sequence := input next asText.
							[input atEnd or: [sequence last isLetter]] whileFalse: [sequence append: input next].
							sequence last = $m ifTrue: ["text attributes"
							attributes := self attributesFrom: (sequence asString from: 2 to: sequence size - 1)].
							state := prevState]
						ifFalse: [ | sequence |
							"side effects"
							sequence := input upTo: $m.
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
					self newestCommandBlock input: (input upTo: Character return).
					state := #autocomplete2].
				[#autocomplete2] -> [
					"This is the part we autocomplete"
					self currentCommandBlock addInput: input upToEnd.
					state := #hidden.
					pty nextPut: (Character value: 21).
					self currentCommandBlock inputBlock moveCursorToEnd.
					monitorSemaphor signal].
				[#hidden] -> [
					"enter is actually cr + lf + '>' + ' ' and therefore counts as 4 characters"
					input next: waitingForCommandString size + 1 + ((waitingForCommandString occurrencesOf: Character cr) * 3).
					state := #output]}
			otherwise: [input next]]
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> refreshCommandIndex [

	currentCommandIndex := commandBlocks childSandblocks size + 1
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> semantics [

	^ SBBashInput
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
SBBashTerminal >> synopsis: aString [

	aString
		ifNil: [
			self sandblockEditor synopsisBlock emphasis: TextEmphasis normal.
			self sandblockEditor synopsisCaption emphasis: TextEmphasis normal]
		ifNotNil: [
			self sandblockEditor synopsisBlock emphasis: TextEmphasis bold.
			self sandblockEditor synopsisCaption emphasis: TextEmphasis normal].
	self sandblockEditor synopsisBlock contents: (aString ifNil: ['']).
	synopsis := aString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> waitingForCommandString [

	^ waitingForCommandString
]

{ #category : #'as yet unclassified' }
SBBashTerminal >> waitingForCommandString: aString [

	waitingForCommandString := aString
]
