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
			terminal := self containingArtefact.
			pty := terminal pty.
			"next command should not be printed"
			terminal state: #hidden.
			pty nextPutAll: self contents.
			pty nextPut: Character return]
		ifFalse: [super keyStroke: anEvent]
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> suggestions [

	| current command suggestionTexts suggestions methodOrNil manpage |
	command := (self contents subStrings: ' ') first.
	current := (self contents subStrings: ' ') last.
	suggestionTexts := Set new.
	
	methodOrNil := SBBashManpageHolder class methodDictionary
		at: command asSymbol
		ifAbsent: [nil].
	methodOrNil isNil not ifTrue: [ | index |
		manpage := methodOrNil decompileString.
		index := 0.
		[
			index := index + 1.
			index := manpage findString: current startingAt: index.
			index = 0 ifFalse: [suggestionTexts add: '...', ((manpage from: (index max: 1) to: (index + 100 min: manpage size)), '...')]] doWhileFalse: [index = 0]].
	
	suggestions := (suggestionTexts collect: [:text | SBSuggestionItem selector: text label: command]) asArray.
	^ suggestions
]
