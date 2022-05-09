Class {
	#name : #SBBashInputTextBubble,
	#superclass : #SBTextBubble,
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> keyStroke: anEvent [

	| pty2 |
	pty2 := self parentSandblock parentSandblock parentSandblock pty.
	pty2 nextPut: anEvent keyCharacter.
	super keyStroke: anEvent.
	SBToggledCode comment: '' active: 0 do: {
		[
			anEvent keyCharacter = Character return
				ifTrue: [ | pty |
					"TODO: Tom fragen, wie man das macht"
					pty := self parentSandblock parentSandblock parentSandblock pty.
					"TODO: hier noch weitere eigene ctrl Seq"
					pty nextPutAll: self contents.
					pty nextPut: Character return]
				ifFalse: [super keyStroke: anEvent]]}
]
