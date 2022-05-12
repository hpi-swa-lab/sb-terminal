Class {
	#name : #SBBashInputTextBubble,
	#superclass : #SBTextBubble,
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> keyStroke: anEvent [

	anEvent keyCharacter = Character return
		ifTrue: [ | pty terminal |
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

	| current command suggestionTexts suggestions manpage |
	command := (self contents subStrings: ' ') first.
	current := (self contents subStrings: ' ') last.
	suggestionTexts := OrderedCollection new.
	
	manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages; ./create_manpage_completions.py ', command, '.1.gz -s'.
	manpage linesDo: [:line |
		"in each line: parse the line by searching flags and descriptions
example line for command ls -b:
complete -c ls -s b -l escape -d 'print C-style escapes for nongraphic characters'"
		"TODO: wenn -a da steht, suche auch nach a"
		(line findString: current) > 0 ifTrue: [ | descIndex flagIndex |
			flagIndex := (line findString: ' -s ') + 4.
			flagIndex > 0 ifFalse: [flagIndex := (line findString: ' -l ') + 4].
			descIndex := (line findString: ' -d ') + 4.
			(descIndex > 4 and: flagIndex > 4) ifTrue: [ | description flagEndIndex flag |
				description := line from: descIndex.
				flagEndIndex := (line findString: '-' startingAt: flagIndex) - 1.
				flag := line from: flagIndex to: flagEndIndex.
				suggestionTexts add: '-', flag, (': ', description)]]].
	
	suggestions := (suggestionTexts collect: [:text | SBSuggestionItem selector: text label: command, (' ', current)]) asArray.
	^ suggestions
]
