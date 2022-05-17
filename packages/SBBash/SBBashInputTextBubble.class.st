Class {
	#name : #SBBashInputTextBubble,
	#superclass : #SBTextBubble,
	#instVars : [
		'terminal'
	],
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

	| current command suggestionTexts suggestions manpageInfo flagIndex manpage |
	flagIndex := self contents findString: ' -'.
	flagIndex > 0
		ifTrue: [command := self contents from: 1 to: flagIndex - 1]
		ifFalse: [command := self contents].
	current := (self contents subStrings: ' ') last.
	suggestionTexts := OrderedCollection new.
	
	"TODO: Command Klasse hat Subcommands vom Type Command, opts (flags) und description"
	
	manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages; ./create_manpage_completions.py -f "', command, '"'.
	manpage = '' ifTrue: [^ #()].
	manpageInfo := STON fromString: manpage.
	(manpageInfo at: #options) do: [:option | | flags description flagsSpread |
		description := option at: #description.
		flags := option at: #flags.
		flagsSpread := flags joinSeparatedBy: ', '.
		((flagsSpread findString: current) > 0 or: (description findString: current) > 0) ifTrue: [suggestionTexts add: flagsSpread, ': ', description]].
	
	suggestions := (suggestionTexts collect: [:text | SBSuggestionItem selector: text label: command]) asArray.
	^ suggestions
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> suggestions2 [

	| current command suggestionTexts suggestions manpage |
	command := (self contents subStrings: ' ') first.
	current := (self contents subStrings: ' ') last.
	suggestionTexts := OrderedCollection new.
	
	manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages; ./create_manpage_completions.py /usr/share/man/man1/', command, '.1.gz -s'.
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

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> terminal [

	^ terminal
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> terminal: anObject [

	terminal := anObject
]
