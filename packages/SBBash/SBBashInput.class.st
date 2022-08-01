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
SBBashInput class >> deduplicateBashSuggestions: aCollection [

	| dict deduplicationDict sizesDict suggestionDict uniqSuggs uniqGroups |
	dict := aCollection groupBy: [:suggestion | suggestion key].
	sizesDict := dict collect: [:c | c value size].
	suggestionDict := dict collect: [:c | c value first].
	SBToggledCode
		comment: ''
		active: 0
		do: {[orderedDict := dict withKeysSorted: [:k1 :k2 | (sizesDict at: k1) >= (sizesDict at: k2)]]}.
	uniqSuggs := OrderedCollection new.
	SBToggledCode comment: '' active: 0 do: {
		[orderedDict keysDo: [:c | deduplicatedSuggestions add: ((suggestionDict at: c) option: (sizesDict at: c) printString)]]}.
	
	deduplicationDict := OrderedDictionary new.
	aCollection reverseDo: [:suggestion | deduplicationDict at: suggestion key put: suggestion].
	uniqSuggs := deduplicationDict keys reverse.
	uniqGroups := OrderedCollection new.
	uniqSuggs do: [:c | | uniqueSuggestion moreOptions |
		uniqueSuggestion := suggestionDict at: c.
		moreOptions := (sizesDict at: c) - 1.
		moreOptions > 0 ifTrue: [uniqueSuggestion selector: moreOptions printString, ' more option(s)'].
		uniqGroups add: uniqueSuggestion].
	^ uniqGroups
]

