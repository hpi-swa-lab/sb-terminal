Class {
	#name : #SBBashInputTextBubble,
	#superclass : #SBTextBubble,
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> keyStroke: anEvent [

	anEvent keyCharacter = Character return
		ifTrue: [ | pty terminal |
			"TODO: Tom fragen, wie man das macht"
			terminal := self parentSandblock parentSandblock parentSandblock.
			pty := terminal pty.
			"next command should not be printed"
			terminal state: #hidden.
			pty nextPutAll: self contents.
			pty nextPut: Character return]
		ifFalse: [super keyStroke: anEvent]
]
