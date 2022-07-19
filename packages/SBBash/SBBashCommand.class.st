Class {
	#name : #SBBashCommand,
	#superclass : #Object,
	#instVars : [
		'commandString',
		'subcommandStrings',
		'subcommands',
		'options',
		'description',
		'synopsis',
		'commandName',
		'terminal'
	],
	#category : #SBBash
}

{ #category : #'as yet unclassified' }
SBBashCommand class >> newFrom: anObject [

	| command |
	command := self new
		commandName: anObject commandName;
		commandString: anObject commandString;
		subcommands: anObject subcommands;
		options: anObject options;
		description: anObject description;
		synopsis: anObject synopsis;
		commandName: anObject commandName;
		terminal: anObject terminal
]

{ #category : #'as yet unclassified' }
SBBashCommand >> commandName [

	commandName ifNotNil: [^ commandName] ifNil: [^ commandString]
]

{ #category : #'as yet unclassified' }
SBBashCommand >> commandName: aString [

	commandName := aString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> commandString [

	^ commandString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> commandString: aString [

	commandString := aString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> description [

	^ description
]

{ #category : #'as yet unclassified' }
SBBashCommand >> description: anObject [

	description := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommand >> options [

	^ options
]

{ #category : #'as yet unclassified' }
SBBashCommand >> options: anObject [

	options := anObject
]

{ #category : #'as yet unclassified' }
SBBashCommand >> subcommands [

	subcommands ifNotNil: [subcommands ifNotEmpty: [^ subcommands]].
	^ subcommandStrings collect: [:commandString |
		SBBashCommand new
			commandString: commandString;
			commandName: '';
			description: '';
			options: {};
			subcommands: {};
			synopsis: '']
]

{ #category : #'as yet unclassified' }
SBBashCommand >> subcommands: aCollection [

	subcommandStrings := aCollection reject: [:e | e = commandString].
	Project current addDeferredUIMessage: [
		subcommands := subcommandStrings collect: [:commandString | | json command |
			json := Json readFrom: (UnixProcess thisOSProcess waitForCommandOutput: './', (SBBashEditor pathToManpageCompletionScript, (' -f "', (commandString, '"')))) readStream.
			command := SBBashCommand new
				commandString: commandString;
				commandName: (json at: #name);
				description: (json at: #description);
				options: (json at: #options);
				synopsis: (json at: #synopsis);
				terminal: terminal;
				subcommands: (json at: #commands).
			"checken, ob es schon da ist?"
			terminal commands add: command.
			command]]
]

{ #category : #'as yet unclassified' }
SBBashCommand >> synopsis [

	^ synopsis
]

{ #category : #'as yet unclassified' }
SBBashCommand >> synopsis: aString [

	synopsis := aString
]

{ #category : #'as yet unclassified' }
SBBashCommand >> terminal [

	^ terminal
]

{ #category : #'as yet unclassified' }
SBBashCommand >> terminal: anObject [

	terminal := anObject
]