{ #category : #'as yet unclassified' }
SBBashInput class >> getSuggestionFromCommand: aCommandObject in: anEditor [

	| selector upto contents |
	selector := aCommandObject commandName.
	selector size > 100 ifTrue: [selector := (selector from: 1 to: 97), '...'].
	upto := (aCommandObject commandString findString: ' ') - 1.
	upto < 0 ifTrue: [upto := aCommandObject commandString size].
	contents := aCommandObject commandString from: 1 to: upto.
	^ SBBashTSBlockSuggestion new
		selector: selector;
		blocks: {
				(self blockFor: #word)
					contents: contents;
					yourself}
			in: anEditor;
		option: aCommandObject commandString;
		key: contents
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadCommandFromManpage: manpage for: anInfoObject [

	| json |
	json := Json readFrom: manpage readStream.
	^ SBBashCommand new
		commandString: anInfoObject mainCommand;
		commandName: (json at: #name);
		options: (json at: #options);
		synopsis: (json at: #synopsis);
		description: (json at: #description);
		terminal: anInfoObject terminal;
		subcommands: (json at: #commands)
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadCommandObjectFor: anInfoObject [

	| command fallbackSubcommands |
	fallbackSubcommands := OrderedCollection new.
	"this could also be a function in the info object"
	command := anInfoObject terminal commands
		detect: [:c |
			(c commandString includesSubstring: anInfoObject mainCommand, ' ') ifTrue: [fallbackSubcommands add: c].
			c commandString = anInfoObject mainCommand]
		ifNone: [ | subcommands |
			SBToggledCode comment: '' active: 0 do: {[subcommands := anInfoObject terminal commands]}.
			subcommands := fallbackSubcommands.
			SBBashCommand new
				commandString: '';
				subcommands: subcommands;
				subcommandStrings: {};
				options: {};
				description: 'Currently not a valid command';
				synopsis: 'Currently not a valid command';
				terminal: anInfoObject terminal].
	anInfoObject commandObject: command
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadCommandsFrom: anInfoObject into: aCollection [

	| perfectFit goodFits |
	goodFits := OrderedCollection new.
	anInfoObject commandObject: (SBBashCommand new
		commandString: '';
		subcommands: anInfoObject terminal commands;
		subcommandStrings: {};
		options: {};
		description: '';
		synopsis: '';
		terminal: anInfoObject terminal).
	anInfoObject terminal commands do: [:cmd |
		(cmd commandString asLowercase includesSubstring: anInfoObject searchString asLowercase)
			ifTrue: [
				cmd commandString = anInfoObject searchString
					ifTrue: [perfectFit := self getSuggestionFromCommand: cmd in: anInfoObject sandblockEditor]
					ifFalse: [goodFits add: (self getSuggestionFromCommand: cmd in: anInfoObject sandblockEditor)]]
			ifFalse: [(cmd commandName includesSubstring: anInfoObject searchString) ifTrue: [aCollection add: (self getSuggestionFromCommand: cmd in: anInfoObject sandblockEditor)]]].
	aCollection addAllFirst: goodFits.
	perfectFit ifNotNil: [aCollection addFirst: perfectFit]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertSubcommandsFrom: anInfoObject into: collection [

	| subcommands |
	subcommands := self loadOnlyNextSubcommandsFor: anInfoObject.
	subcommands do: [:subcmd |
		collection add: (SBBashInsertSuggestionItem new
			selector: subcmd commandName;
			morphs: {
					(self blockFor: #word)
						contents: subcmd commandString;
						yourself}
				editor: anInfoObject sandblockEditor;
			key: subcmd commandString)]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadInsertSuggestionsFrom: anInfoObject into: collection [

	anInfoObject commandObject ifNil: [^ {}].
	anInfoObject commandObject options do: [:option | | morphs flagInfo |
		"TODO: new from json"
		flagInfo := SBBashFlagInformation new
			description: (option at: #description);
			flags: (option at: #flags);
			arguments: ((option at: #arguments) ifNil: [{}]);
			optionals: ((option at: #optionals) ifNil: [{}]).
		
		morphs := OrderedCollection new.
		"TODO: folgenden Blob in Methode auslagern?"
		flagInfo arguments
			ifEmpty: [
				morphs add: ((SBBashInput blockFor: #flag)
					contents: flagInfo firstFlag;
					yourself)]
			ifNotEmpty: [
				morphs add: ((SBBashInput blockFor: #flag)
					contents: flagInfo firstFlag;
					addBlock: ((SBBashInput blockFor: #'flag_argument') in: [:b |
						b lastDeepChild lastSubmorph placeholderText: flagInfo arguments first.
						b]);
					yourself)].
		collection add: (SBBashInsertSuggestionItem new
			selector: flagInfo description;
			morphs: morphs editor: anInfoObject sandblockEditor;
			key: flagInfo firstFlag).
		"with optionals"
		flagInfo optionals notEmpty ifTrue: [
			morphs := flagInfo optionals collect: [:opt |
				(SBBashInput blockFor: #flag)
					contents: flagInfo firstFlag;
					addBlock: ((SBBashInput blockFor: #'flag_argument') in: [:b |
						b lastDeepChild lastSubmorph placeholderText: opt.
						b]);
					yourself].
			collection add: (SBBashInsertSuggestionItem new
				morphs: morphs editor: anInfoObject sandblockEditor;
				key: flagInfo firstFlag)]]
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadOnlyNextSubcommandsFor: anInfoObject [

	| subcommands |
	anInfoObject commandObject ifNil: [^ {}].
	subcommands := anInfoObject commandObject subcommands collect: [:cmdObj | | from upto |
		from := anInfoObject mainCommand size + 2.
		upto := (cmdObj commandString findString: ' ' startingAt: from) - 1.
		upto < 0 ifTrue: [upto := cmdObj commandString size].
		cmdObj commandString size >= from ifTrue: [ | newCommandObject |
			newCommandObject := cmdObj shallowCopy.
			newCommandObject commandString: (cmdObj commandString from: from to: upto).
			newCommandObject]].
	subcommands := subcommands select: [:cmdObj | cmdObj notNil].
	"subcommands := (subcommands
		collect: [:cmdObj | cmdObj commandString -> true]
		into: OrderedDictionary new) keys.
	1 halt."
	^ subcommands
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadSubcommandsFrom: anInfoObject into: collection [

	| subcommands |
	subcommands := self loadOnlyNextSubcommandsFor: anInfoObject.
	subcommands do: [:subcmd |
		(subcmd commandName asLowercase includesSubstring: anInfoObject searchString asLowercase) ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				selector: subcmd commandName;
				blocks: {
						(self blockFor: #word)
							contents: subcmd commandString;
							yourself}
					in: anInfoObject sandblockEditor;
				option: subcmd commandString;
				key: subcmd commandString)]]
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
			ifEmpty: [
				morphs add: ((SBBashInput blockFor: #flag)
					contents: flagInfo firstFlag;
					yourself)]
			ifNotEmpty: [
				morphs add: ((SBBashInput blockFor: #flag)
					contents: flagInfo firstFlag;
					addBlock: ((SBBashInput blockFor: #'flag_argument') in: [:b |
						b lastDeepChild lastSubmorph placeholderText: flagInfo arguments first.
						b]);
					yourself)].
		((flagInfo flagsJoined asLowercase includesSubstring: anInfoObject searchString asLowercase) or: (flagInfo description asLowercase includesSubstring: anInfoObject searchString asLowercase)) ifTrue: [
			collection add: (SBBashTSBlockSuggestion new
				selector: flagInfo description;
				blocks: morphs in: anInfoObject sandblockEditor;
				option: flagInfo firstFlag;
				terminalCommand: anInfoObject mainCommand).
			"with optionals"
			flagInfo optionals notEmpty ifTrue: [
				morphs := flagInfo optionals collect: [:opt |
					(SBBashInput blockFor: #flag)
						contents: flagInfo firstFlag;
						addBlock: ((SBBashInput blockFor: #'flag_argument') in: [:b |
							b lastDeepChild lastSubmorph placeholderText: opt.
							b]);
						yourself].
				collection add: (SBBashTSBlockSuggestion new
					blocks: morphs in: anInfoObject sandblockEditor;
					option: flagInfo firstFlag;
					terminalCommand: anInfoObject mainCommand;
					key: flagInfo firstFlag, 'optional')]]]
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
	(aBlock type ~= #word and: [aBlock type ~= #flag]) ifTrue: [^ suggestions].
	
	"Könnte in eine Methode SBBashCommandInformation >> newFromBlock: aBlock"
	terminal := aBlock containingArtefact.
	info := SBBashCommandInformation new
		fullCommand: aBlock parentSandblock sourceString;
		searchString: aBlock sourceString;
		terminal: terminal;
		sandblockEditor: aBlock sandblockEditor.
	
	aBlock parentSandblock type = #'command_name' ifTrue: [
		"reduce lag by only searching commands beyond a certain length"
		info searchString size >= 3 ifTrue: [self loadCommandsFrom: info into: suggestions].
		^ self deduplicateBashSuggestions: suggestions].
	
	self loadCommandObjectFor: info.
	self loadSubcommandsFrom: info into: suggestions.
	self loadSuggestionsFrom: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description.
		terminal debugOutput: info mainCommand].
	^ self deduplicateBashSuggestions: suggestions
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
	
	self loadCommandObjectFor: info.
	self loadInsertSubcommandsFrom: info into: suggestions.
	self loadInsertSuggestionsFrom: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description].
	
	^ self deduplicateBashSuggestions: suggestions
]

{ #category : #'as yet unclassified' }
SBBashInput class >> transitionPairs [

	^ {#command -> #'function_definition'}
]
