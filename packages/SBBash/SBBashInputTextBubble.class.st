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
SBBashInputTextBubble >> absorbsInput2: anEvent [
	"Wenn suggestions da sind, will ich da reinnavigieren
Wenn ich Shift halte, will ich mit ArrowUp den Focus wechseln"

	^ true
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> keyStroke: anEvent [

	anEvent keyCharacter
		caseOf: {
			[Character tab] -> [ | pty suggestionMenu |
				"suggestions may be empty, but the suggestionMenu might still have items"
				suggestionMenu := self sandblockEditor suggestionMenu.
				suggestionMenu hasItems ifTrue: [suggestionMenu useSuggestion] ifFalse: [
					self contents ifEmpty: [^ false].
					pty := self terminal pty.
					self terminal state: #autocomplete.
					pty nextPutAll: self contents.
					pty nextPut: Character tab.
					"Don't send incomplete command yet!"
					self terminal monitorSemaphor wait]].
			[Character return] -> [ | pty |
				pty := self terminal pty.
				"The command should not be printed"
				self terminal state: #hidden.
				Project current addDeferredUIMessage: [
					pty nextPutAll: self contents.
					pty nextPut: Character return]]}
		otherwise: [super keyStroke: anEvent]
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> loadManpageFor: fullCommandString into: collection [

	| manpage command |
	fullCommandString = '' ifTrue: [^ nil].
	command := self terminal commands
		detect: [:c | c commandString = fullCommandString]
		ifNone: [].
	command isNil
		ifTrue: [ | commandString |
			manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages; ./create_manpage_completions.py -f "', fullCommandString, '"'.
			manpage = '' ifTrue: [^ nil].
			commandString := fullCommandString from: 1 to: fullCommandString lastSpacePosition.
			command := self optionsFromManpage: manpage withCommand: fullCommandString into: collection.
			self terminal commands add: command]
		ifFalse: [self suggestionsFrom: command into: collection].
	^ command
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> optionsFromManpage: manpage withCommand: fullCommandString into: collection [

	| ston command |
	ston := STON fromString: manpage.
	command := SBBashCommand new
		options: (ston at: #options);
		fullCommandString: fullCommandString;
		synopsis: (ston at: #synopsis);
		description: (ston at: #description).
	self suggestionsFrom: command into: collection.
	
	^ command
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> suggestions [

	| commandString suggestions containsSpace command |
	suggestions := OrderedCollection new.
	containsSpace := (self contents findString: ' ') > 0.
	containsSpace ifFalse: [^ suggestions].
	commandString := self contents.
	"Either collect suggestions for current word or (end on whitespace) show all options for flags"
	self contents lastSpacePosition = self contents size
		ifTrue: [current := '-']
		ifFalse: [current := (self contents subStrings: ' ') last].
	"TODO: add suggestions for subcommands?"
	"TODO: Command Klasse hat Subcommands vom Type Command, opts (flags) und description
 und das terminal hat eine Collection von diesen Commands"
	"docker container ls -a"
	"gibt es schon den Hauptcommand (docker)?"
	"wenn ja, gibt es schon den Subcommand (container)?"
	"wenn ja, gibt es schon den Subcommand (ls)?"
	"alle options hinzufügen"
	"options durchsuchen"
	command := self loadManpageFor: commandString into: suggestions.
	command ifNotNil: [
		self terminal synopsis: command synopsis.
		self terminal description: command description].
	
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
SBBashInputTextBubble >> suggestionsFrom: command into: collection [

	command options do: [:option | | flags description flagsJoined firstFlag suggestionText |
		description := option at: #description.
		flags := option at: #flags.
		flags ifNotEmpty: [firstFlag := flags first] ifEmpty: [firstFlag := ''].
		flagsJoined := flags joinSeparatedBy: ', '.
		suggestionText := flagsJoined, ': ', description.
		((flagsJoined findString: current) > 0 or: (description findString: current) > 0) ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				selector: suggestionText;
				option: firstFlag;
				command: command commandString)]]
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> terminal [

	^ self containingArtefact
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> terminal: anObject [

	terminal := anObject
]

{ #category : #'as yet unclassified' }
SBBashInputTextBubble >> useSuggestion: anItem [

	self contents: anItem command, anItem option
	"self sandblockEditor suggestionMenu activeItem flag"
	"self suggestions first flag"
]
