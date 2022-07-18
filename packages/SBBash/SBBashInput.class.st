Class {
	#name : #SBBashInput,
	#superclass : #SBBash,
	#instVars : [
		'terminal',
		'current',
		'processReturn'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashInput class >> autocompleteFile [
	<action>
	<actionValidIf: #canAutocompleteFile:>

	UIManager default inform: 'please first implement autocompletion'
]

{ #category : #'as yet unclassified' }
SBBashInput class >> canAutocompleteFile: aBlock [

	^ aBlock type = #word and: [aBlock sandblockEditor suggestionMenu canUseSuggestion not]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> commandFrom: manpage [

	| json |
	json := Json readFrom: manpage readStream.
	^ SBBashCommand new
		options: (json at: #options);
		synopsis: (json at: #synopsis);
		description: (json at: #description)
]

{ #category : #'as yet unclassified' }
SBBashInput class >> confirm: aBlock [
	<action>

	| pty terminal command |
	terminal := aBlock containingArtefact.
	command := (aBlock orOwnerSuchThat: [:b | b isTSBlock and: [b type = #command]]) ifNotNil: #sourceString ifNil: [^ self].
	pty := terminal pty.
	terminal state: #hidden.
	terminal waitingForCommandString: command.
	pty nextPutAll: command.
	pty nextPut: Character return
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertSubcommandsFrom: anInfoObject into: collection [

	| subcommands |
	subcommands := self loadOnlyNextSubcommandsFor: anInfoObject.
	"TODO: machen, dass das richtig geparst wird --> command davor, aber nicht alle Blöcke nehmen"
	subcommands do: [:subcmd |
		collection add: (SBBashInsertSuggestionItem new
			morphs: {
				(self blockFor: #word)
					contents: subcmd;
					yourself}
			editor: anInfoObject sandblockEditor)]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertSuggestionsFrom: anInfoObject into: collection [
	
	anInfoObject commandObject ifNil: [^{}].
	anInfoObject commandObject options do: [:option | | morphs flagInfo |
		flagInfo := SBBashFlagInformation new
			description: (option at: #description);
			flags: (option at: #flags);
			arguments: ((option at: #arguments) ifNil: [{}]);
			optionals: ((option at: #optionals) ifNil: [{}]).
		
		morphs := OrderedCollection new.
		flagInfo arguments
			ifEmpty: [morphs add: (self parseToplevel: 'command ', flagInfo firstFlag) childSandblocks first childSandblocks second]
			ifNotEmpty: [morphs add: (self parseToplevel: 'command ', (flagInfo firstFlag, ('=', flagInfo arguments first))) childSandblocks first childSandblocks second].
		collection add: (SBBashInsertSuggestionItem new
			selector: flagInfo description;
			morphs: morphs editor: anInfoObject sandblockEditor).
		"with optionals"
		flagInfo optionals notEmpty ifTrue: [
			morphs addAll: (flagInfo optionals collect: [:opt | (self parseToplevel: 'command ', (flagInfo firstFlag, ('=', opt))) childSandblocks first childSandblocks second]).
			collection add: (SBBashInsertSuggestionItem new
				morphs: morphs
				editor: anInfoObject sandblockEditor)]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadManpageFor: anInfoObject [

	| manpage command |
	"this could also be a function in the info object"
	command := anInfoObject terminal commands
		detect: [:c | c commandString = anInfoObject mainCommand]
		ifNone: [].
	command isNil ifTrue: [
		manpage := UnixProcess thisOSProcess waitForCommandOutput: './', (SBBashEditor pathToManpageCompletionScript, ' -f "'), anInfoObject mainCommand, '"'.
		manpage = '' ifTrue: [^ nil].
		command := self commandFrom: manpage.
		command
			commandString: anInfoObject mainCommand;
			subcommands: (anInfoObject terminal allCommands select: [:cmd | (cmd findString: anInfoObject mainCommand, ' ') = 1]).
		anInfoObject terminal commands add: command].
	anInfoObject commandObject: command
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadOnlyNextSubcommandsFor: anInfoObject [

	| subcommands |
	anInfoObject commandObject ifNil: [^{}].
	subcommands := anInfoObject commandObject subcommands collect: [:cmd | | from upto |
		from := anInfoObject mainCommand size + 2.
		upto := (cmd findString: ' ' startingAt: from) - 1.
		upto < 0 ifTrue: [upto := cmd size].
		cmd size >= from ifTrue: [cmd from: from to: upto]].
	subcommands := subcommands select: [:cmd | cmd notNil].
	subcommands := (subcommands collect: [:cmd | cmd -> true] into: OrderedDictionary new) keys.
	^ subcommands
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadSubcommandsFrom: anInfoObject into: collection [

	| subcommands |
	subcommands := self loadOnlyNextSubcommandsFor: anInfoObject.
	"TODO: machen, dass das richtig geparst wird --> command davor, aber nicht alle Blöcke nehmen"
	subcommands do: [:subcmd |
		(subcmd findString: anInfoObject searchString) > 0 ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				blocks: {(self blockFor: #word) contents: subcmd}
				in: anInfoObject sandblockEditor)]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadSuggestionsFrom: anInfoObject into: collection [

	anInfoObject commandObject ifNil: [^ {}].
	anInfoObject commandObject options do: [:option | | morphs flagInfo |
		flagInfo := SBBashFlagInformation new
			description: (option at: #description);
			flags: (option at: #flags);
			arguments: (option at: #arguments);
			optionals: (option at: #optionals).
		
		morphs := OrderedCollection new.
		flagInfo arguments
			ifEmpty: [morphs add: (self parseToplevel: 'command ', flagInfo firstFlag) childSandblocks first childSandblocks second]
			ifNotEmpty: [morphs add: (self parseToplevel: 'command ', (flagInfo firstFlag, ('=', flagInfo arguments first))) childSandblocks first childSandblocks second].
		((flagInfo flagsJoined findString: anInfoObject searchString) > 0 or: (flagInfo description findString: anInfoObject searchString) > 0) ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				selector: flagInfo description;
				blocks: morphs in: anInfoObject sandblockEditor;
				option: flagInfo firstFlag;
				terminalCommand: anInfoObject mainCommand).
			"with optionals"
			flagInfo optionals notEmpty ifTrue: [
				morphs addAll: (flagInfo optionals collect: [:opt | (self parseToplevel: 'command ', (flagInfo firstFlag, ('=', opt))) childSandblocks first childSandblocks second]).
				collection add: (SBBashTSBlockSuggestion new
					blocks: morphs in: anInfoObject sandblockEditor;
					option: flagInfo firstFlag;
					terminalCommand: anInfoObject mainCommand)]]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestAlwaysFor: aBlock [

	^ true
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsFor2: aBlock [

	(aBlock type = #word and: [aBlock parentSandblock type = #command]) ifTrue: [
		^ {
			SBTSBlockSuggestion new
				blocks: {(self parseToplevel: 'command ', 'FILL') childSandblocks first childSandblocks second}
				in: aBlock sandblockEditor}].
	^ #()
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsFor: aBlock [

	| suggestions info terminal |
	suggestions := OrderedCollection new.
	((aBlock type = #word and: [aBlock parentSandblock type = #command]) not and: [aBlock type ~= #flag]) ifTrue: [^ suggestions].
	terminal := aBlock containingArtefact.
	info := SBBashCommandInformation new
		fullCommand: aBlock parentSandblock sourceString;
		searchString: aBlock sourceString;
		terminal: terminal;
		sandblockEditor: aBlock sandblockEditor.
	self loadManpageFor: info.
	self loadSubcommandsFrom: info into: suggestions.
	self loadSuggestionsFrom: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description.
		terminal debugOutput: info mainCommand].
	^ suggestions
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsForInsert: aCommand [

	| suggestions terminal info container |
	suggestions := OrderedCollection new.
	(aCommand element isTSChoice and: [(aCommand element alternatives anySatisfy: [:alt | alt type = #'_primary_expression']) not]) ifTrue: [^ suggestions].
	container := aCommand container.
	container childSandblocks ifEmpty: [^ suggestions].
	terminal := container containingArtefact.
	
	info := SBBashCommandInformation new
		fullCommand: container sourceString;
		terminal: terminal;
		sandblockEditor: container sandblockEditor.
	aCommand index > 1 ifTrue: [info previousBlock: (container childSandblocks at: aCommand index - 1)].
	self loadManpageFor: info.
	self loadInsertSubcommandsFrom: info into: suggestions.
	self loadInsertSuggestionsFrom: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description].
	^ suggestions
]

{ #category : #'as yet unclassified' }
SBBashInput class >> transitionPairs [

	^ {#command -> #'function_definition'}
]
