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
SBBashTextBubble >> keyStroke: anEvent [

	pty nextPut: anEvent keyCharacter
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> launchBash [

	(pty := PseudoTTY command: '/bin/bash' arguments: {'-i'}) isNil ifTrue: [^ self error: 'could not create process'].
	
	[[pty isConnected] whileTrue: [self readDataFromBash]] fork
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	pty close
]

{ #category : #'as yet unclassified' }
SBBashTextBubble >> readDataFromBash [

	| buf |
	pty isConnected ifFalse: [^ nil].
	(buf := pty peekUpToEnd) isNil ifTrue: [
		buf := pty upToEnd.
		Transcript showln: buf.
		Project current addDeferredUIMessage: [self addBashOutput: buf]].
	^ buf
]
