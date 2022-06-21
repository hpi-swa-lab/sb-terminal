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
	command := (aBlock orOwnerSuchThat: [:b | b type = #command]) sourceString.
	terminal := aBlock containingArtefact.
	pty := terminal pty.
	terminal state: #hidden.
	terminal waitingForCommandString: command.
	pty nextPutAll: command.
	pty nextPut: Character return
]

{ #category : #'as yet unclassified' }
SBBashInput class >> loadManpageFor: anInfoObject into: collection [

	| manpage command |
	"this could also be a function in the info object"
	command := anInfoObject terminal commands
		detect: [:c | c commandString = anInfoObject mainCommand]
		ifNone: [].
	command isNil ifTrue: [
		manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages/manpage_completions; ./create_manpage_completions.py -f "', anInfoObject mainCommand, '"'.
		manpage = '' ifTrue: [^ nil].
		command := self commandFrom: manpage.
		command commandString: anInfoObject mainCommand.
		anInfoObject terminal commands add: command].
	anInfoObject commandObject: command.
	self suggestionsFrom: anInfoObject into: collection
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
	(aBlock type = #word and: [aBlock parentSandblock type = #command]) ifFalse: [^ suggestions].
	terminal := aBlock containingArtefact.
	info := SBBashCommandInformation new
		fullCommand: aBlock parentSandblock sourceString;
		searchString: aBlock sourceString;
		terminal: terminal;
		sandblockEditor: aBlock sandblockEditor.
	self loadManpageFor: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description].
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
		previousBlock: (container childSandblocks at: aCommand index - 1);
		terminal: terminal;
		sandblockEditor: container sandblockEditor.
	self loadManpageFor: info into: suggestions.
	info commandObject ifNotNil: [
		terminal synopsis: info commandObject synopsis.
		terminal description: info commandObject description].
	^ suggestions
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsFrom: anInfoObject into: collection [

	anInfoObject commandObject options do: [:option | | flags description flagsJoined firstFlag suggestionText arguments optionals morphs |
		description := option at: #description.
		flags := option at: #flags.
		arguments := option at: #arguments.
		optionals := option at: #optionals.
		flags ifNotEmpty: [firstFlag := flags first] ifEmpty: [firstFlag := ''].
		flagsJoined := flags joinSeparatedBy: ', '.
		suggestionText := flagsJoined, ': ', description.
		
		morphs := OrderedCollection new.
		morphs add: (self parseToplevel: 'command ', firstFlag) childSandblocks first childSandblocks second.
		morphs addAll: (arguments collect: [:arg | (self parseToplevel: 'command ', ('=', arg)) childSandblocks first childSandblocks second]).
		anInfoObject searchString
			ifNil: [
				"probably from suggestionsForInsert:"
				"without optionals"
				collection add: (SBBashInsertSuggestionItem new
					selector: description;
					morphs: morphs editor: anInfoObject sandblockEditor).
				"with optionals"
				optionals notEmpty ifTrue: [
					morphs addAll: (optionals collect: [:opt | (self parseToplevel: 'command ', ('=', opt)) childSandblocks first childSandblocks second]).
					collection add: (SBBashInsertSuggestionItem new
						morphs: morphs
						editor: anInfoObject sandblockEditor)]]
			ifNotNil: [
				"probably from suggestionsFor:"
				((flagsJoined findString: anInfoObject searchString) > 0 or: (description findString: anInfoObject searchString) > 0) ifTrue: [
					collection add: (SBBashTSBlockSuggestion new
						selector: description;
						blocks: morphs in: anInfoObject sandblockEditor;
						option: firstFlag;
						command: anInfoObject mainCommand).
					optionals notEmpty ifTrue: [
						morphs addAll: (optionals collect: [:opt | (self parseToplevel: 'command ', ('=', opt)) childSandblocks first childSandblocks second]).
						collection add: (SBBashTSBlockSuggestion new
							blocks: morphs in: anInfoObject sandblockEditor;
							option: firstFlag;
							command: anInfoObject mainCommand)]]]]
]
