Class {
	#name : #SBBashInputTextBubble,
	#superclass : #SBTextBubble,
	#instVars : [
		'terminal',
		'current'
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
SBBashInputTextBubble >> loadManpageFor: commandString into: collection [

	| manpage command |
	command := self terminal commands
		detect: [:c | c commandString = commandString]
		ifNone: [].
	command isNil
		ifTrue: [ | options |
			manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages; ./create_manpage_completions.py -f "', commandString, '"'.
			manpage = '' ifTrue: [^ nil].
			options := (self optionsFromManpage: manpage into: collection).
			self terminal commands add: (SBBashCommand new
				commandString: commandString;
				options: options)]
		ifFalse: [self optionsFromCommand: command into: collection]
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> optionsFromCommand: command into: collection [

	command options do: [:option | | flags description flagsSpread |
		description := option at: #description.
		flags := option at: #flags.
		flagsSpread := flags joinSeparatedBy: ', '.
		((flagsSpread findString: current) > 0 or: (description findString: current) > 0) ifTrue: [collection add: flagsSpread, ': ', description]]
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> optionsFromManpage: manpage into: collection [

	| ston options |
	ston := STON fromString: manpage.
	options := ston at: #options.
	options do: [:option | | flags description flagsSpread |
		description := option at: #description.
		flags := option at: #flags.
		flagsSpread := flags joinSeparatedBy: ', '.
		((flagsSpread findString: current) > 0 or: (description findString: current) > 0) ifTrue: [collection add: flagsSpread, ': ', description]].

	^ options
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> suggestions [

	| command suggestionTexts suggestions flagIndex |
	flagIndex := self contents findString: ' -'.
	"Find full command (everything before any flag)"
	flagIndex > 0
		ifTrue: [command := self contents from: 1 to: flagIndex - 1]
		ifFalse: [command := self contents].
	"Either collect suggestions for current word or (end on whitespace) show all options for flags"
	self contents lastSpacePosition = self contents size
		ifTrue: [current := '-']
		ifFalse: [current := (self contents subStrings: ' ') last].
	suggestionTexts := OrderedCollection new.
	"TODO: add suggestions for subcommands?"
	"TODO: Command Klasse hat Subcommands vom Type Command, opts (flags) und description
 und das terminal hat eine Collection von diesen Commands"
	"docker container ls -a"
	"gibt es schon den Hauptcommand (docker)?"
	"wenn ja, gibt es schon den Subcommand (container)?"
	"wenn ja, gibt es schon den Subcommand (ls)?"
	"alle options hinzufügen"
	"options durchsuchen"
	self loadManpageFor: command into: suggestionTexts.
	
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

	^ self containingArtefact
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> terminal: anObject [

	terminal := anObject
]
