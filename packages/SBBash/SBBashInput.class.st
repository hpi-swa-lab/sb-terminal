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

	| ston |
	ston := STON fromString: manpage.
	^ SBBashCommand new
		options: (ston at: #options);
		synopsis: (ston at: #synopsis);
		description: (ston at: #description)
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
		manpage := UnixProcess thisOSProcess waitForCommandOutput: 'cd ../manpages; ./create_manpage_completions.py -f "', anInfoObject mainCommand, '"'.
		manpage = '' ifTrue: [^ nil].
		command := self commandFrom: manpage.
		command fullCommandString: anInfoObject fullCommand.
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

	(aCommand element isTSChoice and: [(aCommand element alternatives anySatisfy: [:alt | alt type = #'_primary_expression']) not]) ifTrue: [^ #()].
	^ {
		(SBInsertSuggestionItem selector: 'a' label: 'arg')
			morph: (self parseToplevel: 'command ', '--FILL') childSandblocks first childSandblocks second
				previewOnly: true;
			yourself}
]

{ #category : #'as yet unclassified' }
SBBashInput class >> suggestionsFrom: anInfoObject into: collection [

	anInfoObject commandObject options do: [:option | | flags description flagsJoined firstFlag suggestionText |
		description := option at: #description.
		flags := option at: #flags.
		flags ifNotEmpty: [firstFlag := flags first] ifEmpty: [firstFlag := ''].
		flagsJoined := flags joinSeparatedBy: ', '.
		suggestionText := flagsJoined, ': ', description.
		((flagsJoined findString: anInfoObject searchString) > 0 or: (description findString: anInfoObject searchString) > 0) ifTrue: [
			"TODO: Blocks collection für Parameter verwenden"
			collection add: (SBBashTSBlockSuggestion new
				selector: description;
				blocks: {(self parseToplevel: 'command ', firstFlag) childSandblocks first childSandblocks second}
					in: anInfoObject sandblockEditor;
				option: firstFlag;
				command: anInfoObject mainCommand)]]
]
