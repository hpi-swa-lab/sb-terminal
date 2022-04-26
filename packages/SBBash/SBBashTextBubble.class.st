Class {
	#name : #SBBashTextBubble,
	#superclass : #SBTextBubble,
	#instVars : [
		'pty'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashTextBubble >> absorbsInput: anEvent [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> addBashOutput: aString [

	self contents: self contents, aString
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> initialize [

	super initialize.
	
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

	pty nextPut: anEvent keyCharacter
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> launchBash [

	(pty := PseudoTTY command: '/bin/bash' arguments: {'-i'}) isNil ifTrue: [^ self error: 'could not create process'].
	
	[[self readDataFromBash] repeat] fork
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	pty close
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> readDataFromBash [

	| buf output |
	pty isConnected ifFalse: [^ nil].
	(buf := pty peekUpToEnd) isNil ifTrue: [buf := pty upToEnd].
	
	output := '' writeStream.
	SBToggledCode
		comment: ''
		active: 1
		do: {[output nextPutAll: buf asString]. [self readFrom: buf asString readStream writeInto: output]}.
	Project current addDeferredUIMessage: [self addBashOutput: output contents]
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> readFrom: input writeInto: output [

	| state sequence |
	state := #read.
	[input atEnd] whileFalse: [
		state = #escape ifTrue: [
			sequence := input upToAnyOf: #($; $m).
			"color"
			
			sequence = '[01' ifTrue: [ | foregroundColor |
				foregroundColor := input upTo: $m.
				state := #read].
			"reset color"
			sequence = '[00' ifTrue: [state := #read].
			"set title"
			sequence = ']0' ifTrue: [ | title |
				title := input upTo: (Character value: 7).
				state := #read]].
		input peek = Character escape ifTrue: [
			state := #escape.
			input next].
		state = #read ifTrue: [
			output nextPutAll: (input upTo: Character escape).
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
