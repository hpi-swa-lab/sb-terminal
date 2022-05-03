Class {
	#name : #SBBashTextBubble,
	#superclass : #SBTextBubble,
	#instVars : [
		'pty',
		'closed'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTextBubble >> absorbsInput: anEvent [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> addBashOutput: aString [

	self contents: self contents asText, aString
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> colorFrom: parameter [

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
SBBashTextBubble >> initialize [

	super initialize.
	
	self font: TextStyle defaultFixedFont.
	self launchBash
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> isEscapeSequenceOrControlCode: aBuffer [
	"return"

	aBuffer = #[8] asOrderedCollection ifTrue: [^ true].
	"set title"
	aBuffer = #[27 93 48 59] asOrderedCollection ifTrue: [^ true].
	aBuffer = #[27 91 48 48 109] asOrderedCollection ifTrue: [^ true].
	aBuffer = #[27 91 48 48 109] asOrderedCollection ifTrue: [^ true].
	"ESC [ 0 1 ; 3 4 m
wird aktuell von set title rausgefiltert"
	aBuffer = #[27 91 48 49 59 51 52 109] asOrderedCollection ifTrue: [^ true].
	aBuffer = #[27 91 48 49 59 51 50 109] asOrderedCollection ifTrue: [^ true].
	"bell"
	aBuffer = #[7] asOrderedCollection ifTrue: [^ true].
	^ false
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> keyStroke: anEvent [

	Transcript showln: ''.
	Transcript showln: 'keyStroke: '.
	Transcript showln: anEvent.
	pty nextPut: anEvent keyCharacter
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> launchBash [

	(pty := PseudoTTY command: '/bin/bash' arguments: {'-i'}) isNil ifTrue: [^ self error: 'could not create process'].
	
	closed := false.
	pty nextPutAll: 'PS1="\033[81m${PS1}\033[80m"'.
	pty nextPut: Character return.
	[[self readDataFromBash] doWhileFalse: [closed]] fork
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	closed := true.
	
	pty close
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> pty [

	^ pty
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> readDataFromBash [

	| buf output |
	(pty isConnected not or: [closed]) ifTrue: [^ nil].
	Processor yield.
	(buf := pty peekUpToEnd) isNil ifTrue: [buf := pty upToEnd].
	output := '' asText.
	self readFrom: buf asString readStream writeInto: output.
	Project current addDeferredUIMessage: [self addBashOutput: output]
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> readFrom: input writeInto: output [

	| state sequence color |
	state := #read.
	color := TextColor black.
	SBToggledCode comment: '' active: 1 do: {
		[
			Transcript showln: 'stream: '.
			Transcript show: input contents].
		[output append: input upToEnd]}.
	[input atEnd] whileFalse: [
		state = #escape ifTrue: [
			sequence := input upToAnyOf: #($; $m).
			"color"
			sequence = '[01' ifTrue: [
				color := self colorFrom: (input upTo: $m).
				state := #read].
			"reset all attributes"
			(sequence = '[00' or: sequence = '[0') ifTrue: [
				color := TextColor black.
				state := #read].
			"set title"
			sequence = ']0' ifTrue: [ | title |
				title := input upTo: (Character value: 7).
				state := #read]].
		input peek = Character escape ifTrue: [
			state := #escape.
			input next].
		state = #read ifTrue: [
			output append: ((input upTo: Character escape) asText
				addAttribute: color;
				addAttribute: (TextFontReference toFont: TextStyle defaultFixedFont)).
			state := #escape]]
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> removeEscapeSequences: aBuffer [

	| inSeq newBuf sequenceBuffer |
	inSeq := false.
	aBuffer isNil ifTrue: [^ aBuffer].
	sequenceBuffer := OrderedCollection new.
	newBuf := OrderedCollection new.
	"wenn wir esc finden --> in Stream schreiben und immer mit
Sequences vergleichen
wenn es nach 10 Zeichen nicht dabei ist oder noch ein esc kommt
--> wieder in den Buffer schreiben, ggf. neuen Stream"
	aBuffer do: [:e |
		e = 27 ifTrue: [
			newBuf addAll: sequenceBuffer.
			sequenceBuffer := OrderedCollection new.
			inSeq := true].
		inSeq
			ifTrue: [
				sequenceBuffer add: e.
				(self isEscapeSequenceOrControlCode: sequenceBuffer) ifTrue: [sequenceBuffer := OrderedCollection new].
				sequenceBuffer size >= 10 ifTrue: [
					newBuf addAll: sequenceBuffer.
					sequenceBuffer := OrderedCollection new]]
			ifFalse: [newBuf add: e]].
	newBuf addAll: sequenceBuffer.
	^ newBuf asByteArray
]
